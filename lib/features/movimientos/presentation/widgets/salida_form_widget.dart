import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../providers/movimientos_provider.dart';

/// Formulario para SALIDA de productos
/// Color: Naranja - Representa salida de inventario
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

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionController.dispose();
    _productoSearchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final success = await ref.read(movimientosProvider.notifier).createMovimiento(
          productoId: _productoSelected!.productoId,
          usuarioId: user.usuarioId,
          clienteId: user.clienteId,
          tipo: TipoMovimiento.salida,
          costo: 0.0,
          impuesto: 0.0,
          descuentoUnidad: 0.0,
          cantidad: double.parse(_cantidadController.text),
          observacion: _observacionController.text.isEmpty
              ? null
              : _observacionController.text,
          fecha: DateTime.now(),
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salida registrada correctamente'),
          backgroundColor: AppColors.warning,
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
                        'Registrar salida de inventario',
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

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
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
                      labelText: 'Observación *',
                      hintText: 'Motivo de la salida...',
                      prefixIcon: Icon(Icons.notes, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    maxLines: 4,
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Describe el motivo de la salida';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Botón Guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                            'Registrar Salida',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
