import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../domain/entities/resolucion_entity.dart';

class ResolucionFormDialog extends StatefulWidget {
  final ResolucionEntity? resolucion;
  final Function(Map<String, dynamic>) onSave;

  const ResolucionFormDialog({
    super.key,
    this.resolucion,
    required this.onSave,
  });

  @override
  State<ResolucionFormDialog> createState() => _ResolucionFormDialogState();
}

class _ResolucionFormDialogState extends State<ResolucionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prefijoController;
  late TextEditingController _numeroResolucionController;
  late TextEditingController _numeroDesdeController;
  late TextEditingController _numeroHastaController;
  late TextEditingController _numeroActualController;
  late TextEditingController _fechaResolucionController;
  late TextEditingController _fechaVencimientoController;
  late bool _activo;

  bool get isEdit => widget.resolucion != null;

  @override
  void initState() {
    super.initState();
    final r = widget.resolucion;
    _prefijoController = TextEditingController(text: r?.prefijo ?? '');
    _numeroResolucionController = TextEditingController(text: r?.numeroResolucion ?? '');
    _numeroDesdeController = TextEditingController(text: r?.numeroDesde.toString() ?? '1');
    _numeroHastaController = TextEditingController(text: r?.numeroHasta.toString() ?? '1000');
    _numeroActualController = TextEditingController(text: r?.numeroActual.toString() ?? '1');
    _fechaResolucionController = TextEditingController(
      text: r != null ? DateFormat('yyyy-MM-dd').format(r.fechaResolucion) : '',
    );
    _fechaVencimientoController = TextEditingController(
      text: r != null ? DateFormat('yyyy-MM-dd').format(r.fechaVencimiento) : '',
    );
    _activo = r?.activo ?? true;
  }

  @override
  void dispose() {
    _prefijoController.dispose();
    _numeroResolucionController.dispose();
    _numeroDesdeController.dispose();
    _numeroHastaController.dispose();
    _numeroActualController.dispose();
    _fechaResolucionController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateTime.parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'prefijo': _prefijoController.text.trim(),
      'numeroResolucion': _numeroResolucionController.text.trim(),
      'numeroDesde': int.parse(_numeroDesdeController.text),
      'numeroHasta': int.parse(_numeroHastaController.text),
      'numeroActual': int.parse(_numeroActualController.text),
      'fechaResolucion': DateTime.parse(_fechaResolucionController.text),
      'fechaVencimiento': DateTime.parse(_fechaVencimientoController.text),
      'activo': _activo,
    };

    widget.onSave(data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Editar Resolución' : 'Nueva Resolución'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prefijo
              TextFormField(
                controller: _prefijoController,
                decoration: InputDecoration(
                  labelText: 'Prefijo *',
                  hintText: 'Ej: FAC, FV, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El prefijo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Número de Resolución (solo en crear)
              if (!isEdit)
                Column(
                  children: [
                    TextFormField(
                      controller: _numeroResolucionController,
                      decoration: InputDecoration(
                        labelText: 'Número de Resolución *',
                        hintText: 'Ej: 18762001234567',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de resolución es requerido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              // Número Desde (solo en crear)
              if (!isEdit)
                Column(
                  children: [
                    TextFormField(
                      controller: _numeroDesdeController,
                      decoration: InputDecoration(
                        labelText: 'Número Desde *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              // Número Hasta
              TextFormField(
                controller: _numeroHastaController,
                decoration: InputDecoration(
                  labelText: 'Número Hasta *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Número Actual
              TextFormField(
                controller: _numeroActualController,
                decoration: InputDecoration(
                  labelText: 'Número Actual *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Fecha de Resolución (solo en crear)
              if (!isEdit)
                Column(
                  children: [
                    TextFormField(
                      controller: _fechaResolucionController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Resolución *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, _fechaResolucionController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaResolucionController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La fecha es requerida';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              // Fecha de Vencimiento
              TextFormField(
                controller: _fechaVencimientoController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Vencimiento *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _fechaVencimientoController),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _fechaVencimientoController),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La fecha es requerida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Activo
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
                activeColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
