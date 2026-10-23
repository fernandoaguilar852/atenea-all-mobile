import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../providers/reportes_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _loadData();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(costoBeneficioReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
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
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.grey100,
          child: Row(
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
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
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
