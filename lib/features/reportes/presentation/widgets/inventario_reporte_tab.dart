import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/reportes_provider.dart';

class InventarioReporteTab extends ConsumerStatefulWidget {
  const InventarioReporteTab({super.key});

  @override
  ConsumerState<InventarioReporteTab> createState() =>
      _InventarioReporteTabState();
}

class _InventarioReporteTabState extends ConsumerState<InventarioReporteTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filtros opcionales
  bool _showAdvancedFilters = false;
  final _productoSearchController = TextEditingController();
  Producto? _productoSelected;
  String _searchTerm = '';
  Timer? _debounce;
  String? _tipoMovimientoSelected;

  // Control de scroll
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Fecha actual por defecto
    final now = DateTime.now();
    _startDate = now;
    _endDate = now;
    // NO cargar datos automáticamente - esperar a que el usuario haga click en Consultar

    // Listener para mostrar/ocultar botón de scroll to top
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _productoSearchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(inventarioReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          productoId: _productoSelected?.productoId,
          tipoMovimiento: _tipoMovimientoSelected,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
  }

  /// Valida que el rango de fechas no supere los 60 días
  bool _validateDateRange() {
    if (_startDate == null || _endDate == null) return false;

    final difference = _endDate!.difference(_startDate!).inDays;
    return difference <= 60;
  }

  /// Muestra un diálogo informando que el rango de fechas excede el límite
  void _showDateRangeExceededDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rango de fechas excedido'),
        content: const Text(
          'El intervalo entre la fecha de inicio y la fecha final no puede superar los 60 días.',
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

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3) {
        setState(() {
          _searchTerm = value;
        });
      } else {
        setState(() {
          _searchTerm = '';
        });
      }
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _currentPage = 1;
      });
      // NO llamar a _loadData automáticamente - esperar al botón Consultar
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(inventarioReporteProvider);
    final reporte = reporteState.data;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
        // Filtros
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          color: AppColors.surfaceVariant,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _startDate != null && _endDate != null
                                    ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                    : 'Seleccionar rango',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(_showAdvancedFilters
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined),
                    onPressed: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                  ),
                  if (_showAdvancedFilters)
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        setState(() {
                          _productoSelected = null;
                          _productoSearchController.clear();
                          _searchTerm = '';
                          _tipoMovimientoSelected = null;
                        });
                        // NO cargar automáticamente - esperar botón Consultar
                      },
                    ),
                ],
              ),
              if (_showAdvancedFilters) ...[
                SizedBox(height: 12.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _productoSearchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        labelText: 'Buscar Producto',
                        hintText: 'Escribir 3+ caracteres para buscar',
                        prefixIcon: _productoSelected != null
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20.sp),
                                onPressed: () {
                                  setState(() {
                                    _productoSelected = null;
                                    _productoSearchController.clear();
                                    _searchTerm = '';
                                  });
                                },
                              )
                            : Icon(Icons.search, size: 20.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    if (_productoSelected != null)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16.sp, color: AppColors.primary),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Seleccionado: ${_productoSelected!.displayName}',
                                style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_searchTerm.isNotEmpty && _productoSelected == null)
                      Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(currentUserProvider);
                          if (user == null) return const SizedBox();

                          final productosAsync = ref.watch(productosSearchProvider(
                            ProductosSearchParams(clienteId: user.clienteId, searchTerm: _searchTerm)
                          ));

                          return productosAsync.when(
                            data: (productos) {
                              if (productos.isEmpty) {
                                return Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(color: AppColors.borderColor),
                                  ),
                                  child: Text(
                                    'No se encontraron productos',
                                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                                  ),
                                );
                              }

                              return Container(
                                margin: EdgeInsets.only(top: 4.h),
                                constraints: BoxConstraints(maxHeight: 200.h),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: productos.length,
                                  separatorBuilder: (context, index) => Divider(height: 1.h),
                                  itemBuilder: (context, index) {
                                    final producto = productos[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        producto.nombre,
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                      subtitle: Text(
                                        'ID: ${producto.productoId} - \$${producto.precio.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 11.sp),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _productoSelected = producto;
                                          _productoSearchController.text = producto.nombre;
                                          _searchTerm = '';
                                        });
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Buscando productos...',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            error: (error, stack) => Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: AppColors.danger),
                              ),
                              child: Text(
                                'Error al buscar productos',
                                style: TextStyle(fontSize: 12.sp, color: AppColors.danger),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _tipoMovimientoSelected,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Movimiento',
                    hintText: 'Seleccionar tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'venta',
                      child: Text('Venta'),
                    ),
                    DropdownMenuItem(
                      value: 'salida',
                      child: Text('Salida'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoMovimientoSelected = value;
                    });
                  },
                ),
              ],
              // Botón Consultar - siempre al final de los filtros
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Validar rango de fechas
                    if (!_validateDateRange()) {
                      _showDateRangeExceededDialog();
                      return;
                    }

                    setState(() => _currentPage = 1);
                    // Limpiar cache antes de consultar para garantizar datos frescos
                    await ref.read(inventarioReporteProvider.notifier).clearCache();
                    _loadData();
                  },
                  icon: const Icon(Icons.search, size: 22),
                  label: Text(
                    'Consultar Reporte',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (reporte != null)
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResumenItem(
                  label: 'Productos',
                  value: '${reporte.resumen.totalProductos}',
                ),
                _ResumenItem(
                  label: 'Movimientos',
                  value: '${reporte.resumen.totalMovimientos ?? 0}',
                ),
                _ResumenItem(
                  label: 'Stock Bajo',
                  value: '${reporte.resumen.productosConStockBajo}',
                ),
              ],
            ),
          ),
        if (reporteState.isLoading)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          )
        else if (reporteState.error != null)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: Text(reporteState.error!),
          )
        else if (reporte == null || reporte.productos.isEmpty)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: const Text('No hay datos'),
          )
        else
          ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(AppSpacing.md),
                          itemCount: reporte.productos.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final producto = reporte.productos[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  producto.nombreProducto,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (producto.unidadMedida != null)
                                      Text(
                                        producto.unidadMedida!,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(
                                          'Consumido: ${producto.cantidadConsumida}',
                                          style: TextStyle(fontSize: 11.sp),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          'Stock: ${producto.stockActual}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: producto.necesitaReposicion
                                                ? AppColors.danger
                                                : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Min: ${producto.stockMinimo}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    if (producto.necesitaReposicion)
                                      Text(
                                        'Reponer',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

        if (reporte?.pagination != null)
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
                  onPressed: reporte!.pagination!.hasPrevious
                      ? () {
                          setState(() => _currentPage--);
                          _loadData();
                        }
                      : null,
                  icon: Icon(Icons.chevron_left, size: 20.sp),
                  label: Text(
                    'Anterior',
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: reporte.pagination!.hasPrevious
                        ? AppColors.primary
                        : AppColors.grey400,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
                // Información de página
                Text(
                  'Página $_currentPage de ${reporte.pagination!.totalPages}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                // Botón Siguiente
                TextButton.icon(
                  onPressed: reporte.pagination!.hasNext
                      ? () {
                          setState(() => _currentPage++);
                          _loadData();
                        }
                      : null,
                  label: Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                  ),
                  icon: Icon(Icons.chevron_right, size: 20.sp),
                  style: TextButton.styleFrom(
                    foregroundColor: reporte.pagination!.hasNext
                        ? AppColors.primary
                        : AppColors.grey400,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
        // Espaciado al final
        SizedBox(height: 80.h),
            ],
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

class _ResumenItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResumenItem({
    required this.label,
    required this.value,
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
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
