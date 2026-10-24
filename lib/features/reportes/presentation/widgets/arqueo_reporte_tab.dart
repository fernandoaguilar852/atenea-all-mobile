import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../providers/reportes_provider.dart';

class ArqueoReporteTab extends ConsumerStatefulWidget {
  const ArqueoReporteTab({super.key});

  @override
  ConsumerState<ArqueoReporteTab> createState() => _ArqueoReporteTabState();
}

class _ArqueoReporteTabState extends ConsumerState<ArqueoReporteTab> {
  DateTime? _startDate;
  DateTime? _endDate;

  // Filtros opcionales
  bool _showAdvancedFilters = false;
  String? _tipoPagoFilter;

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
    ref.read(arqueoReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          tipoPago: _tipoPagoFilter,
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
    final reporteState = ref.watch(arqueoReporteProvider);
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
                DropdownButtonFormField<String>(
                  value: _tipoPagoFilter,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Pago',
                    hintText: 'Seleccionar tipo de pago',
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
                      value: 'CAJA',
                      child: Text('CAJA'),
                    ),
                    DropdownMenuItem(
                      value: 'BANCO',
                      child: Text('BANCO'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoPagoFilter = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: reporteState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reporteState.error != null
                  ? Center(child: Text(reporteState.error!))
                  : reporte == null
                      ? const Center(child: Text('No hay datos'))
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CAJA',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _ArqueoCard(
                                saldoInicial: reporte.reporteArqueo.caja.saldoInicial,
                                totalIngresos: reporte.reporteArqueo.caja.totalIngresos,
                                totalEgresos: reporte.reporteArqueo.caja.totalEgresos,
                                saldoFinal: reporte.reporteArqueo.caja.saldoFinal,
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'BANCO',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _ArqueoCard(
                                saldoInicial: reporte.reporteArqueo.banco.saldoInicial,
                                totalIngresos: reporte.reporteArqueo.banco.totalIngresos,
                                totalEgresos: reporte.reporteArqueo.banco.totalEgresos,
                                saldoFinal: reporte.reporteArqueo.banco.saldoFinal,
                              ),
                              SizedBox(height: 20.h),
                              Card(
                                color: AppColors.success.withValues(alpha: 0.1),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TOTAL GENERAL',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(
                                            reporte.resumen.totalGeneral),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }
}

class _ArqueoCard extends StatelessWidget {
  final double saldoInicial;
  final double totalIngresos;
  final double totalEgresos;
  final double saldoFinal;

  const _ArqueoCard({
    required this.saldoInicial,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.saldoFinal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _ArqueoRow('Saldo Inicial', saldoInicial, AppColors.grey600),
            Divider(height: 16.h),
            _ArqueoRow('Ingresos', totalIngresos, AppColors.success),
            Divider(height: 16.h),
            _ArqueoRow('Egresos', totalEgresos, AppColors.danger),
            Divider(height: 16.h),
            _ArqueoRow('Saldo Final', saldoFinal, AppColors.primary,
                isBold: true),
          ],
        ),
      ),
    );
  }
}

class _ArqueoRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;

  const _ArqueoRow(
    this.label,
    this.value,
    this.color, {
    this.isBold = false,
  });

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
