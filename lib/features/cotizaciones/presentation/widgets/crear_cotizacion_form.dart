import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/consumidor.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/utils/single_decimal_input_formatter.dart';
import '../../../../shared/widgets/consumidor_autocomplete_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movimientos/presentation/widgets/producto_autocomplete_widget.dart';
import '../../domain/entities/cotizacion_editable_entity.dart';
import '../../domain/entities/nueva_cotizacion_entity.dart';
import '../providers/cotizaciones_provider.dart';

/// Formulario para CREAR o EDITAR una cotización (hoja inferior).
///
/// Toda la cotización se arma en pantalla: datos del cliente y una lista de
/// productos que se van agregando uno a uno. La pantalla calcula los totales a
/// partir de las líneas.
///
/// - Crear: primero se crea la cabecera y luego cada línea, una por una.
/// - Editar (si viene [cotizacionId]): se cargan los datos guardados; al
///   guardar se eliminan/actualizan/crean las líneas y, al final, se actualiza
///   la cabecera con los totales recalculados.
class CrearCotizacionForm extends ConsumerStatefulWidget {
  /// Si viene, el formulario edita esa cotización (modo edición)
  final int? cotizacionId;

  const CrearCotizacionForm({super.key, this.cotizacionId});

  @override
  ConsumerState<CrearCotizacionForm> createState() =>
      _CrearCotizacionFormState();
}

class _CrearCotizacionFormState extends ConsumerState<CrearCotizacionForm> {
  static const Color _primary = AppColors.primary;

  final _clienteFormKey = GlobalKey<FormState>();
  final _lineaFormKey = GlobalKey<FormState>();

  /// Sección "Agregar producto": se usa para llevarla a la vista al buscar
  final _productoSectionKey = GlobalKey();

  // Cliente
  final _clienteSearchController = TextEditingController();
  final _nombreController = TextEditingController(text: 'Consumidor Final');
  final _identificacionController = TextEditingController(text: '222222222222');
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Línea que se está armando
  final _productoSearchController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();
  final _descuentoController = TextEditingController(text: '0');
  final _ivaController = TextEditingController();
  Producto? _productoSelected;

  // Líneas agregadas
  final List<NuevaLineaCotizacion> _lineas = [];

  bool _isLoading = false;

  // ---- Modo edición ----
  bool get _esEdicion => widget.cotizacionId != null;

  /// Cargando los datos de la cotización a editar
  bool _cargando = false;
  String? _errorCarga;

  /// Cotización cargada (para mostrar su número)
  CotizacionEditable? _editable;

  /// Líneas tal como estaban al abrir la edición (para detectar cambios)
  List<NuevaLineaCotizacion> _lineasOriginales = [];

  /// Ids de líneas guardadas que el usuario quitó (se eliminan al guardar)
  final List<int> _detallesEliminados = [];

  /// Índice de la línea que se está editando en el formulario de abajo
  int? _indiceLineaEditando;

  final _observacionController = TextEditingController();

  /// Mensaje de error visible dentro de la hoja (un SnackBar quedaría oculto
  /// detrás de ella)
  String? _errorMensaje;

  /// Líneas guardadas en el servidor (acumula entre reintentos)
  int _lineasGuardadas = 0;

  // Fechas de la cotización (por defecto: hoy y un mes después)
  late DateTime _fechaCotizacion;
  late DateTime _fechaValidez;

  /// true si el usuario eligió a mano la fecha de validez (ya no se recalcula)
  bool _validezModificada = false;

  final NumberFormat _money =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fechaCotizacion = DateTime(hoy.year, hoy.month, hoy.day);
    _fechaValidez = _unMesDespues(_fechaCotizacion);

