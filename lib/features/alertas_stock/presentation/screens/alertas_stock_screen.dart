import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movimientos/presentation/widgets/producto_autocomplete_widget.dart';
import '../../domain/entities/alerta_stock_entity.dart';
import '../providers/alertas_stock_provider.dart';

class AlertasStockScreen extends ConsumerStatefulWidget {
  const AlertasStockScreen({super.key});

  @override
  ConsumerState<AlertasStockScreen> createState() =>
      _AlertasStockScreenState();
}

class _AlertasStockScreenState extends ConsumerState<AlertasStockScreen> {
  int _currentPage = 1;

  // Filtro de producto
  final TextEditingController _productoSearchController = TextEditingController();
  Producto? _productoSeleccionado;

  // Control de scroll
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    // Listener para mostrar/ocultar botón de scroll to top
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });

    // Cargar alertas al iniciar
    Future.microtask(() {
      _loadData();
    });
  }

  @override
  void dispose() {
    _productoSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final currentUser = ref.read(currentUserProvider);
    final clienteId = currentUser?.clienteId ?? 0;
    if (clienteId > 0) {
      ref.read(alertasStockProvider(clienteId).notifier).fetchAlertas(
            pageNumber: _currentPage,
            productoId: _productoSeleccionado?.productoId,
          );
    }
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
  }

  void _limpiarFiltro() {
    setState(() {
      _productoSeleccionado = null;
      _productoSearchController.clear();
      _currentPage = 1;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final clienteId = currentUser?.clienteId ?? 0;
    final state = ref.watch(alertasStockProvider(clienteId));

    return _buildBody(state, clienteId);
  }

  Widget _buildBody(AlertasStockState state, int clienteId) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () {
            setState(() {
              _currentPage = 1;
            });
            _loadData();
            return Future.value();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
        // Filtro de producto
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, size: 20.sp, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Filtrar por producto',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  if (_productoSeleccionado != null)
                    TextButton.icon(
                      onPressed: _limpiarFiltro,
                      icon: Icon(Icons.clear, size: 16.sp),
                      label: const Text('Limpiar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ProductoAutocompleteWidget(
                clienteId: clienteId,
                controller: _productoSearchController,
                selectedProducto: _productoSeleccionado,
                onProductoSelected: (producto) {
                  setState(() {
                    _productoSeleccionado = producto;
                    _currentPage = 1;
                  });
                  _loadData();
                },
                onClear: _limpiarFiltro,
                primaryColor: AppColors.warning,
                hintText: 'Buscar producto por nombre o código...',
              ),
            ],
          ),
        ),
        // Lista de alertas
        if (state.isLoading && state.alertas.isEmpty)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          )
        else if (state.error != null && state.alertas.isEmpty)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64.sp, color: AppColors.danger),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Error al cargar alertas',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    state.error!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(alertasStockProvider(clienteId).notifier)
                          .refresh();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (state.alertas.isEmpty)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _productoSeleccionado != null
                        ? Icons.search_off
                        : Icons.check_circle_outline,
                    size: 64.sp,
                    color: _productoSeleccionado != null
                        ? AppColors.grey400
                        : AppColors.success,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    _productoSeleccionado != null
                        ? 'No hay alertas para este producto'
                        : 'No hay alertas de stock',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    _productoSeleccionado != null
                        ? 'El producto "${_productoSeleccionado!.nombre}" tiene stock suficiente'
                        : 'Todos tus productos tienen stock suficiente',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          // Lista de alertas como Column
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                ...state.alertas.map((alerta) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: _AlertaStockCard(alerta: alerta),
                    )),
              ],
            ),
          ),
        // Paginación en la parte inferior
        if (state.totalElement > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              border: Border(
                top: BorderSide(
                  color: AppColors.grey300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Anterior
                TextButton.icon(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _loadData();
                        }
                      : null,
                  icon: Icon(Icons.chevron_left, size: 20.sp),
                  label: Text(
                    'Anterior',
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _currentPage > 1
                        ? AppColors.primary
                        : AppColors.grey400,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
                // Información de página
                Text(
                  'Página $_currentPage de ${(state.totalElement / state.pageSize).ceil()}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                // Botón Siguiente
                TextButton.icon(
                  onPressed: state.hasMoreElements
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _loadData();
                        }
                      : null,
                  label: Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                  ),
                  icon: Icon(Icons.chevron_right, size: 20.sp),
                  style: TextButton.styleFrom(
                    foregroundColor: state.hasMoreElements
                        ? AppColors.primary
                        : AppColors.grey400,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
        // Espaciado al final para que no quede pegado al fondo
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
              borderRadius: BorderRadius.circular(28.w),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(28.w),
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppColors.white,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertaStockCard extends StatelessWidget {
  final AlertaStockEntity alerta;

  const _AlertaStockCard({required this.alerta});

  Color _getSeverityColor() {
    if (alerta.stockActual == 0) {
      return AppColors.danger;
    } else if (alerta.porcentajeStock != null && alerta.porcentajeStock! < 25) {
      return AppColors.warning;
    }
    return AppColors.info;
  }

  String _getSeverityLabel() {
    if (alerta.stockActual == 0) {
      return 'SIN STOCK';
    } else if (alerta.porcentajeStock != null && alerta.porcentajeStock! < 25) {
      return 'STOCK BAJO';
    }
    return 'ALERTA';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final severityColor = _getSeverityColor();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre del producto y severity badge
          Row(
            children: [
              // Indicador de severidad
              Container(
                width: 4.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12.w),
              // Nombre del producto y badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.nombreProducto,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getSeverityLabel(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Stock info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StockInfo(
                  label: 'Stock Actual',
                  value: '${alerta.stockActual}',
                  color: severityColor,
                ),
                Container(
                  width: 1,
                  height: 30.h,
                  color: AppColors.grey300,
                ),
                _StockInfo(
                  label: 'Stock Mínimo',
                  value: '${alerta.stockMinimo}',
                  color: AppColors.textSecondary,
                ),
                if (alerta.porcentajeStock != null) ...[
                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.grey300,
                  ),
                  _StockInfo(
                    label: 'Porcentaje',
                    value: '${alerta.porcentajeStock!.toStringAsFixed(1)}%',
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: 6.w),
                  Text(
                    'Alerta: ${dateFormat.format(alerta.fechaAlerta)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${alerta.diasEnAlerta} días',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StockInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
