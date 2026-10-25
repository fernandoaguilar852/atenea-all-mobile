import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/caja.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/movimiento_entity.dart';
import '../../providers/movimientos_provider.dart';

/// Formulario para INGRESO de dinero
/// Color: Azul - Representa ingreso de efectivo
class IngresoFormWidget extends ConsumerStatefulWidget {
  const IngresoFormWidget({super.key});

  @override
  ConsumerState<IngresoFormWidget> createState() => _IngresoFormWidgetState();
}

class _IngresoFormWidgetState extends ConsumerState<IngresoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _observacionController = TextEditingController();
  final _productoSearchController = TextEditingController();

  Producto? _productoSelected;
  Caja? _cajaSelected;
  bool _isLoading = false;

  @override
  void dispose() {
    _montoController.dispose();
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
    if (_cajaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una caja')),
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
          cajaId: _cajaSelected!.cajaId,
          pagoId: 1, // TODO: Implementar selección de tipo de pago
          tipo: TipoMovimiento.ingreso,
          costo: double.parse(_montoController.text),
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
          content: Text('Ingreso registrado correctamente'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary; // Azul para INGRESO
    final user = ref.watch(currentUserProvider);

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
                    Icons.add_circle,
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
                        'Ingreso de Dinero',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Registrar entrada de efectivo',
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
                  // Caja
                  Text(
                    'Caja *',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (user != null)
                    Consumer(
                      builder: (context, ref, child) {
                        final cajasAsync = ref.watch(cajasProvider(
                          CajasParams(clienteId: user.clienteId, estado: null),
                        ));

                        return cajasAsync.when(
                          data: (cajas) => DropdownButtonFormField<Caja>(
                            value: _cajaSelected,
                            decoration: InputDecoration(
                              hintText: 'Seleccionar caja',
                              prefixIcon: Icon(Icons.point_of_sale, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            items: cajas.map((caja) {
                              return DropdownMenuItem(
                                value: caja,
                                child: Text(caja.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _cajaSelected = value);
                            },
                            validator: (value) {
                              if (value == null) return 'Selecciona una caja';
                              return null;
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        );
                      },
                    ),

                  SizedBox(height: 16.h),

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

                  // Monto
                  TextFormField(
                    controller: _montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      helperText: 'Monto del ingreso',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa el monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Monto inválido';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Cantidad
                  TextFormField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad *',
                      hintText: '1',
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
                    initialValue: '1',
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
                      hintText: 'Concepto del ingreso...',
                      prefixIcon: Icon(Icons.notes, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 200,
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
                            'Registrar Ingreso',
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
