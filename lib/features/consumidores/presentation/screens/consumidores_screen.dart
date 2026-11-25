import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../providers/consumidores_provider.dart';

/// Listado de consumidores (en el menú se llama "Clientes")
class ConsumidoresScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const ConsumidoresScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<ConsumidoresScreen> createState() => _ConsumidoresScreenState();
}

class _ConsumidoresScreenState extends ConsumerState<ConsumidoresScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filtros
  String? _searchFilter; // Solo se aplica con 3 o más caracteres
  bool? _activoFilter; // null = todos

  // Búsqueda con debounce
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Scroll controller para scroll-to-top
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    // Listener para mostrar/ocultar botón scroll-to-top
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToTop) {
        setState(() {
          _showScrollToTop = showButton;
        });
      }
    });

    // Listener para recargar cuando la app regresa del background
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        debugPrint('App resumed - reloading consumidores data');
        _refreshData();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(consumidoresProvider.notifier).loadConsumidores(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          search: _searchFilter,
          activo: _activoFilter,
        );
  }

  // Pull-to-refresh: limpia cache y recarga
  Future<void> _refreshData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Limpiar cache
    await ref.read(consumidoresProvider.notifier).clearCache(user.clienteId);

    // Recargar datos forzando refresh
    await ref.read(consumidoresProvider.notifier).loadConsumidores(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          search: _searchFilter,
          activo: _activoFilter,
          forceRefresh: true,
        );
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
  }

  // ===========================================================================
  // FILTROS
  // ===========================================================================

  bool get _tieneFiltrosActivos =>
      _searchController.text.isNotEmpty ||
      _searchFilter != null ||
      _activoFilter != null;

  /// Búsqueda con debounce: solo consulta con 3 o más caracteres.
  /// Si el texto baja de 3 y había búsqueda activa, la quita.
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    // Refresca la visibilidad del botón "Limpiar filtros"
    setState(() {});

    final query = value.trim();
    final nuevoFiltro = query.length >= 3 ? query : null;

    // Sin cambio efectivo en el filtro: no consultar
    if (nuevoFiltro == _searchFilter) return;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _searchFilter = nuevoFiltro;
        _currentPage = 1;
      });
      _loadData();
    });
  }

  void _limpiarFiltros() {
    _debounce?.cancel();
    setState(() {
      _searchController.clear();
      _searchFilter = null;
      _activoFilter = null;
      _currentPage = 1;
    });
    _loadData();
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceVariant,
      child: Column(
        children: [
          // Búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar cliente',
              hintText: 'Digite al menos 3 caracteres...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              filled: true,
              fillColor: AppColors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
          SizedBox(height: AppSpacing.md),

          // Filtro por estado (todos / activos / inactivos)
          DropdownButtonFormField<bool?>(
            value: _activoFilter,
            decoration: InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
            items: const [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text('Todos'),
              ),
              DropdownMenuItem<bool?>(
                value: true,
                child: Text('Activos'),
              ),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Inactivos'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _activoFilter = value;
                _currentPage = 1;
              });
              _loadData();
            },
          ),

          // Botón limpiar filtros
          if (_tieneFiltrosActivos) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consumidoresState = ref.watch(consumidoresProvider);
    final data = consumidoresState.data;

    final bodyContent = Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Filtros
                _buildFiltros(),

                // Lista de consumidores o estados (loading/error/empty)
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: consumidoresState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : consumidoresState.error != null && data == null
                          ? Center(
                              child: Text(
                                consumidoresState.error!,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )
                          : data == null || data.consumidores.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay clientes',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Column(
                                      children: data.consumidores.map((consumidor) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                                          child: _ConsumidorCard(consumidor: consumidor),
                                        );
                                      }).toList(),
                                    ),
                                    // Indicador de loading para paginación (no bloquea UI)
                                    if (consumidoresState.isLoadingMore)
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(AppSpacing.sm),
                                          color: AppColors.primary.withValues(alpha: 0.9),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16.w,
                                                height: 16.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                      AppColors.white),
                                                ),
                                              ),
                                              SizedBox(width: AppSpacing.sm),
                                              Text(
                                                'Cargando...',
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                ),

                // Paginación
                if (data?.pagination != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Anterior
                        TextButton.icon(
                          onPressed: data!.pagination!.hasPrevious
                              ? () {
                                  setState(() => _currentPage--);
                                  _loadData();
                                }
                              : null,
                          icon: Icon(Icons.chevron_left, size: 20.sp),
                          label: Text(
                            'Anterior',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),

                        // Información de página
                        Text(
                          'Página $_currentPage de ${data.pagination!.totalPages}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),

                        // Botón Siguiente
                        TextButton.icon(
                          onPressed: data.pagination!.hasNext
                              ? () {
                                  setState(() => _currentPage++);
                                  _loadData();
                                }
                              : null,
                          label: Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                          icon: Icon(Icons.chevron_right, size: 20.sp),
                        ),
                      ],
                    ),
                  ),

                // Espaciado adicional al final para que el botón flotante no cubra contenido
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),

        // Botón flotante scroll-to-top
        if (_showScrollToTop)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28.r),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(28.r),
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppColors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (!widget.showScaffold) {
      return bodyContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada consumidor
class _ConsumidorCard extends StatelessWidget {
  final ConsumidorEntity consumidor;

  const _ConsumidorCard({required this.consumidor});

  /// Fila con un icono y un texto de contacto
  Widget _infoRow(IconData icon, String texto) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telefono = consumidor.telefono;
    final email = consumidor.email;
    final direccion = consumidor.direccion;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre + etiqueta inactivo
            Row(
              children: [
                Flexible(
                  child: Text(
                    consumidor.nombreRazonSocial,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (!consumidor.activo) ...[
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey300.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'INACTIVO',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4.h),

            // Identificación (con dígito de verificación si lo tiene)
            Text(
              '${consumidor.tipoIdentificacion}: ${consumidor.identificacionCompleta}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),

            // Datos de contacto (solo los que existen)
            if (telefono != null && telefono.isNotEmpty)
              _infoRow(Icons.phone_outlined, telefono),
            if (email != null && email.isNotEmpty)
              _infoRow(Icons.email_outlined, email),
            if (direccion != null && direccion.isNotEmpty)
              _infoRow(Icons.location_on_outlined, direccion),
          ],
        ),
      ),
    );
  }
}
