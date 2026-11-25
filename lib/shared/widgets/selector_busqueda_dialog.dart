import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/theme_config.dart';
import '../../core/utils/text_utils.dart';

/// Abre un diálogo con buscador para elegir un elemento de una lista larga
/// (ciudades, departamentos, etc.).
///
/// El buscador filtra mientras se escribe, sin importar mayúsculas ni tildes
/// ("bogota" encuentra "Bogotá D.C."). Devuelve el elemento elegido, o null si
/// se cancela.
Future<T?> mostrarSelectorBusqueda<T>({
  required BuildContext context,
  required String titulo,
  required List<T> items,
  required String Function(T item) etiqueta,
  T? seleccionado,
  String hintBusqueda = 'Buscar...',
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => _SelectorBusquedaDialog<T>(
      titulo: titulo,
      items: items,
      etiqueta: etiqueta,
      seleccionado: seleccionado,
      hintBusqueda: hintBusqueda,
    ),
  );
}

class _SelectorBusquedaDialog<T> extends StatefulWidget {
  final String titulo;
  final List<T> items;
  final String Function(T item) etiqueta;
  final T? seleccionado;
  final String hintBusqueda;

  const _SelectorBusquedaDialog({
    required this.titulo,
    required this.items,
    required this.etiqueta,
    required this.seleccionado,
    required this.hintBusqueda,
  });

  @override
  State<_SelectorBusquedaDialog<T>> createState() =>
      _SelectorBusquedaDialogState<T>();
}

class _SelectorBusquedaDialogState<T> extends State<_SelectorBusquedaDialog<T>> {
  final TextEditingController _controller = TextEditingController();
  late List<T> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = widget.items;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filtrar(String texto) {
    final consulta = normalizarTexto(texto.trim());
    setState(() {
      _filtrados = consulta.isEmpty
          ? widget.items
          : widget.items
              .where((i) => normalizarTexto(widget.etiqueta(i)).contains(consulta))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      contentPadding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hintBusqueda,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _filtrar('');
                        },
                      )
                    : null,
              ),
              onChanged: _filtrar,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: _filtrados.isEmpty
                  ? Center(
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtrados.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filtrados[index];
                        final esSeleccionado = widget.seleccionado != null &&
                            item == widget.seleccionado;
                        return ListTile(
                          dense: true,
                          title: Text(
                            widget.etiqueta(item),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight:
                                  esSeleccionado ? FontWeight.w700 : FontWeight.w400,
                              color: esSeleccionado
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          trailing: esSeleccionado
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
