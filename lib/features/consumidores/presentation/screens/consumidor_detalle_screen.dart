import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../providers/consumidores_provider.dart';

/// Detalle de un consumidor (cliente). El botón de volver lo pone el AppBar.
class ConsumidorDetalleScreen extends ConsumerStatefulWidget {
  final int consumidorId;

  const ConsumidorDetalleScreen({super.key, required this.consumidorId});

  @override
  ConsumerState<ConsumidorDetalleScreen> createState() =>
      _ConsumidorDetalleScreenState();
}

class _ConsumidorDetalleScreenState
    extends ConsumerState<ConsumidorDetalleScreen> {
  ConsumidorEntity? _consumidor;
  bool _isLoading = true;
  String? _error;

  // Ubicación (se resuelve aparte para no bloquear el detalle)
  String? _ciudadNombre;
  String? _departamentoNombre;
  bool _cargandoUbicacion = false;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final consumidor = await ref
          .read(consumidoresRepositoryProvider)
          .getConsumidor(
            clienteId: user.clienteId,
            consumidorId: widget.consumidorId,
          );

      if (!mounted) return;
      setState(() {
        _consumidor = consumidor;
        _isLoading = false;
      });

      // Cargar ciudad y departamento sin bloquear la pantalla
      final ciudadId = consumidor.ciudadId;
      if (ciudadId != null) {
        _cargarUbicacion(ciudadId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar detalle: $e';
        _isLoading = false;
      });
    }
  }

  /// Resuelve el nombre de la ciudad y de su departamento (solo se guarda el id)
  Future<void> _cargarUbicacion(int ciudadId) async {
    setState(() => _cargandoUbicacion = true);

    try {
      final ciudad = await ref.read(ciudadPorIdProvider(ciudadId).future);
      if (!mounted) return;
      setState(() => _ciudadNombre = ciudad.nombre);

      final departamentos = await ref.read(departamentosProvider.future);
      if (!mounted) return;
      for (final d in departamentos) {
        if (d.departamentoId == ciudad.departamentoId) {
          setState(() => _departamentoNombre = d.nombre);
          break;
        }
      }
    } catch (e) {
      debugPrint('No se pudo cargar la ubicación del cliente: $e');
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_consumidor?.nombreRazonSocial ?? 'Detalle de Cliente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48.sp, color: AppColors.danger),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadDetalle,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _consumidor == null
                  ? const Center(child: Text('No se encontró el cliente'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Identificación'),
                          SizedBox(height: 8.h),
                          _buildIdentificacion(),
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Contacto'),
                          SizedBox(height: 8.h),
                          _buildContacto(),
                          SizedBox(height: 16.h),
                          _buildSectionTitle('Ubicación y registro'),
                          SizedBox(height: 8.h),
                          _buildUbicacion(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Texto de un campo opcional: el valor o "No registrado"
  String _opcional(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'No registrado' : valor;

  Widget _buildIdentificacion() {
    final c = _consumidor!;
    final estadoColor = c.activo ? AppColors.success : AppColors.grey400;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    c.activo ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: estadoColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            _buildInfoRow('Nombre / Razón social', c.nombreRazonSocial),
            SizedBox(height: 8.h),
            _buildInfoRow('Tipo de identificación', c.tipoIdentificacion),
            SizedBox(height: 8.h),
            _buildInfoRow('Número', c.identificacionCompleta),
          ],
        ),
      ),
    );
  }

  Widget _buildContacto() {
    final c = _consumidor!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildInfoRow('Teléfono', _opcional(c.telefono)),
            SizedBox(height: 8.h),
            _buildInfoRow('Email', _opcional(c.email)),
            SizedBox(height: 8.h),
            _buildInfoRow('Dirección', _opcional(c.direccion)),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacion() {
    final c = _consumidor!;

    // Mientras se resuelve: "Cargando..."; si falla: el código guardado
    String ciudad() {
      if (c.ciudadId == null) return 'No registrada';
      if (_ciudadNombre != null) return _ciudadNombre!;
      return _cargandoUbicacion ? 'Cargando...' : 'Código ${c.ciudadId}';
    }

    String departamento() {
      if (c.ciudadId == null) return 'No registrado';
      if (_departamentoNombre != null) return _departamentoNombre!;
      return _cargandoUbicacion ? 'Cargando...' : 'No disponible';
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildInfoRow('Ciudad', ciudad()),
            SizedBox(height: 8.h),
            _buildInfoRow('Departamento', departamento()),
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Fecha de creación',
              DateFormat('dd/MM/yyyy HH:mm').format(c.creadoEn.toLocal()),
            ),
          ],
        ),
      ),
    );
  }
}
