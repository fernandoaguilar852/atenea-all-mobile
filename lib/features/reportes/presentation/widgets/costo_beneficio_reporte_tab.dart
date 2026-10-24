import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/models/tipo_producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../providers/reportes_provider.dart';
import '../../domain/entities/costo_beneficio_entity.dart';

class CostoBeneficioReporteTab extends ConsumerStatefulWidget {
  const CostoBeneficioReporteTab({super.key});

  @override
  ConsumerState<CostoBeneficioReporteTab> createState() =>
      _CostoBeneficioReporteTabState();
}

class _CostoBeneficioReporteTabState
    extends ConsumerState<CostoBeneficioReporteTab> {
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
  TipoProducto? _categoriaSelected;
  bool? _activoSelected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _loadData();
  }

  @override
  void dispose() {
    _productoSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(costoBeneficioReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          productoId: _productoSelected?.productoId,
          categoriaId: _categoriaSelected?.tipoProductoId,
          activo: _activoSelected,
          pageNumber: _currentPage,
          pageSize: _pageSize,
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
      _loadData();
    }
  }

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return format.format(value);
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(costoBeneficioReporteProvider);
    final reporte = reporteState.data;

    return Column(
      children: [
        // Filtros
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.grey100,
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
                          border: Border.all(color: AppColors.grey300),
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
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadData,
                  ),
                ],
              ),
              if (_showAdvancedFilters) ...[
                SizedBox(height: 12.h),
                Consumer(
                  builder: (context, ref, child) {
                    final user = ref.watch(currentUserProvider);
                    if (user == null) return const SizedBox();

                    final tiposProductoAsync = ref.watch(tiposProductoProvider(
                      TiposProductoParams(clienteId: user.clienteId)
                    ));

                    return tiposProductoAsync.when(
                      data: (tiposProducto) => DropdownButtonFormField<TipoProducto>(
                        value: _categoriaSelected,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          hintText: 'Seleccionar categoría',
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
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                        items: tiposProducto.map((tipo) {
                          return DropdownMenuItem<TipoProducto>(
                            value: tipo,
                            child: Text(tipo.nombre),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoriaSelected = value;
                            // Si se selecciona categoría, limpiar el producto seleccionado
                            if (value != null) {
                              _productoSelected = null;
                              _productoSearchController.clear();
                              _searchTerm = '';
                            }
                          });
                        },
                      ),
                      loading: () => Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8.w),
                            Text('Cargando categorías...', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                      error: (error, stack) => Container(
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.danger),
                        ),
                        child: Text('Error al cargar categorías', style: TextStyle(fontSize: 14.sp, color: AppColors.danger)),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _productoSearchController,
                      enabled: _categoriaSelected == null,
                      onChanged: _categoriaSelected == null ? _onSearchChanged : null,
                      decoration: InputDecoration(
                        labelText: 'Buscar Producto',
                        hintText: _categoriaSelected == null
                            ? 'Escribir 3+ caracteres para buscar'
                            : 'Deshabilitado (categoría seleccionada)',
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
                        fillColor: _categoriaSelected == null
                            ? AppColors.white
                            : AppColors.grey100,
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
                                    border: Border.all(color: AppColors.grey300),
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
                                  border: Border.all(color: AppColors.grey300),
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
                                border: Border.all(color: AppColors.grey300),
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
                DropdownButtonFormField<bool?>(
                  value: _activoSelected,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    hintText: 'Seleccionar estado',
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
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
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
                      _activoSelected = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        if (reporte != null)
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResumenItem(
                      label: 'Ingresos',
                      value: _formatCurrency(reporte.resumen.totalIngresos),
                    ),
                    _ResumenItem(
                      label: 'Costos',
                      value: _formatCurrency(reporte.resumen.totalCostos),
                    ),
                    _ResumenItem(
                      label: 'Beneficio',
                      value: _formatCurrency(
                          reporte.resumen.beneficioNetoTotal),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Margen Promedio: ${_formatPercentage(reporte.resumen.margenPromedioGeneral)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: reporteState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reporteState.error != null
                  ? Center(child: Text(reporteState.error!))
                  : reporte == null || reporte.productos.isEmpty
                      ? const Center(child: Text('No hay datos'))
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: reporte.productos.length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final producto = reporte.productos[index];
                            return Card(
                              child: ExpansionTile(
                                title: Text(
                                  producto.nombreProducto,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  '${producto.nombreCategoria} • Vendidos: ${producto.cantidadVendida}',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(producto.beneficioNeto),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: producto.beneficioNeto >= 0
                                            ? AppColors.success
                                            : AppColors.danger,
                                      ),
                                    ),
                                    Text(
                                      _formatPercentage(
                                          producto.margenPorcentaje),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      children: [
                                        _DetailRow(
                                          'Ingresos',
                                          _formatCurrency(
                                              producto.ingresoTotal),
                                          AppColors.success,
                                        ),
                                        SizedBox(height: 8.h),
                                        _DetailRow(
                                          'Costos',
                                          _formatCurrency(producto.costoTotal),
                                          AppColors.danger,
                                        ),
                                        SizedBox(height: 8.h),
                                        _DetailRow(
                                          'Precio Venta Unit.',
                                          _formatCurrency(producto.precioVenta),
                                          AppColors.textPrimary,
                                        ),
                                        SizedBox(height: 8.h),
                                        _DetailRow(
                                          'Costo Unit.',
                                          _formatCurrency(
                                              producto.costoUnitario),
                                          AppColors.textPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
        if (reporte?.pagination != null)
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Página $_currentPage de ${reporte!.pagination!.totalPages}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: reporte.pagination!.hasPrevious
                          ? () {
                              setState(() => _currentPage--);
                              _loadData();
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: reporte.pagination!.hasNext
                          ? () {
                              setState(() => _currentPage++);
                              _loadData();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
