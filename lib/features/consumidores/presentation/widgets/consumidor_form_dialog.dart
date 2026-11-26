import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/ciudad.dart';
import '../../../../core/models/departamento.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../../shared/widgets/selector_busqueda_dialog.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../../domain/entities/nuevo_consumidor_entity.dart';

/// Diálogo con el formulario de un consumidor (cliente), para crear o editar.
///
/// Si recibe [consumidor], funciona en modo edición: precarga sus datos,
/// incluida su ciudad y departamento. No llama al API por sí mismo: al guardar
/// invoca [onGuardar], que devuelve null si salió bien (el diálogo se cierra
/// con `true`) o el mensaje de error (se muestra dentro del diálogo y se puede
/// corregir y reintentar).
class ConsumidorFormDialog extends ConsumerStatefulWidget {
  final Future<String?> Function(NuevoConsumidor consumidor) onGuardar;

  /// Consumidor a editar (null = crear uno nuevo)
  final ConsumidorEntity? consumidor;

  const ConsumidorFormDialog({
    super.key,
    required this.onGuardar,
    this.consumidor,
  });

  @override
  ConsumerState<ConsumidorFormDialog> createState() =>
      _ConsumidorFormDialogState();
}

class _ConsumidorFormDialogState extends ConsumerState<ConsumidorFormDialog> {
  static const List<String> _tipos = ['CC', 'NIT', 'CE', 'TI', 'PAS'];
  static const List<String> _digitos = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  ];

  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _tipo = 'CC';
  String? _digito;
  Departamento? _departamento;
  Ciudad? _ciudad;
  bool _activo = true;

  bool _guardando = false;
  bool _cargandoCatalogo = false;
  String? _error;
  String? _errorCiudad;

  bool get _esEdicion => widget.consumidor != null;

  /// Ciudad que ya tenía el cliente guardado. Si el usuario no la cambia, se
  /// conserva (aunque no se haya podido cargar su nombre).
  int? _ciudadIdOriginal;

  /// Tipos de identificación; en edición se añade el actual si no está en la lista
  List<String> get _tiposDisponibles {
    final actual = widget.consumidor?.tipoIdentificacion;
    return (actual != null && !_tipos.contains(actual))
        ? [..._tipos, actual]
        : _tipos;
  }

  @override
  void initState() {
    super.initState();

    final c = widget.consumidor;
    if (c == null) return;

    // Modo edición: precargar los datos del cliente
    _tipo = c.tipoIdentificacion;
    _numeroController.text = c.numeroIdentificacion;
    _digito = _digitos.contains(c.digitoVerificacion) ? c.digitoVerificacion : null;
    _nombreController.text = c.nombreRazonSocial;
    _direccionController.text = c.direccion ?? '';
    _emailController.text = c.email ?? '';
    _telefonoController.text = c.telefono ?? '';
    _activo = c.activo;
    _ciudadIdOriginal = c.ciudadId;

    final ciudadId = c.ciudadId;
    if (ciudadId != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _cargarUbicacionActual(ciudadId));
    }
  }

  /// Carga la ciudad guardada del cliente y su departamento, para mostrarlos.
  /// Si falla, el campo muestra el código de la ciudad y se conserva igual.
  Future<void> _cargarUbicacionActual(int ciudadId) async {
    setState(() => _cargandoCatalogo = true);

    try {
      final ciudad = await ref.read(ciudadPorIdProvider(ciudadId).future);
      if (!mounted) return;
      setState(() => _ciudad = ciudad);

      final departamentos = await ref.read(departamentosProvider.future);
      if (!mounted) return;
      for (final d in departamentos) {
        if (d.departamentoId == ciudad.departamentoId) {
          setState(() => _departamento = d);
          break;
        }
      }
    } catch (e) {
      debugPrint('No se pudo cargar la ciudad del cliente: $e');
    } finally {
      if (mounted) setState(() => _cargandoCatalogo = false);
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // ===========================================================================
  // UBICACIÓN: departamento -> ciudad
  // ===========================================================================

  Future<void> _elegirDepartamento() async {
    setState(() {
      _cargandoCatalogo = true;
      _error = null;
    });

    try {
      final departamentos = await ref.read(departamentosProvider.future);
      if (!mounted) return;
      setState(() => _cargandoCatalogo = false);

      final elegido = await mostrarSelectorBusqueda<Departamento>(
        context: context,
        titulo: 'Departamento',
        items: departamentos,
        etiqueta: (d) => d.nombre,
        seleccionado: _departamento,
        hintBusqueda: 'Buscar departamento...',
      );

      if (elegido != null &&
          elegido.departamentoId != _departamento?.departamentoId) {
        setState(() {
          _departamento = elegido;
          _ciudad = null; // La ciudad anterior era de otro departamento
          _ciudadIdOriginal = null; // Hay que elegir una ciudad nueva
          _errorCiudad = null;
        });
      }
    } catch (e) {
      ref.invalidate(departamentosProvider); // Para reintentar en el próximo toque
      if (!mounted) return;
      setState(() {
        _cargandoCatalogo = false;
        _error = 'No se pudieron cargar los departamentos. Intenta de nuevo.';
      });
    }
  }

  Future<void> _elegirCiudad() async {
    final departamento = _departamento;
    if (departamento == null) {
      setState(() => _errorCiudad = 'Selecciona primero el departamento');
      return;
    }

    setState(() {
      _cargandoCatalogo = true;
      _error = null;
    });

    try {
      final ciudades = await ref.read(
        ciudadesProvider(departamento.departamentoId).future,
      );
      if (!mounted) return;
      setState(() => _cargandoCatalogo = false);

      final elegida = await mostrarSelectorBusqueda<Ciudad>(
        context: context,
        titulo: 'Ciudad de ${departamento.nombre}',
        items: ciudades,
        etiqueta: (c) => c.nombre,
        seleccionado: _ciudad,
        hintBusqueda: 'Buscar ciudad...',
      );

      if (elegida != null) {
        setState(() {
          _ciudad = elegida;
          _errorCiudad = null;
        });
      }
    } catch (e) {
      ref.invalidate(ciudadesProvider(departamento.departamentoId));
      if (!mounted) return;
      setState(() {
        _cargandoCatalogo = false;
        _error = 'No se pudieron cargar las ciudades. Intenta de nuevo.';
      });
    }
  }

  /// Campo de solo lectura que abre un selector al tocarlo
  Widget _campoSelector({
    required String label,
    required IconData icon,
    required String? valor,
    required VoidCallback onTap,
    String? errorText,
    bool habilitado = true,
  }) {
    return InkWell(
      onTap: (_guardando || _cargandoCatalogo || !habilitado) ? null : onTap,
      child: InputDecorator(
        decoration: _decoration(label, icon: icon).copyWith(
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          enabled: habilitado,
        ),
        child: Text(
          valor ?? 'Seleccionar',
          style: TextStyle(
            fontSize: 14.sp,
            color: valor != null ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // GUARDAR
  // ===========================================================================

  Future<void> _guardar() async {
    if (_guardando) return;

    setState(() => _error = null);

    final formularioValido = _formKey.currentState!.validate();

    // La ciudad es obligatoria (del cliente solo se guarda su id). En edición,
    // si no se cambió, se conserva la que ya tenía.
    final ciudadId = _ciudad?.ciudadId ?? _ciudadIdOriginal;
    if (ciudadId == null) {
      setState(() => _errorCiudad = _departamento == null
          ? 'Selecciona el departamento y la ciudad'
          : 'La ciudad es obligatoria');
    }

    if (!formularioValido || ciudadId == null) return;

    setState(() => _guardando = true);

    final consumidor = NuevoConsumidor(
      tipoIdentificacion: _tipo,
      numeroIdentificacion: _numeroController.text.trim(),
      digitoVerificacion: _tipo == 'NIT' ? _digito : null,
      nombreRazonSocial: _nombreController.text.trim(),
      direccion: _direccionController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      ciudadId: ciudadId,
      activo: _activo,
    );

    final error = await widget.onGuardar(consumidor);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _guardando = false;
        _error = error;
      });
    }
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final esNit = _tipo == 'NIT';
    final soloNumeros = _tipo != 'PAS';

    return AlertDialog(
      title: Text(_esEdicion ? 'Editar Cliente' : 'Nuevo Cliente'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de identificación
                DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: _decoration('Tipo de identificación *', icon: Icons.badge_outlined),
                  items: _tiposDisponibles
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          if (valor == null) return;
                          setState(() {
                            _tipo = valor;
                            if (valor != 'NIT') _digito = null;
                          });
                        },
                ),
                SizedBox(height: 12.h),

                // Número (+ dígito de verificación solo para NIT)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _numeroController,
                        enabled: !_guardando,
                        decoration: _decoration('Número *', icon: Icons.pin_outlined),
                        keyboardType:
                            soloNumeros ? TextInputType.number : TextInputType.text,
                        inputFormatters: soloNumeros
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : const [],
                        validator: (value) {
                          final texto = (value ?? '').trim();
                          if (texto.isEmpty) return 'Requerido';
                          if (soloNumeros && !RegExp(r'^\d+$').hasMatch(texto)) {
                            return 'Solo números';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (esNit) ...[
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 92.w,
                        child: DropdownButtonFormField<String>(
                          initialValue: _digito,
                          decoration: _decoration('DV *'),
                          items: _digitos
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: _guardando
                              ? null
                              : (valor) => setState(() => _digito = valor),
                          validator: (value) => value == null ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),

                // Nombre o razón social
                TextFormField(
                  controller: _nombreController,
                  enabled: !_guardando,
                  decoration: _decoration('Nombre o razón social *', icon: Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                ),
                SizedBox(height: 12.h),

                // Contacto (opcional)
                TextFormField(
                  controller: _telefonoController,
                  enabled: !_guardando,
                  decoration: _decoration('Teléfono', icon: Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _emailController,
                  enabled: !_guardando,
                  decoration: _decoration('Email', icon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final texto = (value ?? '').trim();
                    if (texto.isEmpty) return null;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)
                        ? null
                        : 'Email inválido';
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _direccionController,
                  enabled: !_guardando,
                  decoration: _decoration('Dirección', icon: Icons.location_on_outlined),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 12.h),

                // Departamento -> Ciudad (solo se guarda el id de la ciudad)
                _campoSelector(
                  label: 'Departamento',
                  icon: Icons.map_outlined,
                  valor: _departamento?.nombre,
                  onTap: _elegirDepartamento,
                ),
                SizedBox(height: 12.h),
                _campoSelector(
                  label: 'Ciudad *',
                  icon: Icons.location_city_outlined,
                  // Si no se pudo cargar el nombre, se muestra el código guardado
                  valor: _ciudad?.nombre ??
                      (_ciudadIdOriginal != null
                          ? 'Ciudad actual (código $_ciudadIdOriginal)'
                          : null),
                  onTap: _elegirCiudad,
                  errorText: _errorCiudad,
                ),
                if (_cargandoCatalogo) ...[
                  SizedBox(height: 8.h),
                  const LinearProgressIndicator(),
                ],

                // Activo
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo'),
                  value: _activo,
                  activeThumbColor: AppColors.primary,
                  onChanged: _guardando ? null : (valor) => setState(() => _activo = valor),
                ),

                // Error del servidor o de carga
                if (_error != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
