import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/caja.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/reportes_provider.dart';

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
  Caja? _cajaSelected;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(arqueoReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          tipoPago: _tipoPagoFilter,
          cajaId: _cajaSelected?.cajaId,
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
      // NO llamar a _loadData automáticamente - esperar al botón Consultar
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
                          _tipoPagoFilter = null;
                          _cajaSelected = null;
                        });
                        // NO cargar automáticamente - esperar botón Consultar
                      },
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
                SizedBox(height: 8.h),
                Consumer(
                  builder: (context, ref, child) {
                    final user = ref.watch(currentUserProvider);
                    if (user == null) return const SizedBox();

                    final cajasAsync = ref.watch(cajasProvider(
                      CajasParams(clienteId: user.clienteId, estado: null)
                    ));

                    return cajasAsync.when(
                      data: (cajas) => DropdownButtonFormField<Caja>(
                        value: _cajaSelected,
                        decoration: InputDecoration(
                          labelText: 'Caja',
                          hintText: 'Seleccionar caja',
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
                        items: cajas
                            .map(
                              (caja) => DropdownMenuItem(
                                value: caja,
                                child: Text(caja.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _cajaSelected = value;
                          });
                        },
                      ),
                      loading: () => DropdownButtonFormField<Caja>(
                        decoration: InputDecoration(
                          labelText: 'Caja',
                          hintText: 'Cargando...',
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
                        items: const [],
                        onChanged: null,
                      ),
                      error: (error, stack) => DropdownButtonFormField<Caja>(
                        decoration: InputDecoration(
                          labelText: 'Caja',
                          hintText: 'Error al cargar',
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
                        items: const [],
                        onChanged: null,
                      ),
                    );
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

                    // Limpiar cache antes de consultar para garantizar datos frescos
                    await ref.read(arqueoReporteProvider.notifier).clearCache();
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
        else if (reporte == null)
          Container(
            height: 400.h,
            alignment: Alignment.center,
            child: const Text('No hay datos'),
          )
        else
          Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
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
                                total: reporte.reporteArqueo.caja.total,
                                numeroTransacciones: reporte.reporteArqueo.caja.numeroTransacciones,
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
                                total: reporte.reporteArqueo.banco.total,
                                numeroTransacciones: reporte.reporteArqueo.banco.numeroTransacciones,
                              ),
                              SizedBox(height: 20.h),
                              Card(
                                color: AppColors.success.withValues(alpha: 0.1),
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
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

class _ArqueoCard extends StatelessWidget {
  final double total;
  final int numeroTransacciones;

  const _ArqueoCard({
    required this.total,
    required this.numeroTransacciones,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _ArqueoRow('Total', total, AppColors.primary, isBold: true),
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transacciones',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$numeroTransacciones',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
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
