import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/tipo_producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../providers/reportes_provider.dart';
import '../../domain/entities/stock_entity.dart';

class StockReporteTab extends ConsumerStatefulWidget {
  const StockReporteTab({super.key});

  @override
  ConsumerState<StockReporteTab> createState() => _StockReporteTabState();
}

class _StockReporteTabState extends ConsumerState<StockReporteTab> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool? _filtroActivo = true;

  // Filtros opcionales
  bool _showAdvancedFilters = false;
  final _nombreProductoController = TextEditingController();
  TipoProducto? _tipoProductoSelected;
  bool _stockBajo = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nombreProductoController.dispose();
    super.dispose();
  }

  void _loadData() {
    ref.read(stockReporteProvider.notifier).loadReporte(
          activo: _filtroActivo,
          nombreProducto: _nombreProductoController.text.isEmpty
              ? null
              : _nombreProductoController.text,
          stockBajo: _stockBajo ? true : null,
          tipoProductoId: _tipoProductoSelected?.tipoProductoId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
  }

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final reporteState = ref.watch(stockReporteProvider);
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
                    child: SegmentedButton<bool?>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Activos')),
                        ButtonSegment(value: false, label: Text('Inactivos')),
                        ButtonSegment(value: null, label: Text('Todos')),
                      ],
                      selected: {_filtroActivo},
                      onSelectionChanged: (Set<bool?> selection) {
                        setState(() {
                          _filtroActivo = selection.first;
                          _currentPage = 1;
                        });
                        _loadData();
                      },
                    ),
                  ),
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
                    final user = ref.watch(currentUserProvider);
                    if (user == null) return const SizedBox();

                    final tiposProductoAsync = ref.watch(tiposProductoProvider(
                      TiposProductoParams(clienteId: user.clienteId)
                    ));

                    return tiposProductoAsync.when(
                      data: (tiposProducto) => DropdownButtonFormField<TipoProducto>(
                        value: _tipoProductoSelected,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Producto',
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
                        items: tiposProducto
                            .map(
                              (tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoProductoSelected = value;
                          });
                        },
                      ),
                      loading: () => DropdownButtonFormField<TipoProducto>(
                        decoration: InputDecoration(
                          labelText: 'Tipo de Producto',
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
                      error: (error, stack) => DropdownButtonFormField<TipoProducto>(
                        decoration: InputDecoration(
                          labelText: 'Tipo de Producto',
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
                SizedBox(height: 8.h),
                CheckboxListTile(
                  title: Text(
                    'Stock Bajo',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  value: _stockBajo,
                  onChanged: (value) {
                    setState(() {
                      _stockBajo = value ?? false;
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
        if (reporte != null)
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ResumenItem(
                  label: 'Productos',
                  value: '${reporte.resumen.totalProductos}',
                ),
                _ResumenItem(
                  label: 'Stock Bajo',
                  value: '${reporte.resumen.productosConStockBajo}',
                ),
                _ResumenItem(
                  label: 'Valor',
                  value: _formatCurrency(reporte.resumen.valorTotalInventario),
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
                              child: ListTile(
                                leading: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: producto.necesitaReposicion
                                        ? AppColors.danger.withValues(alpha: 0.1)
                                        : AppColors.success.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(
                                    producto.necesitaReposicion
                                        ? Icons.warning
                                        : Icons.check_circle,
                                    color: producto.necesitaReposicion
                                        ? AppColors.danger
                                        : AppColors.success,
                                  ),
                                ),
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
                                    Text(
                                      '${producto.nombreCategoria} • ${producto.codigoBarras}',
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(
                                          'Stock: ${producto.stockActual}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                producto.necesitaReposicion
                                                    ? AppColors.danger
                                                    : AppColors.success,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '(Min: ${producto.stockMinimo})',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: AppColors.textSecondary,
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
                                      _formatCurrency(
                                          producto.valorInventario),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      producto.activo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: producto.activo
                                            ? AppColors.success
                                            : AppColors.grey400,
                                      ),
                                    ),
                                  ],
                                ),
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
