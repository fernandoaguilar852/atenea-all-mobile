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
  final _productoSearchController = TextEditingController();
  Producto? _productoSelected;
  String _searchTerm = '';
  Timer? _debounce;
  TipoProducto? _tipoProductoSelected;
  bool _stockBajo = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _productoSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    ref.read(stockReporteProvider.notifier).loadReporte(
          activo: _filtroActivo,
          productoId: _productoSelected?.productoId,
          stockBajo: _stockBajo ? true : null,
          tipoProductoId: _tipoProductoSelected?.tipoProductoId,
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
          padding: EdgeInsets.all(AppSpacing.md),
          color: AppColors.surfaceVariant,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool?>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                  if (_showAdvancedFilters)
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        setState(() {
                          _productoSearchController.clear();
                          _productoSelected = null;
                          _searchTerm = '';
                          _tipoProductoSelected = null;
                          _stockBajo = false;
                        });
                        _loadData();
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadData,
                  ),
                ],
              ),
              if (_showAdvancedFilters) ...[
                SizedBox(height: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _productoSearchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar Producto',
                        hintText: 'Escribe 3+ caracteres para buscar...',
                        prefixIcon: Icon(Icons.search, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    if (_productoSelected != null)
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _productoSelected!.nombre,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 18.sp),
                              onPressed: () {
                                setState(() {
                                  _productoSelected = null;
                                  _productoSearchController.clear();
                                  _searchTerm = '';
                                });
                                _loadData();
                              },
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: productos.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final producto = productos[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        producto.nombre,
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                      subtitle: Text(
                                        'Stock: ${producto.stockTotal}',
                                        style: TextStyle(fontSize: 11.sp),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _productoSelected = producto;
                                          _productoSearchController.text = producto.nombre;
                                          _searchTerm = '';
                                        });
                                        _loadData();
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
                                    height: 16.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Buscando...',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            error: (err, stack) => Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
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
                          padding: EdgeInsets.all(AppSpacing.md),
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
                                    if (producto.unidadMedida != null || producto.codigoBarras != null)
                                      Text(
                                        '${producto.unidadMedida ?? ''} ${producto.codigoBarras != null ? '• ${producto.codigoBarras}' : ''}',
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
                                          producto.precioVenta),
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
            padding: EdgeInsets.all(AppSpacing.md),
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
