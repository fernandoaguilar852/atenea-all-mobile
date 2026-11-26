import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../providers/cotizaciones_provider.dart';
import '../widgets/crear_cotizacion_form.dart';
import 'cotizacion_detalle_screen.dart';

class CotizacionesScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const CotizacionesScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<CotizacionesScreen> createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends ConsumerState<CotizacionesScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filtros
  String? _searchFilter; // Solo se aplica con 3 o más caracteres
  String _origenFilter = CotizacionOrigen.defaultOrigen;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

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
        debugPrint('App resumed - reloading cotizaciones data');
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

    ref.read(cotizacionesProvider.notifier).loadCotizaciones(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          search: _searchFilter,
          origen: _origenFilter,
          startDate: _fechaDesde,
          endDate: _fechaHasta,
        );
  }

  // Pull-to-refresh: limpia cache y recarga
  Future<void> _refreshData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Limpiar cache
    await ref.read(cotizacionesProvider.notifier).clearCache(user.clienteId);

    // Recargar datos forzando refresh
    await ref.read(cotizacionesProvider.notifier).loadCotizaciones(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          search: _searchFilter,
          origen: _origenFilter,
          startDate: _fechaDesde,
          endDate: _fechaHasta,
          forceRefresh: true,
        );
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
  }

  /// Abre el formulario de nueva cotización (hoja inferior).
  /// Si se creó, limpia los filtros y recarga para que se vea la nueva
  /// cotización arriba del listado.
  Future<void> showCreateDialog() async {
    final creada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: CrearCotizacionForm(),
      ),
    );

    if (creada == true && mounted) {
      _limpiarFiltros();
    }
  }

  /// Abre el formulario en modo edición con la cotización ya cargada.
  /// Si se guardó (total o parcialmente) recarga el listado conservando la
  /// página y los filtros actuales.
  Future<void> _editarCotizacion(CotizacionEntity cotizacion) async {
    final guardada = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: CrearCotizacionForm(cotizacionId: cotizacion.cotizacionId),
      ),
    );

    if (guardada == true && mounted) {
      _loadData();
    }
  }

  /// Modal de confirmación antes de eliminar
  void _showDeleteDialog(CotizacionEntity cotizacion) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Cotización'),
        content: Text(
          '¿Está seguro de eliminar la cotización ${cotizacion.numeroCotizacion} '
          'de ${cotizacion.consumidorNombre}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarCotizacion(cotizacion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarCotizacion(CotizacionEntity cotizacion) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final unicaEnPagina =
        (ref.read(cotizacionesProvider).data?.cotizaciones.length ?? 0) == 1;

    final error =
        await ref.read(cotizacionesProvider.notifier).eliminarCotizacion(
              clienteId: user.clienteId,
              cotizacionId: cotizacion.cotizacionId,
            );

    if (!mounted) return;

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Si era la única de la página (y no es la primera), retrocede una página
    if (unicaEnPagina && _currentPage > 1) {
      setState(() => _currentPage--);
    }
    _loadData();

    messenger.showSnackBar(
      SnackBar(
        content: Text('Cotización ${cotizacion.numeroCotizacion} eliminada'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ===========================================================================
  // FILTROS
  // ===========================================================================

  bool get _tieneFiltrosActivos =>
      _searchController.text.isNotEmpty ||
      _searchFilter != null ||
      _origenFilter != CotizacionOrigen.defaultOrigen ||
      _fechaDesde != null ||
      _fechaHasta != null;

  /// Búsqueda con debounce: solo consulta con 3 o más caracteres.
  /// Si el texto baja de 3 caracteres y había búsqueda activa, la quita.
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
      _origenFilter = CotizacionOrigen.defaultOrigen;
      _fechaDesde = null;
      _fechaHasta = null;
      _currentPage = 1;
    });
    _loadData();
  }

  /// Selecciona fecha inicio o fin validando que inicio <= fin
  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final actual = esInicio ? _fechaDesde : _fechaHasta;

    final picked = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null || !mounted) return;

    final inicio = esInicio ? picked : _fechaDesde;
    final fin = esInicio ? _fechaHasta : picked;

    if (inicio != null && fin != null && inicio.isAfter(fin)) {
      _showFechaInvalidaDialog();
      return;
    }

    setState(() {
      if (esInicio) {
        _fechaDesde = picked;
      } else {
        _fechaHasta = picked;
      }
      _currentPage = 1;
    });
    _loadData();
  }

  void _quitarFecha({required bool esInicio}) {
    setState(() {
      if (esInicio) {
        _fechaDesde = null;
      } else {
        _fechaHasta = null;
      }
      _currentPage = 1;
    });
    _loadData();
  }

  /// Muestra un diálogo informando que la fecha inicio debe ser <= fecha fin
  void _showFechaInvalidaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rango de fechas inválido'),
        content: const Text(
          'La fecha de inicio debe ser menor o igual a la fecha fin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildFechaField({
    required String label,
    required DateTime? fecha,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          filled: true,
          fillColor: AppColors.white,
          suffixIcon: fecha != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today),
        ),
        child: Text(
          fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Todas',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: fecha != null ? AppColors.textPrimary : AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
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
              labelText: 'Buscar cotización',
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

          // Filtro por origen (uno u otro)
          DropdownButtonFormField<String>(
            // La key reconstruye el campo cuando el filtro cambia por fuera
            // (ej. "Limpiar filtros"), porque initialValue solo se lee al crearlo
            key: ValueKey(_origenFilter),
            initialValue: _origenFilter,
            decoration: InputDecoration(
              labelText: 'Origen',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
            items: const [
              DropdownMenuItem<String>(
                value: CotizacionOrigen.posInterno,
                child: Text('POS interno'),
              ),
              DropdownMenuItem<String>(
                value: CotizacionOrigen.webPublica,
                child: Text('Web pública'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _origenFilter = value;
                _currentPage = 1;
              });
              _loadData();
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Filtro de fechas (inicio y fin)
          Row(
            children: [
              Expanded(
                child: _buildFechaField(
                  label: 'Fecha inicio',
                  fecha: _fechaDesde,
                  onTap: () => _seleccionarFecha(esInicio: true),
                  onClear: () => _quitarFecha(esInicio: true),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildFechaField(
                  label: 'Fecha fin',
                  fecha: _fechaHasta,
                  onTap: () => _seleccionarFecha(esInicio: false),
                  onClear: () => _quitarFecha(esInicio: false),
                ),
              ),
            ],
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
    final cotizacionesState = ref.watch(cotizacionesProvider);
    final data = cotizacionesState.data;

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

                // Lista de cotizaciones o estados (loading/error/empty)
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: cotizacionesState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : cotizacionesState.error != null && data == null
                          ? Center(
                              child: Text(
                                cotizacionesState.error!,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )
                          : data == null || data.cotizaciones.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay cotizaciones',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Column(
                                      children: data.cotizaciones.map((cotizacion) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                                          child: _CotizacionCard(
                                            cotizacion: cotizacion,
                                            onEdit: () => _editarCotizacion(cotizacion),
                                            onDelete: () => _showDeleteDialog(cotizacion),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    // Indicador de loading para paginación (no bloquea UI)
                                    if (cotizacionesState.isLoadingMore)
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
        title: const Text('Cotizaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showCreateDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada cotización
class _CotizacionCard extends StatelessWidget {
  final CotizacionEntity cotizacion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CotizacionCard({
    required this.cotizacion,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
  }

  /// Texto de vigencia según los días de validez
  String? _vigenciaText() {
    if (cotizacion.estaVencida) return null;
    if (cotizacion.diasValidez <= 0) return 'Vence hoy';
    if (cotizacion.diasValidez == 1) return '1 día restante';
    return '${cotizacion.diasValidez} días restantes';
  }

  @override
  Widget build(BuildContext context) {
    final isVencida = cotizacion.estaVencida;
    final vigencia = _vigenciaText();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CotizacionDetalleScreen(
                cotizacionId: cotizacion.cotizacionId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número de cotización + etiqueta vencida
            Row(
              children: [
                Text(
                  cotizacion.numeroCotizacion,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                if (isVencida)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'VENCIDA',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // Consumidor
            Text(
              cotizacion.consumidorNombre,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            if (cotizacion.consumidorIdentificacion != null &&
                cotizacion.consumidorIdentificacion!.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'ID: ${cotizacion.consumidorIdentificacion}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            if (cotizacion.consumidorTelefono != null &&
                cotizacion.consumidorTelefono!.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'Tel: ${cotizacion.consumidorTelefono}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // Fechas y total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: ${_formatDate(cotizacion.fechaCotizacion)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Válida hasta: ${_formatDate(cotizacion.fechaValidez)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isVencida ? AppColors.danger : AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (vigencia != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        vigencia,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _formatCurrency(cotizacion.total),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16.sp),
                  label: const Text('Editar'),
                  onPressed: onEdit,
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  icon: Icon(Icons.delete, size: 16.sp),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
