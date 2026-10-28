import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/models/proveedor.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../providers/movimientos_provider.dart';
import '../widgets/entrada_form_widget.dart';
import '../widgets/salida_form_widget.dart';
import '../widgets/ingreso_form_widget.dart';
import '../widgets/egreso_form_widget.dart';
import '../widgets/producto_autocomplete_widget.dart';

class MovimientosScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const MovimientosScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends ConsumerState<MovimientosScreen> {
  int _currentPage = 1;
  final int _pageSize = 20;

  // Filtros
  TipoMovimiento? _tipoFilter;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  Producto? _productoFilter;
  Proveedor? _proveedorFilter;

  // Controllers para búsqueda
  final _productoSearchController = TextEditingController();
  final _proveedorSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _productoSearchController.dispose();
    _proveedorSearchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(movimientosProvider.notifier).loadMovimientos(
          clienteId: user.clienteId,
          tipo: _tipoFilter,
          fechaDesde: _fechaDesde,
          fechaHasta: _fechaHasta,
          productoId: _productoFilter?.productoId,
          proveedorId: _proveedorFilter?.proveedorId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
  }

  void _showMovimientoTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tipo de Movimiento',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            _MovimientoTypeOption(
              title: 'Entrada de Productos',
              subtitle: 'Registrar compra o ingreso de inventario',
              icon: Icons.arrow_downward,
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                _showMovimientoForm(context, TipoMovimiento.entrada);
              },
            ),
            SizedBox(height: 12.h),
            _MovimientoTypeOption(
              title: 'Salida de Productos',
              subtitle: 'Registrar salida de inventario',
              icon: Icons.arrow_upward,
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                _showMovimientoForm(context, TipoMovimiento.salida);
              },
            ),
            SizedBox(height: 12.h),
            _MovimientoTypeOption(
              title: 'Ingreso de Dinero',
              subtitle: 'Registrar entrada de efectivo',
              icon: Icons.add_circle,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _showMovimientoForm(context, TipoMovimiento.ingreso);
              },
            ),
            SizedBox(height: 12.h),
            _MovimientoTypeOption(
              title: 'Egreso de Dinero',
              subtitle: 'Registrar salida de efectivo',
              icon: Icons.remove_circle,
              color: AppColors.danger,
              onTap: () {
                Navigator.pop(context);
                _showMovimientoForm(context, TipoMovimiento.egreso);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showMovimientoForm(BuildContext context, TipoMovimiento tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: switch (tipo) {
            TipoMovimiento.entrada => const EntradaFormWidget(),
            TipoMovimiento.salida => const SalidaFormWidget(),
            TipoMovimiento.ingreso => const IngresoFormWidget(),
            TipoMovimiento.egreso => const EgresoFormWidget(),
            _ => const SizedBox(),
          },
        );
      },
    ).then((_) => _loadData()); // Reload data after closing form
  }

  void _showEditDialog(MovimientoEntity movimiento) {
    final cantidadController = TextEditingController(text: movimiento.cantidad.toString());
    final observacionController = TextEditingController(text: movimiento.observacion ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Movimiento #${movimiento.movimientoId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: observacionController,
              decoration: const InputDecoration(
                labelText: 'Observación',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user == null) return;

              final cantidad = double.tryParse(cantidadController.text);
              if (cantidad == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cantidad inválida')),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();

              final success = await ref.read(movimientosProvider.notifier).patchMovimiento(
                    movimientoId: movimiento.movimientoId,
                    clienteId: user.clienteId,
                    cantidad: cantidad,
                    observacion: observacionController.text.isEmpty
                        ? null
                        : observacionController.text,
                    updatedByUsuarioId: user.usuarioId,
                  );

              if (success && mounted) {
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Movimiento actualizado correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MovimientoEntity movimiento) {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Movimiento #${movimiento.movimientoId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de eliminar este movimiento?',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de eliminación *',
                border: OutlineInputBorder(),
                hintText: 'Ej: Error en el registro',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motivoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese el motivo de eliminación')),
                );
                return;
              }

              final user = ref.read(currentUserProvider);
              if (user == null) return;

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();

              final success = await ref.read(movimientosProvider.notifier).deleteMovimiento(
                    movimientoId: movimiento.movimientoId,
                    clienteId: user.clienteId,
                    deletedByUsuarioId: user.usuarioId,
                    deleteReason: motivoController.text,
                  );

              if (success && mounted) {
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Movimiento eliminado correctamente'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movimientosState = ref.watch(movimientosProvider);
    final data = movimientosState.data;
    final user = ref.watch(currentUserProvider);

    final bodyContent = Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.grey100,
            child: Column(
              children: [
                // Filtro por tipo
                DropdownButtonFormField<TipoMovimiento>(
                  value: _tipoFilter,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Movimiento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  items: [
                    const DropdownMenuItem<TipoMovimiento>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ...TipoMovimiento.values.map((tipo) {
                      return DropdownMenuItem<TipoMovimiento>(
                        value: tipo,
                        child: Text(tipo.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoFilter = value;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
                SizedBox(height: 12.h),

                // Filtro de rango de fechas
                InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _fechaDesde != null && _fechaHasta != null
                          ? DateTimeRange(start: _fechaDesde!, end: _fechaHasta!)
                          : null,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      setState(() {
                        _fechaDesde = picked.start;
                        _fechaHasta = picked.end;
                        _currentPage = 1;
                      });
                      _loadData();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range, size: 20.sp, color: AppColors.primary),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            _fechaDesde != null && _fechaHasta != null
                                ? '${DateFormat('dd/MM/yyyy').format(_fechaDesde!)} - ${DateFormat('dd/MM/yyyy').format(_fechaHasta!)}'
                                : 'Seleccionar rango de fechas',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: _fechaDesde != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (_fechaDesde != null)
                          IconButton(
                            icon: Icon(Icons.close, size: 18.sp),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _fechaDesde = null;
                                _fechaHasta = null;
                                _currentPage = 1;
                              });
                              _loadData();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Filtro por producto (autocomplete)
                if (user != null)
                  ProductoAutocompleteWidget(
                    clienteId: user.clienteId,
                    controller: _productoSearchController,
                    selectedProducto: _productoFilter,
                    onProductoSelected: (producto) {
                      setState(() {
                        _productoFilter = producto;
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                    onClear: () {
                      setState(() {
                        _productoFilter = null;
                        _productoSearchController.clear();
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                    primaryColor: AppColors.primary,
                  ),
                SizedBox(height: 12.h),

                // Filtro por proveedor (autocomplete)
                _ProveedorAutocomplete(
                  controller: _proveedorSearchController,
                  selectedProveedor: _proveedorFilter,
                  onProveedorSelected: (proveedor) {
                    setState(() {
                      _proveedorFilter = proveedor;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                  onClear: () {
                    setState(() {
                      _proveedorFilter = null;
                      _proveedorSearchController.clear();
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
                SizedBox(height: 12.h),

                // Botón refresh
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loadData,
                  ),
                ),
              ],
            ),
          ),

          // Lista de movimientos
          Expanded(
            child: movimientosState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movimientosState.error != null
                    ? Center(
                        child: Text(
                          movimientosState.error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      )
                    : data == null || data.movimientos.isEmpty
                        ? const Center(child: Text('No hay movimientos'))
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount: data.movimientos.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final movimiento = data.movimientos[index];
                              return _MovimientoCard(
                                movimiento: movimiento,
                                onTap: () {
                                  // TODO: Implementar vista de detalle
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Ver detalle #${movimiento.movimientoId}'),
                                    ),
                                  );
                                },
                                onEdit: () => _showEditDialog(movimiento),
                                onDelete: () => _showDeleteDialog(movimiento),
                              );
                            },
                          ),
          ),

          // Paginación
          if (data?.pagination != null)
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Página $_currentPage de ${data!.pagination!.totalPages}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: data.pagination!.hasPrevious
                            ? () {
                                setState(() => _currentPage--);
                                _loadData();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: data.pagination!.hasNext
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

    if (!widget.showScaffold) {
      return bodyContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMovimientoTypeSelector(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada movimiento
class _MovimientoCard extends StatelessWidget {
  final MovimientoEntity movimiento;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MovimientoCard({
    required this.movimiento,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return format.format(value);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movimiento.nombreProducto ?? 'Producto #${movimiento.productoId}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getTipoColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                movimiento.tipo.displayName,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _getTipoColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatDate(movimiento.fecha),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(movimiento.total),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Cant: ${movimiento.cantidad}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (movimiento.observacion != null) ...[
                SizedBox(height: 8.h),
                Text(
                  movimiento.observacion!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.edit, size: 16.sp),
                    label: const Text('Editar'),
                    onPressed: onEdit,
                  ),
                  SizedBox(width: 8.w),
                  TextButton.icon(
                    icon: Icon(Icons.delete, size: 16.sp),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTipoColor() {
    switch (movimiento.tipo) {
      case TipoMovimiento.entrada:
      case TipoMovimiento.ingreso:
        return AppColors.success;
      case TipoMovimiento.salida:
      case TipoMovimiento.egreso:
        return AppColors.danger;
      case TipoMovimiento.venta:
        return AppColors.primary;
    }
  }
}

/// Opción de tipo de movimiento en el selector
class _MovimientoTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MovimientoTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de autocomplete para filtrar por proveedor
class _ProveedorAutocomplete extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Proveedor? selectedProveedor;
  final Function(Proveedor) onProveedorSelected;
  final VoidCallback onClear;

  const _ProveedorAutocomplete({
    required this.controller,
    required this.selectedProveedor,
    required this.onProveedorSelected,
    required this.onClear,
  });

  @override
  ConsumerState<_ProveedorAutocomplete> createState() => _ProveedorAutocompleteState();
}

class _ProveedorAutocompleteState extends ConsumerState<_ProveedorAutocomplete> {
  String _searchTerm = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Filtrar por Proveedor',
            hintText: 'Buscar proveedor...',
            prefixIcon: Icon(Icons.business, color: AppColors.primary),
            suffixIcon: widget.selectedProveedor != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
          onChanged: (value) {
            _onSearchChanged(value);
          },
        ),
        if (widget.selectedProveedor != null)
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
                    widget.selectedProveedor!.nombre,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_searchTerm.isNotEmpty && widget.selectedProveedor == null)
          Consumer(
            builder: (context, ref, child) {
              final proveedoresAsync = ref.watch(proveedoresSearchProvider(
                ProveedoresSearchParams(
                  clienteId: user.clienteId,
                  searchTerm: _searchTerm,
                ),
              ));

              return proveedoresAsync.when(
            data: (proveedores) {
              if (proveedores.isEmpty) {
                return Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Text(
                    'No se encontraron proveedores',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
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
                  itemCount: proveedores.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final proveedor = proveedores[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        proveedor.nombre,
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      subtitle: proveedor.nit != null
                          ? Text(
                              'NIT: ${proveedor.nit}',
                              style: TextStyle(fontSize: 11.sp),
                            )
                          : null,
                      onTap: () {
                        widget.controller.text = proveedor.nombre;
                        widget.onProveedorSelected(proveedor);
                        setState(() {
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
                'Error al buscar proveedores',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.danger,
                ),
              ),
            ),
          );
            },
          ),
      ],
    );
  }
}
