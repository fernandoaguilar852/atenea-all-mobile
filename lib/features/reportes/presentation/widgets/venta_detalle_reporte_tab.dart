import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/consumidor.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

  // Filtros opcionales
  bool _showAdvancedFilters = false;
  final _consumidorSearchController = TextEditingController();
  Consumidor? _consumidorSelected;
  String _consumidorSearchTerm = '';
  Timer? _consumidorDebounce;
  final _productoSearchController = TextEditingController();
  Producto? _productoSelected;
  String _productoSearchTerm = '';
  Timer? _productoDebounce;
  String? _selectedEstado;

  @override
  void initState() {
    super.initState();
    // Fecha actual por defecto
    final now = DateTime.now();
    _startDate = now;
    _endDate = now;
    _loadData();
  }

  @override
  void dispose() {
    _consumidorSearchController.dispose();
    _consumidorDebounce?.cancel();
    _productoSearchController.dispose();
    _productoDebounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    if (_startDate == null || _endDate == null) return;

    final dateFormat = DateFormat('yyyy-MM-dd');
    ref.read(ventaDetalleReporteProvider.notifier).loadReporte(
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
          consumidorId: _consumidorSelected?.consumidorId,
          estado: _selectedEstado?.isEmpty ?? true ? null : _selectedEstado,
          productoId: _productoSelected?.productoId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
  }

  void _onConsumidorSearchChanged(String value) {
    if (_consumidorDebounce?.isActive ?? false) _consumidorDebounce!.cancel();
    _consumidorDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3) {
        setState(() {
          _consumidorSearchTerm = value;
        });
      } else {
        setState(() {
          _consumidorSearchTerm = '';
        });
      }
    });
  }

  void _onProductoSearchChanged(String value) {
    if (_productoDebounce?.isActive ?? false) _productoDebounce!.cancel();
    _productoDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 3) {
        setState(() {
          _productoSearchTerm = value;
        });
      } else {
        setState(() {
          _productoSearchTerm = '';
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
                _buildConsumidorAutocomplete(),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEstado,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Estado'),
                          ),
                          const DropdownMenuItem(
                            value: 'pagada',
                            child: Text('Pagada'),
                          ),
                          const DropdownMenuItem(
                            value: 'anulada',
                            child: Text('Anulada'),
                          ),
                          const DropdownMenuItem(
                            value: 'pendiente',
                            child: Text('Pendiente'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEstado = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Estado',
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _buildProductoAutocomplete(),
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

  Widget _buildConsumidorAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _consumidorSearchController,
          onChanged: _onConsumidorSearchChanged,
          decoration: InputDecoration(
            labelText: 'Buscar Consumidor',
            hintText: 'Escribir 3+ caracteres para buscar',
            prefixIcon: _consumidorSelected != null
                ? IconButton(
                    icon: Icon(Icons.clear, size: 20.sp),
                    onPressed: () {
                      setState(() {
                        _consumidorSelected = null;
                        _consumidorSearchController.clear();
                        _consumidorSearchTerm = '';
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
        if (_consumidorSelected != null)
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
                    'Seleccionado: ${_consumidorSelected!.displayName}',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        if (_consumidorSearchTerm.isNotEmpty && _consumidorSelected == null)
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);
              if (user == null) return const SizedBox();

              final consumidoresAsync = ref.watch(consumidoresSearchProvider(
                ConsumidoresSearchParams(clienteId: user.clienteId, searchTerm: _consumidorSearchTerm)
              ));

              return consumidoresAsync.when(
                data: (consumidores) {
                  if (consumidores.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Text(
                        'No se encontraron consumidores',
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
                      itemCount: consumidores.length,
                      separatorBuilder: (context, index) => Divider(height: 1.h),
                      itemBuilder: (context, index) {
                        final consumidor = consumidores[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            consumidor.nombreRazonSocial,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          subtitle: Text(
                            'ID: ${consumidor.consumidorId} - ${consumidor.numeroIdentificacion}',
                            style: TextStyle(fontSize: 11.sp),
                          ),
                          onTap: () {
                            setState(() {
                              _consumidorSelected = consumidor;
                              _consumidorSearchController.text = consumidor.nombreRazonSocial;
                              _consumidorSearchTerm = '';
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
                        'Buscando consumidores...',
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
                    'Error al buscar consumidores',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.danger),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductoAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _productoSearchController,
          onChanged: _onProductoSearchChanged,
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
                        _productoSearchTerm = '';
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
        if (_productoSearchTerm.isNotEmpty && _productoSelected == null)
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);
              if (user == null) return const SizedBox();

              final productosAsync = ref.watch(productosSearchProvider(
                ProductosSearchParams(clienteId: user.clienteId, searchTerm: _productoSearchTerm)
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
                              _productoSearchTerm = '';
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
