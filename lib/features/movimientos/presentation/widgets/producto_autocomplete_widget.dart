import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/catalogs_providers.dart';

/// Widget reutilizable de autocomplete para búsqueda de productos
/// Implementa debounce de 500ms y muestra dropdown con resultados
class ProductoAutocompleteWidget extends ConsumerStatefulWidget {
  final int clienteId;
  final TextEditingController controller;
  final Producto? selectedProducto;
  final Function(Producto) onProductoSelected;
  final VoidCallback onClear;
  final Color primaryColor;
  final String? hintText;

  const ProductoAutocompleteWidget({
    super.key,
    required this.clienteId,
    required this.controller,
    required this.selectedProducto,
    required this.onProductoSelected,
    required this.onClear,
    this.primaryColor = AppColors.primary,
    this.hintText,
  });

  @override
  ConsumerState<ProductoAutocompleteWidget> createState() =>
      _ProductoAutocompleteWidgetState();
}

class _ProductoAutocompleteWidgetState
    extends ConsumerState<ProductoAutocompleteWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Buscar producto...',
            prefixIcon: Icon(Icons.search, color: widget.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: widget.primaryColor, width: 2),
            ),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
          },
        ),
        if (widget.selectedProducto != null)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: widget.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: widget.primaryColor),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: widget.primaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.selectedProducto!.nombre,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18.sp),
                  onPressed: widget.onClear,
                ),
              ],
            ),
          ),
        if (_searchTerm.isNotEmpty && widget.selectedProducto == null)
          Consumer(
            builder: (context, ref, child) {
              final productosAsync = ref.watch(productosSearchProvider(
                ProductosSearchParams(
                  clienteId: widget.clienteId,
                  searchTerm: _searchTerm,
                ),
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
                            widget.controller.text = producto.nombre;
                            widget.onProductoSelected(producto);
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
                    'Error al buscar productos',
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
