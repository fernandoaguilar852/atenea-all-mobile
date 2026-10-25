import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../providers/movimientos_provider.dart';

/// Representa una línea de salida antes de ser guardada
class SalidaLineItem {
  final Producto producto;
  final double cantidad;
  final String? observacion;

  SalidaLineItem({
    required this.producto,
    required this.cantidad,
    this.observacion,
  });
}

/// Formulario para SALIDA de productos
/// Color: Naranja - Representa salida de inventario
/// PERMITE AGREGAR MÚLTIPLES LÍNEAS DE PRODUCTOS
class SalidaFormWidget extends ConsumerStatefulWidget {
  const SalidaFormWidget({super.key});

  @override
  ConsumerState<SalidaFormWidget> createState() => _SalidaFormWidgetState();
}

class _SalidaFormWidgetState extends ConsumerState<SalidaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _observacionController = TextEditingController();
  final _productoSearchController = TextEditingController();

  Producto? _productoSelected;
  bool _isLoading = false;

  // Lista de líneas agregadas
  final List<SalidaLineItem> _lineasSalida = [];

  @override
  void dispose() {
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

    final lineItem = SalidaLineItem(
      producto: _productoSelected!,
      cantidad: double.parse(_cantidadController.text),
      observacion: _observacionController.text.isEmpty
          ? null
          : _observacionController.text,
    );

    setState(() {
      _lineasSalida.add(lineItem);
      // Limpiar formulario
      _productoSelected = null;
      _productoSearchController.clear();
      _cantidadController.clear();
      _observacionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lineItem.producto.nombre} agregado a la lista'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Eliminar línea de la lista
  void _removeLineItem(int index) {
    setState(() {
      _lineasSalida.removeAt(index);
    });
  }

  /// Guardar todas las líneas (hace POST por cada una)
  Future<void> _submitAll() async {
    if (_lineasSalida.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una salida')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    int successCount = 0;
    int errorCount = 0;

    // Iterar y hacer POST por cada línea
    for (final lineItem in _lineasSalida) {
      final success = await ref.read(movimientosProvider.notifier).createMovimiento(
            productoId: lineItem.producto.productoId,
            usuarioId: user.usuarioId,
            clienteId: user.clienteId,
            tipo: TipoMovimiento.salida,
            costo: 0.0,
            impuesto: 0.0,
            descuentoUnidad: 0.0,
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
                ? 'Se guardaron $successCount de ${_lineasSalida.length} salidas'
                : 'Se guardaron $successCount salidas correctamente',
          ),
          backgroundColor: errorCount > 0 ? AppColors.danger : AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.warning; // Naranja para SALIDA

    return Container(
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
                    Icons.arrow_upward,
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
                        'Salida de Productos',
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
                          TextField(
                            controller: _productoSearchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar producto...',
                              prefixIcon: Icon(Icons.search, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                          ),
                          if (_productoSelected != null)
                            Container(
                              margin: EdgeInsets.only(top: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: primaryColor, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      _productoSelected!.nombre,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 18.sp),
                                    onPressed: () {
                                      setState(() {
                                        _productoSelected = null;
                                        _productoSearchController.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 16.h),

                          // Cantidad
                          TextFormField(
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
                              helperText: 'Cantidad a retirar del inventario',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa la cantidad';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Cantidad inválida';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16.h),

                          // Observación
                          TextFormField(
                            controller: _observacionController,
                            decoration: InputDecoration(
                              labelText: 'Observación',
                              hintText: 'Motivo de la salida...',
                              prefixIcon: Icon(Icons.notes, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            maxLines: 3,
                            maxLength: 200,
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
                  if (_lineasSalida.isNotEmpty) ...[
                    Container(
                      color: AppColors.grey100,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Productos Agregados (${_lineasSalida.length})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Total: ${_lineasSalida.fold(0.0, (sum, item) => sum + item.cantidad).toStringAsFixed(0)} unidades',
                            style: TextStyle(
                              fontSize: 14.sp,
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
                      itemCount: _lineasSalida.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = _lineasSalida[index];
                        return _SalidaLineItemCard(
                          item: item,
                          index: index,
                          onRemove: () => _removeLineItem(index),
                        );
                      },
                    ),
                  ],

                  if (_lineasSalida.isEmpty)
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

          // Botón Guardar Todas las Salidas
          if (_lineasSalida.isNotEmpty)
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
                          'Guardar Todas las Salidas (${_lineasSalida.length})',
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
    );
  }
}

/// Card para mostrar cada línea de salida agregada
class _SalidaLineItemCard extends StatelessWidget {
  final SalidaLineItem item;
  final int index;
  final VoidCallback onRemove;

  const _SalidaLineItemCard({
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
                  'Cantidad: ${item.cantidad.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (item.observacion != null && item.observacion!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notes, size: 14.sp, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        item.observacion!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
