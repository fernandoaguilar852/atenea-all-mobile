import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../providers/reportes_provider.dart';

class VentaDetalleReporteTab extends ConsumerStatefulWidget {
  const VentaDetalleReporteTab({super.key});

  @override
  ConsumerState<VentaDetalleReporteTab> createState() =>
      _VentaDetalleReporteTabState();
}

class _VentaDetalleReporteTabState
    extends ConsumerState<VentaDetalleReporteTab> {
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
    ref.read(ventaDetalleReporteProvider.notifier).loadReporte(
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

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(ventaDetalleReporteProvider);
    final reporte = reporteState.data;

    return Column(
      children: [
        // Filtros
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

        // Resumen
        if (reporte != null)
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResumenItem(
                  label: 'Ventas',
                  value: '${reporte.resumen.totalVentas}',
                ),
                _ResumenItem(
                  label: 'Subtotal',
                  value: _formatCurrency(reporte.resumen.totalSubtotal),
                ),
                _ResumenItem(
                  label: 'Total',
                  value: _formatCurrency(reporte.resumen.totalGeneral),
                ),
              ],
            ),
          ),

        // Lista de ventas
        Expanded(
          child: reporteState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reporteState.error != null
                  ? Center(child: Text(reporteState.error!))
                  : reporte == null || reporte.ventas.isEmpty
                      ? const Center(child: Text('No hay datos'))
                      : ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: reporte.ventas.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final venta = reporte.ventas[index];
                            return Card(
                              child: ExpansionTile(
                                title: Text(
                                  'Factura ${venta.numeroFactura}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venta.nombreCliente,
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(DateTime.parse(venta.fechaVenta)),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  _formatCurrency(venta.total),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: AppColors.success,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      children: venta.detalles
                                          .map(
                                            (det) => Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.h),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${det.cantidad}x ${det.nombreProducto}',
                                                      style: TextStyle(
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatCurrency(det.total),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),

        // Paginación
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
