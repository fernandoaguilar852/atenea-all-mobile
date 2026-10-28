import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../providers/movimientos_provider.dart';
import 'producto_autocomplete_widget.dart';

/// Representa una línea de entrada antes de ser guardada
class EntradaLineItem {
  final Producto producto;
  final double cantidad;
  final double costo;
  final double impuesto;
  final double descuento;
  final String? observacion;

  EntradaLineItem({
    required this.producto,
    required this.cantidad,
    required this.costo,
    required this.impuesto,
    required this.descuento,
    this.observacion,
  });

  double get total => (costo + impuesto - descuento) * cantidad;
}

/// Formulario para ENTRADA de productos (Compras)
/// Color: Verde - Representa entrada de inventario
/// PERMITE AGREGAR MÚLTIPLES LÍNEAS DE PRODUCTOS
class EntradaFormWidget extends ConsumerStatefulWidget {
  const EntradaFormWidget({super.key});

  @override
  ConsumerState<EntradaFormWidget> createState() => _EntradaFormWidgetState();
}

class _EntradaFormWidgetState extends ConsumerState<EntradaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _costoController = TextEditingController();
  final _impuestoController = TextEditingController();
  final _descuentoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _observacionController = TextEditingController();
  final _productoSearchController = TextEditingController();

  Producto? _productoSelected;
  int? _proveedorId;
  bool _isLoading = false;

  // Lista de líneas agregadas
  final List<EntradaLineItem> _lineasEntrada = [];

  @override
  void initState() {
    super.initState();
    // Valores por defecto
    _impuestoController.text = '0.00';
    _descuentoController.text = '0.00';
  }

  @override
  void dispose() {
    _costoController.dispose();
    _impuestoController.dispose();
    _descuentoController.dispose();
    _cantidadController.dispose();
    _observacionController.dispose();
    _productoSearchController.dispose();
    super.dispose();
  }

  /// Agregar línea a la lista
  void _addLineItem() {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto')),
      );
      return;
    }

    final lineItem = EntradaLineItem(
      producto: _productoSelected!,
      cantidad: double.parse(_cantidadController.text),
      costo: double.parse(_costoController.text),
      impuesto: double.parse(_impuestoController.text),
      descuento: double.parse(_descuentoController.text),
      observacion: _observacionController.text.isEmpty
          ? null
          : _observacionController.text,
    );

    setState(() {
      _lineasEntrada.add(lineItem);
      // Limpiar formulario
      _productoSelected = null;
      _productoSearchController.clear();
      _cantidadController.clear();
      _costoController.clear();
      _impuestoController.text = '0.00';
      _descuentoController.text = '0.00';
      _observacionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lineItem.producto.nombre} agregado a la lista'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Eliminar línea de la lista
  void _removeLineItem(int index) {
    setState(() {
      _lineasEntrada.removeAt(index);
    });
  }

  /// Guardar todas las líneas (hace POST por cada una)
  Future<void> _submitAll() async {
    if (_lineasEntrada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una entrada')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    int successCount = 0;
    int errorCount = 0;

    // Iterar y hacer POST por cada línea
    for (final lineItem in _lineasEntrada) {
      final success = await ref.read(movimientosProvider.notifier).createMovimiento(
            productoId: lineItem.producto.productoId,
            usuarioId: user.usuarioId,
            clienteId: user.clienteId,
            proveedorId: _proveedorId,
            tipo: TipoMovimiento.entrada,
            costo: lineItem.costo,
            impuesto: lineItem.impuesto,
            descuentoUnidad: lineItem.descuento,
            cantidad: lineItem.cantidad,
            observacion: lineItem.observacion,
            fecha: DateTime.now(),
          );

      if (success) {
        successCount++;
      } else {
        errorCount++;
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorCount > 0
                ? 'Se guardaron $successCount de ${_lineasEntrada.length} entradas'
                : 'Se guardaron $successCount entradas correctamente',
          ),
          backgroundColor: errorCount > 0 ? AppColors.warning : AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.success; // Verde para ENTRADA
    final user = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrada de Productos',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Agregar múltiples productos',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Form + Lista de items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Formulario para agregar items
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Producto
                          Text(
                            'Producto *',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (user != null)
                            ProductoAutocompleteWidget(
                              clienteId: user.clienteId,
                              controller: _productoSearchController,
                              selectedProducto: _productoSelected,
                              onProductoSelected: (producto) {
                                setState(() {
                                  _productoSelected = producto;
                                });
                              },
                              onClear: () {
                                setState(() {
                                  _productoSelected = null;
                                  _productoSearchController.clear();
                                });
                              },
                              primaryColor: primaryColor,
                              hintText: 'Escribe 3+ caracteres para buscar...',
                            ),

                          SizedBox(height: 16.h),

                          // Cantidad y Costo en fila
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cantidadController,
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad *',
                                    hintText: '0',
                                    prefixIcon: Icon(Icons.inventory_2, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: TextFormField(
                                  controller: _costoController,
                                  decoration: InputDecoration(
                                    labelText: 'Costo Unit. *',
                                    hintText: '0.00',
                                    prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Impuesto y Descuento en fila
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _impuestoController,
                                  decoration: InputDecoration(
                                    labelText: 'Impuesto',
                                    hintText: '0.00',
                                    prefixIcon: Icon(Icons.percent, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: TextFormField(
                                  controller: _descuentoController,
                                  decoration: InputDecoration(
                                    labelText: 'Descuento',
                                    hintText: '0.00',
                                    prefixIcon: Icon(Icons.discount, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Observación
                          TextFormField(
                            controller: _observacionController,
                            decoration: InputDecoration(
                              labelText: 'Observación',
                              hintText: 'Notas...',
                              prefixIcon: Icon(Icons.notes, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            maxLines: 2,
                            maxLength: 200,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                          ),

                          SizedBox(height: 16.h),

                          // Botón Agregar a la lista
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addLineItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                'Agregar a la Lista',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de items agregados
                  if (_lineasEntrada.isNotEmpty) ...[
                    Container(
                      color: AppColors.grey100,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Productos Agregados (${_lineasEntrada.length})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                                .format(_lineasEntrada.fold(0.0, (sum, item) => sum + item.total)),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      itemCount: _lineasEntrada.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = _lineasEntrada[index];
                        return _EntradaLineItemCard(
                          item: item,
                          index: index,
                          onRemove: () => _removeLineItem(index),
                        );
                      },
                    ),
                  ],

                  if (_lineasEntrada.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64.sp,
                            color: AppColors.grey300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Agrega productos a la lista',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Botón Guardar Todas las Entradas
          if (_lineasEntrada.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Guardar Todas las Entradas (${_lineasEntrada.length})',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

/// Card para mostrar cada línea de entrada agregada
class _EntradaLineItemCard extends StatelessWidget {
  final EntradaLineItem item;
  final int index;
  final VoidCallback onRemove;

  const _EntradaLineItemCard({
    required this.item,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${index + 1}. ${item.producto.nombre}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.danger, size: 20.sp),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cantidad: ${item.cantidad}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                Text(
                  'Costo: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.costo)}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (item.impuesto > 0 || item.descuento > 0) ...[
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.impuesto > 0)
                    Text(
                      'Impuesto: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.impuesto)}',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                  if (item.descuento > 0)
                    Text(
                      'Desc.: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.descuento)}',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ],
            if (item.observacion != null && item.observacion!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                item.observacion!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.total),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
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
