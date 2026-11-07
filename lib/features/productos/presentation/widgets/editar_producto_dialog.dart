import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/iva.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/models/tipo_producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/productos_provider.dart';

/// Formatter que permite solo un separador decimal (. o ,)
class SingleDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir solo números, punto y coma
    final text = newValue.text;
    if (!RegExp(r'^[0-9.,]*$').hasMatch(text)) {
      return oldValue;
    }

    // Contar separadores decimales (. y ,)
    final dotCount = '.'.allMatches(text).length;
    final commaCount = ','.allMatches(text).length;
    final totalSeparators = dotCount + commaCount;

    // Permitir máximo un separador
    if (totalSeparators > 1) {
      return oldValue;
    }

    return newValue;
  }
}

class EditarProductoDialog extends ConsumerStatefulWidget {
  final Producto producto;

  const EditarProductoDialog({
    super.key,
    required this.producto,
  });

  @override
  ConsumerState<EditarProductoDialog> createState() => _EditarProductoDialogState();
}

class _EditarProductoDialogState extends ConsumerState<EditarProductoDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nombreController;
  late final TextEditingController _codExternoController;
  late final TextEditingController _codBarrasController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockTotalController;
  late final TextEditingController _stockMinimoController;

  // Form values
  TipoProducto? _tipoProductoSelected;
  Iva? _ivaSelected;
  late String _unidadMedida;
  late bool _manejaStock;
  late bool _activo;
  bool _isLoading = false;

  final List<String> _unidadesMedida = [
    'UNIDAD',
    'KILOGRAMO',
    'LITRO',
    'METRO',
    'CAJA',
    'PAR',
    'PAQUETE',
    'OTRO',
  ];

  @override
  void initState() {
    super.initState();

    // Pre-llenar controllers con datos del producto
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _codExternoController = TextEditingController(text: widget.producto.codExterno ?? '');
    _codBarrasController = TextEditingController(text: widget.producto.codBarras ?? '');
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockTotalController = TextEditingController(text: widget.producto.stockTotal.toString());
    _stockMinimoController = TextEditingController(text: widget.producto.stockMinimo.toString());

    _unidadMedida = widget.producto.unidadMedida;
    _manejaStock = widget.producto.manejaStock;
    _activo = widget.producto.activo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codExternoController.dispose();
    _codBarrasController.dispose();
    _precioController.dispose();
    _stockTotalController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoProductoSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de producto')),
      );
      return;
    }

    if (_ivaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un IVA')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Usuario no autenticado');

      await ref.read(productosProvider.notifier).updateProducto(
        productoId: widget.producto.productoId,
        clienteId: user.clienteId,
        tipoProductoId: _tipoProductoSelected!.tipoProductoId,
        nombre: _nombreController.text.trim(),
        codExterno: _codExternoController.text.trim().isEmpty
            ? null
            : _codExternoController.text.trim(),
        codBarras: _codBarrasController.text.trim().isEmpty
            ? null
            : _codBarrasController.text.trim(),
        precio: double.parse(_precioController.text.replaceAll(',', '.')),
        unidadMedida: _unidadMedida,
        stockTotal: double.parse(_stockTotalController.text.replaceAll(',', '.')),
        stockMinimo: double.parse(_stockMinimoController.text.replaceAll(',', '.')),
        manejaStock: _manejaStock,
        ivaId: _ivaSelected!.ivaId,
        activo: _activo,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // true indica que se actualizó exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto "${_nombreController.text}" actualizado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar producto: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const AlertDialog(
        title: Text('Error'),
        content: Text('Usuario no autenticado'),
      );
    }

    final tiposProductoAsync = ref.watch(tiposProductoProvider(
      TiposProductoParams(clienteId: user.clienteId),
    ));

    final ivasAsync = ref.watch(ivasProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: AppColors.white, size: 28.sp),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Editar Producto',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body - Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del producto
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Producto *',
                          hintText: 'Ej: Cerveza Aguila',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Tipo de Producto
                      tiposProductoAsync.when(
                        data: (tipos) {
                          // Pre-seleccionar el tipo de producto actual
                          _tipoProductoSelected ??= tipos.firstWhere(
                            (tipo) => tipo.tipoProductoId == widget.producto.tipoProductoId,
                            orElse: () => tipos.first,
                          );

                          return DropdownButtonFormField<TipoProducto>(
                            value: _tipoProductoSelected,
                            decoration: InputDecoration(
                              labelText: 'Tipo de Producto *',
                              prefixIcon: const Icon(Icons.category_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            items: tipos.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.nombre),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _tipoProductoSelected = value);
                            },
                            validator: (value) {
                              if (value == null) return 'Selecciona un tipo de producto';
                              return null;
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (error, _) => Text('Error: $error'),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Row: Código Externo y Código de Barras
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codExternoController,
                              decoration: InputDecoration(
                                labelText: 'Código Externo',
                                hintText: 'Ej: EXT-001',
                                prefixIcon: const Icon(Icons.qr_code_2_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _codBarrasController,
                              decoration: InputDecoration(
                                labelText: 'Código de Barras',
                                hintText: 'Ej: 7501234567890',
                                prefixIcon: const Icon(Icons.qr_code_scanner),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Precio
                      TextFormField(
                        controller: _precioController,
                        decoration: InputDecoration(
                          labelText: 'Precio *',
                          hintText: 'Ej: 15000.50',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          SingleDecimalInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El precio es requerido';
                          }
                          final precio = double.tryParse(value.replaceAll(',', '.'));
                          if (precio == null || precio <= 0) {
                            return 'Ingresa un precio válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // IVA
                      ivasAsync.when(
                        data: (ivas) {
                          // Pre-seleccionar el IVA actual
                          _ivaSelected ??= ivas.firstWhere(
                            (iva) => iva.ivaId == widget.producto.ivaId,
                            orElse: () => ivas.first,
                          );

                          return DropdownButtonFormField<Iva>(
                            value: _ivaSelected,
                            decoration: InputDecoration(
                              labelText: 'IVA *',
                              prefixIcon: const Icon(Icons.calculate_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                            ),
                            items: ivas.map((iva) {
                              return DropdownMenuItem(
                                value: iva,
                                child: Text(iva.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _ivaSelected = value);
                            },
                            validator: (value) {
                              if (value == null) return 'Selecciona un IVA';
                              return null;
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (error, _) => Text('Error: $error'),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Unidad de Medida
                      DropdownButtonFormField<String>(
                        value: _unidadMedida,
                        decoration: InputDecoration(
                          labelText: 'Unidad de Medida *',
                          prefixIcon: const Icon(Icons.straighten_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        items: _unidadesMedida.map((unidad) {
                          return DropdownMenuItem(
                            value: unidad,
                            child: Text(unidad),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _unidadMedida = value);
                          }
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Row: Stock Total y Stock Mínimo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockTotalController,
                              decoration: InputDecoration(
                                labelText: 'Stock Total *',
                                hintText: 'Ej: 100.500',
                                prefixIcon: const Icon(Icons.inventory_2_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                              inputFormatters: [
                                SingleDecimalInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Stock total requerido';
                                }
                                final stock = double.tryParse(value.replaceAll(',', '.'));
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _stockMinimoController,
                              decoration: InputDecoration(
                                labelText: 'Stock Mínimo *',
                                hintText: 'Ej: 10.250',
                                prefixIcon: const Icon(Icons.warning_amber_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                              inputFormatters: [
                                SingleDecimalInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Stock mínimo requerido';
                                }
                                final stock = double.tryParse(value.replaceAll(',', '.'));
                                if (stock == null || stock < 0) {
                                  return 'Stock inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Maneja Stock
                      SwitchListTile(
                        title: Text(
                          'Maneja Stock',
                          style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                        ),
                        subtitle: Text(
                          _manejaStock
                              ? 'El sistema controlará el inventario de este producto'
                              : 'El producto no tendrá control de inventario',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                        value: _manejaStock,
                        onChanged: (value) {
                          setState(() => _manejaStock = value);
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          side: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),

                      // Estado Activo
                      SwitchListTile(
                        title: Text(
                          'Estado Activo',
                          style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                        ),
                        subtitle: Text(
                          _activo
                              ? 'El producto está disponible para operaciones'
                              : 'El producto está desactivado (solo puede eliminarse)',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                        value: _activo,
                        onChanged: (value) {
                          setState(() => _activo = value);
                        },
                        activeColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          side: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer - Botones
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.grey400),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 15.sp, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSubmit,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Icon(Icons.check, size: 20.sp),
                      label: Text(
                        _isLoading ? 'Actualizando...' : 'Actualizar',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
