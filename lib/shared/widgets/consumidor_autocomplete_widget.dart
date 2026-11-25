import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/theme_config.dart';
import '../../core/models/consumidor.dart';
import '../../core/providers/catalogs_providers.dart';

/// Widget global y reutilizable para buscar consumidores (clientes).
///
/// Misma lógica que el autocomplete de productos: debounce de 500 ms, busca
/// con 3 o más caracteres y muestra un listado con los resultados. Al elegir
/// uno llama a [onConsumidorSelected] y limpia el buscador, para que el
/// formulario que lo usa autollene sus campos.
///
/// Usa `consumidoresSearchProvider` (core), por lo que no depende de ningún
/// módulo de negocio y se puede usar también en el futuro módulo de Consumidores.
class ConsumidorAutocompleteWidget extends ConsumerStatefulWidget {
  final int clienteId;
  final TextEditingController controller;
  final ValueChanged<Consumidor> onConsumidorSelected;
  final Color primaryColor;
  final String? labelText;
  final String? hintText;

  const ConsumidorAutocompleteWidget({
    super.key,
    required this.clienteId,
    required this.controller,
    required this.onConsumidorSelected,
    this.primaryColor = AppColors.primary,
    this.labelText,
    this.hintText,
  });

  @override
  ConsumerState<ConsumidorAutocompleteWidget> createState() =>
      _ConsumidorAutocompleteWidgetState();
}

class _ConsumidorAutocompleteWidgetState
    extends ConsumerState<ConsumidorAutocompleteWidget> {
  String _searchTerm = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _searchTerm = value.trim().length >= 3 ? value.trim() : '';
      });
    });
  }

  void _seleccionar(Consumidor consumidor) {
    widget.onConsumidorSelected(consumidor);
    widget.controller.clear();
    setState(() => _searchTerm = '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText ?? 'Buscar cliente...',
            prefixIcon: Icon(Icons.search, color: widget.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: widget.primaryColor, width: 2),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
        if (_searchTerm.isNotEmpty)
          Consumer(
            builder: (context, ref, child) {
              final consumidoresAsync = ref.watch(consumidoresSearchProvider(
                ConsumidoresSearchParams(
                  clienteId: widget.clienteId,
                  searchTerm: _searchTerm,
                ),
              ));

              return consumidoresAsync.when(
                data: (consumidores) {
                  if (consumidores.isEmpty) {
                    return _mensaje('No se encontraron clientes');
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
                      itemCount: consumidores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final consumidor = consumidores[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            consumidor.nombreRazonSocial,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${consumidor.tipoIdentificacion}: ${consumidor.numeroIdentificacion}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () => _seleccionar(consumidor),
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
                      Text('Buscando...', style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ),
                error: (err, stack) => _mensaje(
                  'Error al buscar clientes',
                  color: AppColors.danger,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _mensaje(String texto, {Color? color}) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color ?? AppColors.grey300),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12.sp,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}
