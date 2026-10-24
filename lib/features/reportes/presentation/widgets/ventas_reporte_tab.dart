import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/caja.dart';
import '../../../../core/models/tipo_producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../providers/reportes_provider.dart';

class VentasReporteTab extends ConsumerStatefulWidget {
  const VentasReporteTab({super.key});

  @override
  ConsumerState<VentasReporteTab> createState() => _VentasReporteTabState();
}

class _VentasReporteTabState extends ConsumerState<VentasReporteTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filtros opcionales
  bool _showAdvancedFilters = false;
  final _nombreProductoController = TextEditingController();
  TipoProducto? _categoriaSelected;
  Caja? _cajaSelected;
  bool _incluirAnuladas = false;

  @override
  void initState() {
    super.initState();
    // Fecha del mes actual
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _loadData();
  }

  @override
  void dispose() {
    _nombreProductoController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(ventasReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          nombreProducto: _nombreProductoController.text.isEmpty
              ? null
              : _nombreProductoController.text,
          categoriaId: _categoriaSelected?.tipoProductoId,
          cajaId: _cajaSelected?.cajaId,
          incluirAnuladas: _incluirAnuladas,
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
    final reporteState = ref.watch(ventasReporteProvider);
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
                TextField(
                  controller: _nombreProductoController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
                    hintText: 'Buscar por nombre',
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
                SizedBox(height: 8.h),
                Consumer(
                  builder: (context, ref, child) {
                    final tiposProductoAsync = ref.watch(tiposProductoProvider);

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
                Consumer(
                  builder: (context, ref, child) {
                    final cajasAsync = ref.watch(cajasProvider('abierta'));

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
                        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                        items: cajas.map((caja) {
                          return DropdownMenuItem<Caja>(
                            value: caja,
                            child: Text(caja.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _cajaSelected = value;
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
                            Text('Cargando cajas...', style: TextStyle(fontSize: 14.sp)),
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
                        child: Text('Error al cargar cajas', style: TextStyle(fontSize: 14.sp, color: AppColors.danger)),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                CheckboxListTile(
                  title: Text(
                    'Incluir ventas anuladas',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  value: _incluirAnuladas,
                  onChanged: (value) {
                    setState(() {
                      _incluirAnuladas = value ?? false;
                    });
                  },
                  tileColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    side: BorderSide(color: AppColors.grey300),
                  ),
                ),
              ],
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
                  label: 'Productos',
                  value: '${reporte.resumen.totalProductosVendidos}',
                ),
                _ResumenItem(
                  label: 'Cantidad',
                  value: '${reporte.resumen.totalCantidadVendida}',
                ),
                _ResumenItem(
                  label: 'Total',
                  value: _formatCurrency(reporte.resumen.totalVentas),
                ),
              ],
            ),
          ),

        // Tabla
        Expanded(
          child: reporteState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reporteState.error != null
                  ? Center(child: Text(reporteState.error!))
                  : reporte == null || reporte.reporteVentas.isEmpty
                      ? const Center(child: Text('No hay datos'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Código')),
                                DataColumn(label: Text('Producto')),
                                DataColumn(label: Text('Categoría')),
                                DataColumn(label: Text('Precio Unit.')),
                                DataColumn(label: Text('Cantidad')),
                                DataColumn(label: Text('Total')),
                              ],
                              rows: reporte.reporteVentas
                                  .map(
                                    (row) => DataRow(
                                      cells: [
                                        DataCell(Text(row.codigoBarras)),
                                        DataCell(
                                          SizedBox(
                                            width: 150.w,
                                            child: Text(
                                              row.nombreProducto,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(row.nombreCategoria)),
                                        DataCell(Text(
                                            _formatCurrency(row.precioVentaUnitario))),
                                        DataCell(Text('${row.cantidadVendida}')),
                                        DataCell(Text(
                                            _formatCurrency(row.totalVentas))),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
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
