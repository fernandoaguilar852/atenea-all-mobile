import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../providers/cotizaciones_provider.dart';

class CotizacionesScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const CotizacionesScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<CotizacionesScreen> createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends ConsumerState<CotizacionesScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;

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
          forceRefresh: true,
        );
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
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
                                          child: _CotizacionCard(cotizacion: cotizacion),
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
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada cotización
class _CotizacionCard extends StatelessWidget {
  final CotizacionEntity cotizacion;

  const _CotizacionCard({required this.cotizacion});

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
            SizedBox(height: 2.h),
            Text(
              'ID: ${cotizacion.consumidorIdentificacion}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