    // En modo edición se cargan los datos guardados de la cotización
    if (_esEdicion) {
      _cargando = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCotizacion());
    }
  }

  @override
  void dispose() {
    _clienteSearchController.dispose();
    _nombreController.dispose();
    _identificacionController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _productoSearchController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _descuentoController.dispose();
    _ivaController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // CLIENTE
  // ===========================================================================

  /// Autollena los campos del cliente con el consumidor elegido
  /// (el buscador es el widget global ConsumidorAutocompleteWidget)
  void _seleccionarConsumidor(Consumidor consumidor) {
    setState(() {
      _nombreController.text = consumidor.nombreRazonSocial;
      _identificacionController.text = consumidor.numeroIdentificacion;
      _emailController.text = consumidor.email ?? '';
      _telefonoController.text = consumidor.telefono ?? '';
    });
    FocusScope.of(context).unfocus();
  }

  // ===========================================================================
  // LÍNEAS
  // ===========================================================================

  /// Al enfocar el buscador de productos, lleva esa sección al inicio de la
  /// vista (cuando el teclado ya está abierto) para que los resultados de la
  /// búsqueda queden visibles.
  void _mostrarSeccionProducto() {
    Future.delayed(const Duration(milliseconds: 350), () {
      final ctx = _productoSectionKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Al elegir un producto: precio sugerido e IVA vienen del producto
  void _onProductoSelected(Producto producto) {
    setState(() {
      _productoSelected = producto;
      _precioController.text = formatDecimal(producto.precio);
      _ivaController.text = '${formatDecimal(producto.ivaPorcentaje)} %';
    });
  }

  void _limpiarProducto() {
    setState(() {
      _productoSelected = null;
      _productoSearchController.clear();
      _precioController.clear();
      _ivaController.clear();
    });
  }

  void _agregarLinea() {
    if (!_lineaFormKey.currentState!.validate()) return;

    // Modo "actualizar línea": cambia cantidad, precio y descuento de la línea
    // elegida (el producto y su IVA no cambian)
    final editando = _indiceLineaEditando;
    if (editando != null) {
      final texto = _descuentoController.text.trim();
      setState(() {
        _lineas[editando] = _lineas[editando].copyWith(
          cantidad: parseDecimal(_cantidadController.text)!,
          precioUnitario: parseDecimal(_precioController.text)!,
          descuentoPorcentaje: texto.isEmpty ? 0 : (parseDecimal(texto) ?? 0),
        );
        _errorMensaje = null;
      });
      _cancelarEdicionLinea();
      FocusScope.of(context).unfocus();
      return;
    }

    final producto = _productoSelected;
    if (producto == null) {
      setState(() => _errorMensaje = 'Selecciona un producto');
      return;
    }

    final descuentoTexto = _descuentoController.text.trim();

    final linea = NuevaLineaCotizacion(
      productoId: producto.productoId,
      productoNombre: producto.nombre,
      cantidad: parseDecimal(_cantidadController.text)!,
      precioUnitario: parseDecimal(_precioController.text)!,
      descuentoPorcentaje:
          descuentoTexto.isEmpty ? 0 : (parseDecimal(descuentoTexto) ?? 0),
      // El IVA no se edita: viene del producto
      porcentajeImpuesto: producto.ivaPorcentaje,
    );

    setState(() {
      _lineas.add(linea);
      _errorMensaje = null;
      _productoSelected = null;
      _productoSearchController.clear();
      _cantidadController.clear();
      _precioController.clear();
      _descuentoController.text = '0';
      _ivaController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  /// Carga una línea en el formulario de abajo para cambiar su cantidad,
  /// precio o descuento (el producto queda fijo)
  void _editarLinea(int index) {
    final linea = _lineas[index];
    setState(() {
      _indiceLineaEditando = index;
      _productoSelected = null;
      _productoSearchController.clear();
      _cantidadController.text = formatDecimal(linea.cantidad);
      _precioController.text = formatDecimal(linea.precioUnitario);
      _descuentoController.text = formatDecimal(linea.descuentoPorcentaje);
      _ivaController.text = '${formatDecimal(linea.porcentajeImpuesto)} %';
      _errorMensaje = null;
    });
    _mostrarSeccionProducto();
  }

  /// Sale del modo "actualizar línea" y limpia el formulario de la línea
  void _cancelarEdicionLinea() {
    setState(() {
      _indiceLineaEditando = null;
      _productoSelected = null;
      _productoSearchController.clear();
      _cantidadController.clear();
      _precioController.clear();
      _descuentoController.text = '0';
      _ivaController.clear();
    });
  }

  /// Quita una línea. Si ya estaba guardada en el servidor (modo edición),
  /// pide confirmación; se elimina de verdad al guardar los cambios.
  Future<void> _confirmarQuitarLinea(int index) async {
    final linea = _lineas[index];

    if (!(_esEdicion && linea.estaGuardada)) {
      _quitarLinea(index);
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitar producto'),
        content: Text(
          '¿Quitar "${linea.productoNombre}" de la cotización? '
          'Se eliminará al guardar los cambios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) _quitarLinea(index);
  }

  void _quitarLinea(int index) {
    final linea = _lineas[index];
    _cancelarEdicionLinea();
    setState(() {
      _lineas.removeAt(index);
      if (linea.estaGuardada) {
        _detallesEliminados.add(linea.cotizacionDetalleId!);
      }
    });
  }

  // ===========================================================================
  // TOTALES Y GUARDADO
  // ===========================================================================

  // ===========================================================================
  // FECHAS
  // ===========================================================================

  /// Un mes después de [fecha]; si el día no existe en ese mes (ej. 31 de
  /// enero) usa el último día del mes (28 o 29 de febrero).
  DateTime _unMesDespues(DateTime fecha) {
    final mes = fecha.month == 12 ? 1 : fecha.month + 1;
    final anio = fecha.month == 12 ? fecha.year + 1 : fecha.year;
    final ultimoDia = DateTime(anio, mes + 1, 0).day;
    return DateTime(anio, mes, fecha.day > ultimoDia ? ultimoDia : fecha.day);
  }

  /// Elige la fecha de cotización o la de validez. La validez no puede ser
  /// anterior a la cotización. Si se cambia la fecha de cotización y la
  /// validez no se ha tocado, se recalcula a un mes después.
  Future<void> _seleccionarFecha({required bool esCotizacion}) async {
    final ahora = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: esCotizacion ? _fechaCotizacion : _fechaValidez,
      firstDate: DateTime(2020),
      lastDate: DateTime(ahora.year + (esCotizacion ? 2 : 5), 12, 31),
    );

    if (picked == null || !mounted) return;

    final cotizacion = esCotizacion ? picked : _fechaCotizacion;
    final validez = esCotizacion
        ? (_validezModificada ? _fechaValidez : _unMesDespues(picked))
        : picked;

    if (validez.isBefore(cotizacion)) {
      _mostrarFechaInvalida();
      return;
    }

    setState(() {
      _fechaCotizacion = cotizacion;
      _fechaValidez = validez;
      if (!esCotizacion) _validezModificada = true;
    });
  }

  void _mostrarFechaInvalida() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fechas inválidas'),
        content: const Text(
          'La fecha de validez debe ser igual o posterior a la fecha de cotización.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Arma la cotización con los datos actuales (también calcula los totales)
  ///
  /// TODO(deuda técnica): enviar [_fechaCotizacion] y [_fechaValidez] al API.
  /// Hoy se muestran y se pueden editar en el formulario, pero NO se envían:
  /// el servidor asigna la fecha de hoy y 30 días de validez por su cuenta.
  /// Falta confirmar con el backend los nombres de los campos y su formato.
  NuevaCotizacion _construirCotizacion() {
    return NuevaCotizacion(
      consumidorNombre: _nombreController.text.trim(),
      consumidorIdentificacion: _identificacionController.text.trim(),
      consumidorEmail: _emailController.text.trim(),
      consumidorTelefono: _telefonoController.text.trim(),
      lineas: List.unmodifiable(_lineas),
    );
  }

  /// Crea la cotización: primero la cabecera y luego cada línea, una por una
  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() => _errorMensaje = null);

    if (!_clienteFormKey.currentState!.validate()) {
      // Llevar la vista a los datos del cliente
      final ctx = _clienteFormKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
      }
      setState(() => _errorMensaje =
          'Completa los datos del cliente (nombre e identificación)');
      return;
    }

    if (_lineas.isEmpty) {
      setState(() => _errorMensaje = 'Agrega al menos un producto');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Modo edición: eliminar/actualizar/crear líneas y, al final, la cabecera
    if (_esEdicion) {
      setState(() => _isLoading = true);

      final resultado =
          await ref.read(cotizacionesProvider.notifier).actualizarCotizacionCompleta(
                clienteId: user.clienteId,
                cotizacionId: widget.cotizacionId!,
                cotizacion: _construirCotizacion(),
                lineasOriginales: _lineasOriginales,
                detallesEliminados: List.of(_detallesEliminados),
                observacion: _observacionController.text,
              );

      if (!mounted) return;
      await _procesarResultadoEdicion(resultado, user.clienteId);
      return;
    }

    setState(() {
      _isLoading = true;
      _lineasGuardadas = 0;
    });

    final resultado =
        await ref.read(cotizacionesProvider.notifier).crearCotizacion(
              clienteId: user.clienteId,
              cotizacion: _construirCotizacion(),
            );

    if (!mounted) return;
    await _procesarResultado(resultado, user.clienteId);
  }

  /// Decide qué hacer según el resultado: éxito, fallo de cabecera o
  /// líneas pendientes (con opción de reintentar)
  Future<void> _procesarResultado(
    CrearCotizacionResultado resultado,
    int clienteId,
  ) async {
    _lineasGuardadas += resultado.lineasCreadas;
    final creada = resultado.cotizacion;

    // La cabecera no se creó: no hay nada guardado, se conserva el formulario
    if (creada == null) {
      setState(() {
        _isLoading = false;
        _errorMensaje = 'No se pudo crear la cotización: ${resultado.error}';
      });
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Todo guardado: cerrar la hoja avisando que hay que recargar el listado
    if (resultado.completo) {
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Cotización ${creada.numeroCotizacion} creada con '
            '$_lineasGuardadas producto(s)',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    // Faltan líneas: la cabecera ya existe, se ofrece reintentar solo esas
    setState(() => _isLoading = false);
    final reintentar = await _mostrarDialogoPendientes(resultado);
    if (!mounted) return;

    if (reintentar == true) {
      setState(() => _isLoading = true);
      final nuevo =
          await ref.read(cotizacionesProvider.notifier).reintentarDetalles(
                clienteId: clienteId,
                cotizacion: creada,
                pendientes: resultado.lineasPendientes,
              );
      if (!mounted) return;
      await _procesarResultado(nuevo, clienteId);
      return;
    }

    // Cerrar sin reintentar: la cotización quedó incompleta
    navigator.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Cotización ${creada.numeroCotizacion} creada, pero faltan '
          '${resultado.lineasPendientes.length} producto(s)',
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  /// Avisa qué productos no se guardaron. true = reintentar, false = cerrar.
  Future<bool?> _mostrarDialogoPendientes(CrearCotizacionResultado resultado) {
    final numero = resultado.cotizacion!.numeroCotizacion;
    final pendientes = resultado.lineasPendientes;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cotización incompleta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La cotización $numero se creó, pero ${pendientes.length} '
                'producto(s) no se pudieron guardar:',
              ),
              SizedBox(height: 8.h),
              ...pendientes.map((l) => Text('• ${l.productoNombre}')),
              if (resultado.error != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Error: ${resultado.error}',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EDICIÓN
  // ===========================================================================

  /// Carga la cotización a editar y rellena el formulario
  Future<void> _cargarCotizacion() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    final (editable, error) =
        await ref.read(cotizacionesProvider.notifier).obtenerCotizacionParaEditar(
              clienteId: user.clienteId,
              cotizacionId: widget.cotizacionId!,
            );

    if (!mounted) return;

    if (editable == null) {
      setState(() {
        _cargando = false;
        _errorCarga = error ?? 'No se pudo cargar la cotización';
      });
      return;
    }

    setState(() {
      _editable = editable;
      _nombreController.text = editable.consumidorNombre;
      _identificacionController.text = editable.consumidorIdentificacion;
      _emailController.text = editable.consumidorEmail ?? '';
      _telefonoController.text = editable.consumidorTelefono ?? '';
      _observacionController.text = editable.observacion ?? '';
      _lineas
        ..clear()
        ..addAll(editable.lineas);
      _lineasOriginales = List.of(editable.lineas);
      _detallesEliminados.clear();
      _cargando = false;
    });
  }

  /// Resultado de guardar los cambios: éxito o pendientes (con reintento)
  Future<void> _procesarResultadoEdicion(
    ActualizarCotizacionResultado resultado,
    int clienteId,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final numero = _editable?.numeroCotizacion ?? '';

    if (resultado.completo) {
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Cotización $numero actualizada'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    setState(() => _isLoading = false);
    final reintentar = await _mostrarDialogoPendientesEdicion(resultado);
    if (!mounted) return;

    if (reintentar == true) {
      setState(() => _isLoading = true);
      final nuevo =
          await ref.read(cotizacionesProvider.notifier).reintentarActualizacion(
                clienteId: clienteId,
                cotizacionId: widget.cotizacionId!,
                pendientes: resultado.pendientes,
              );
      if (!mounted) return;
      await _procesarResultadoEdicion(nuevo, clienteId);
      return;
    }

    // Cerrar sin reintentar: algo pudo cambiar, hay que recargar el listado
    navigator.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Cotización $numero con cambios incompletos '
          '(faltan ${resultado.pendientes.length} paso(s))',
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  /// Lista los pasos que no se pudieron guardar. true = reintentar.
  Future<bool?> _mostrarDialogoPendientesEdicion(
    ActualizarCotizacionResultado resultado,
  ) {
    final numero = _editable?.numeroCotizacion ?? '';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambios incompletos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No se pudieron guardar todos los cambios de la cotización '
                '$numero. Faltan estos pasos:',
              ),
              SizedBox(height: 8.h),
              ...resultado.pendientes.map((op) => Text('• ${op.descripcion}')),
              if (resultado.error != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Error: ${resultado.error}',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              SizedBox(height: 8.h),
              Text(
                'Los totales se actualizan al final, así que hasta completar '
                'los pasos pueden no coincidir con los productos.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCuerpo()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.request_quote, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esEdicion ? 'Editar Cotización' : 'Nueva Cotización',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                Text(
                  _esEdicion
                      ? (_editable?.numeroCotizacion ?? 'Cargando...')
                      : 'Cliente y productos',
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
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: _primary) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSeccionCliente() {
    final user = ref.watch(currentUserProvider);

    return Form(
      key: _clienteFormKey,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSeccion('Cliente'),
            SizedBox(height: 12.h),

            // Buscador global de consumidores existentes
            if (user != null)
              ConsumidorAutocompleteWidget(
                clienteId: user.clienteId,
                controller: _clienteSearchController,
                onConsumidorSelected: _seleccionarConsumidor,
                primaryColor: _primary,
                labelText: 'Buscar cliente existente',
                hintText: 'Digite al menos 3 caracteres...',
              ),
            SizedBox(height: 12.h),

            TextFormField(
              controller: _nombreController,
              decoration: _decoration('Nombre *', icon: Icons.person_outline),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Requerido' : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _identificacionController,
              decoration: _decoration('Identificación *', icon: Icons.badge_outlined),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Requerido' : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _emailController,
              decoration: _decoration('Email', icon: Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _telefonoController,
              decoration: _decoration('Teléfono', icon: Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionFechas() {
    Widget campoFecha(String label, DateTime fecha, VoidCallback onTap) {
      return InkWell(
        onTap: _isLoading ? null : onTap,
        child: InputDecorator(
          decoration: _decoration(label, icon: Icons.calendar_today),
          child: Text(
            DateFormat('dd/MM/yyyy').format(fecha),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTituloSeccion('Fechas'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: campoFecha(
                  'Cotización',
                  _fechaCotizacion,
                  () => _seleccionarFecha(esCotizacion: true),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: campoFecha(
                  'Validez',
                  _fechaValidez,
                  () => _seleccionarFecha(esCotizacion: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cuerpo del formulario: cargando, error de carga o el formulario completo
  Widget _buildCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorCarga != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
              SizedBox(height: 16.h),
              Text(
                'No se pudo cargar la cotización: $_errorCarga',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: _cargarCotizacion,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionCliente(),
          Divider(height: 1.h, color: AppColors.grey300),
          // Las fechas solo se muestran al crear; al editar va la observación
          if (_esEdicion) _buildSeccionObservacion() else _buildSeccionFechas(),
          Divider(height: 1.h, color: AppColors.grey300),
          _buildSeccionLinea(),
          _buildListaLineas(),
        ],
      ),
    );
  }

  /// Observación general de la cotización (solo en modo edición)
  Widget _buildSeccionObservacion() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTituloSeccion('Observación'),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _observacionController,
            decoration: _decoration('Observación', icon: Icons.notes, hint: 'Notas...'),
            maxLines: 3,
            maxLength: 200,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  /// Aviso de que se está editando una línea (en lugar del buscador de producto)
  Widget _bannerEdicionLinea() {
    final nombre = _lineas[_indiceLineaEditando!].productoNombre;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _primary),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: _primary, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Editando: $nombre',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18.sp),
            tooltip: 'Cancelar edición',
            onPressed: _cancelarEdicionLinea,
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionLinea() {
    final user = ref.watch(currentUserProvider);

    return Form(
      key: _lineaFormKey,
      child: Padding(
        key: _productoSectionKey,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSeccion(
              _indiceLineaEditando != null ? 'Editar producto' : 'Agregar producto',
            ),
            SizedBox(height: 12.h),

            if (_indiceLineaEditando != null)
              _bannerEdicionLinea()
            else if (user != null)
              Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onFocusChange: (hasFocus) {
                  if (hasFocus) _mostrarSeccionProducto();
                },
                child: ProductoAutocompleteWidget(
                  clienteId: user.clienteId,
                  controller: _productoSearchController,
                  selectedProducto: _productoSelected,
                  onProductoSelected: _onProductoSelected,
                  onClear: _limpiarProducto,
                  primaryColor: _primary,
                  hintText: 'Escribe 3+ caracteres para buscar...',
                ),
              ),
            SizedBox(height: 16.h),

            // Cantidad y precio
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantidadController,
                    decoration: _decoration('Cantidad *', icon: Icons.inventory_2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [SingleDecimalInputFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      final n = parseDecimal(value);
                      if (n == null || n <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    decoration: _decoration('Precio unit. *', icon: Icons.attach_money),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [SingleDecimalInputFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      final n = parseDecimal(value);
                      if (n == null || n < 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Descuento % e IVA % (el IVA viene del producto y no se edita)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _descuentoController,
                    decoration: _decoration('Descuento %', icon: Icons.discount),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [SingleDecimalInputFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final n = parseDecimal(value);
                      if (n == null) return 'Inválido';
                      if (n < 0 || n > 100) return 'Entre 0 y 100';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _ivaController,
                    enabled: false,
                    decoration: _decoration('IVA', icon: Icons.percent).copyWith(
                      hintText: 'Del producto',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _agregarLinea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                icon: Icon(
                  _indiceLineaEditando != null ? Icons.check : Icons.add,
                  color: Colors.white,
                ),
                label: Text(
                  _indiceLineaEditando != null ? 'Actualizar línea' : 'Agregar a la Lista',
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
    );
  }

  Widget _buildListaLineas() {
    if (_lineas.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64.sp,
                color: AppColors.grey300,
              ),
              SizedBox(height: 16.h),
              Text(
                'Agrega productos a la cotización',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.grey100,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Text(
            'Productos Agregados (${_lineas.length})',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          itemCount: _lineas.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return _LineaCard(
              linea: _lineas[index],
              index: index,
              money: _money,
              onRemove: _isLoading ? null : () => _confirmarQuitarLinea(index),
              // El lápiz solo se ofrece al editar una cotización
              onEdit: (_esEdicion && !_isLoading) ? () => _editarLinea(index) : null,
            );
          },
        ),
      ],
    );
  }

  /// Totales en vivo + botón de crear
  Widget _buildFooter() {
    // Con el teclado abierto se oculta el pie (totales y botón) para dejar
    // espacio al formulario y que se vean los resultados de las búsquedas
    if (MediaQuery.of(context).viewInsets.bottom > 0 ||
        _cargando ||
        _errorCarga != null) {
      return const SizedBox.shrink();
    }

    final cotizacion = _construirCotizacion();

    Widget fila(String etiqueta, double valor, {bool destacado = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: destacado ? 16.sp : 13.sp,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
                color: destacado ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            Text(
              _money.format(valor),
              style: TextStyle(
                fontSize: destacado ? 18.sp : 13.sp,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w600,
                color: destacado ? _primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMensaje != null)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.danger),
              ),
              child: Text(
                _errorMensaje!,
                style: TextStyle(fontSize: 12.sp, color: AppColors.danger),
              ),
            ),
          fila('Subtotal', cotizacion.subtotalSinImpuestos),
          fila('Descuentos', -cotizacion.totalDescuentos),
          fila('Impuestos', cotizacion.totalImpuestos),
          Divider(height: 12.h, thickness: 1.5),
          fila('TOTAL', cotizacion.total, destacado: true),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoading || _lineas.isEmpty) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _esEdicion
                          ? 'Guardar Cambios'
                          : 'Crear Cotización (${_lineas.length})',
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
    );
  }
}

/// Card de una línea agregada a la cotización
class _LineaCard extends StatelessWidget {
  final NuevaLineaCotizacion linea;
  final int index;
  final NumberFormat money;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  const _LineaCard({
    required this.linea,
    required this.index,
    required this.money,
    required this.onRemove,
    this.onEdit,
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
                    '${index + 1}. ${linea.productoNombre}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEdit != null) ...[
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primary, size: 20.sp),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 16.w),
                ],
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.danger, size: 20.sp),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${formatDecimal(linea.cantidad)} x ${money.format(linea.precioUnitario)}'
              ' = ${money.format(linea.subtotal)}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            if (linea.descuentoPorcentaje > 0) ...[
              SizedBox(height: 4.h),
              Text(
                'Desc. ${formatDecimal(linea.descuentoPorcentaje)}%: '
                '-${money.format(linea.descuentoValor)}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.success),
              ),
            ],
            if (linea.porcentajeImpuesto > 0) ...[
              SizedBox(height: 4.h),
              Text(
                'IVA ${formatDecimal(linea.porcentajeImpuesto)}%: '
                '+${money.format(linea.valorImpuesto)}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ],
            Divider(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
                Text(
                  money.format(linea.totalLinea),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
