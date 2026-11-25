import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/cotizacion_detalle_entity.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../providers/cotizaciones_provider.dart';

class CotizacionDetalleScreen extends ConsumerStatefulWidget {
  final int cotizacionId;

  const CotizacionDetalleScreen({super.key, required this.cotizacionId});

  @override
  ConsumerState<CotizacionDetalleScreen> createState() =>
      _CotizacionDetalleScreenState();
}

class _CotizacionDetalleScreenState
    extends ConsumerState<CotizacionDetalleScreen> {
  CotizacionDetalleEntity? _cotizacion;
  bool _isLoading = true;
  String? _error;

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
      final cotizacion = await ref
          .read(cotizacionesRepositoryProvider)
          .getCotizacionDetalle(
            clienteId: user.clienteId,
            cotizacionId: widget.cotizacionId,
          );

      if (!mounted) return;
      setState(() {
        _cotizacion = cotizacion;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar detalle: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
  }

  /// Cantidad sin decimales si es entera, con decimales si no
  String _formatCantidad(double cantidad) {
    return cantidad == cantidad.truncateToDouble()
        ? cantidad.toInt().toString()
        : cantidad.toString();
  }

  String _origenLabel(String origen) {
    switch (origen) {
      case CotizacionOrigen.posInterno:
        return 'POS interno';
      case CotizacionOrigen.webPublica:
        return 'Web pública';
      default:
        return origen;
    }
  }

  /// Texto de vigencia según los días de validez
  String _vigenciaText(CotizacionDetalleEntity cotizacion) {
    if (cotizacion.diasValidez <= 0) return 'Vence hoy';
    if (cotizacion.diasValidez == 1) return '1 día restante';
    return '${cotizacion.diasValidez} días restantes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cotizacion?.numeroCotizacion ?? 'Detalle de Cotización'),
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
                      Text(_error!, textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadDetalle,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _cotizacion == null
                  ? const Center(child: Text('No se encontró la cotización'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información general
                          _buildGeneralInfo(),
                          SizedBox(height: 16.h),

                          // Detalles de productos
                          if (_cotizacion!.detalles.isNotEmpty) ...[
                            _buildSectionTitle('Productos'),
                            SizedBox(height: 8.h),
                            _buildDetallesSection(),
                            SizedBox(height: 16.h),
                          ],

                          // Resumen de montos
                          _buildMontosTotales(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildGeneralInfo() {
    final cotizacion = _cotizacion!;
    final estadoColor =
        cotizacion.estaVencida ? AppColors.danger : AppColors.success;
    final tieneIdentificacion = cotizacion.consumidorIdentificacion != null &&
        cotizacion.consumidorIdentificacion!.isNotEmpty;
    final tieneEmail =
        cotizacion.consumidorEmail != null && cotizacion.consumidorEmail!.isNotEmpty;
    final tieneTelefono = cotizacion.consumidorTelefono != null &&
        cotizacion.consumidorTelefono!.isNotEmpty;
    final tieneObservacion =
        cotizacion.observacion != null && cotizacion.observacion!.isNotEmpty;

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
                    cotizacion.estaVencida ? 'VENCIDA' : 'VIGENTE',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: estadoColor,
                    ),
                  ),
                ),
              ],
            ),
            if (!cotizacion.estaVencida) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Vigencia', _vigenciaText(cotizacion)),
            ],
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            _buildInfoRow('Cliente', cotizacion.consumidorNombre),
            if (tieneIdentificacion) ...[
              SizedBox(height: 8.h),
              _buildInfoRow(
                'Identificación',
                cotizacion.consumidorIdentificacion!,
              ),
            ],
            if (tieneEmail) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Email', cotizacion.consumidorEmail!),
            ],
            if (tieneTelefono) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('Teléfono', cotizacion.consumidorTelefono!),
            ],
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Fecha cotización',
              DateFormat('dd/MM/yyyy HH:mm')
                  .format(cotizacion.fechaCotizacion.toLocal()),
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              'Válida hasta',
              DateFormat('dd/MM/yyyy')
                  .format(cotizacion.fechaValidez.toLocal()),
            ),
            if (cotizacion.origen != null && cotizacion.origen!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow('Origen', _origenLabel(cotizacion.origen!)),
            ],
            if (tieneObservacion) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow('Observación', cotizacion.observacion!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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

  Widget _buildDetallesSection() {
    return Card(
      child: Column(
        children: _cotizacion!.detalles.asMap().entries.map((entry) {
          final index = entry.key;
          final detalle = entry.value;
          // La observación de línea solo se muestra si aporta algo distinto al nombre
          final mostrarObservacion = detalle.observacionLinea != null &&
              detalle.observacionLinea!.isNotEmpty &&
              detalle.observacionLinea != detalle.nombreProducto;

          return Column(
            children: [
              if (index > 0) Divider(height: 1.h, color: AppColors.grey300),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            detalle.nombreProducto,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatCurrency(detalle.totalLinea),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${_formatCantidad(detalle.cantidad)} x ${_formatCurrency(detalle.precioUnitario)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (detalle.descuentoValor > 0) ...[
                          SizedBox(width: 8.w),
                          Text(
                            'Desc: ${_formatCurrency(detalle.descuentoValor)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (mostrarObservacion) ...[
                      SizedBox(height: 4.h),
                      Text(
                        detalle.observacionLinea!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMontosTotales() {
    final cotizacion = _cotizacion!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildMontoRow(
              'Subtotal',
              cotizacion.subtotalSinImpuestos,
              isSubtotal: true,
            ),
            SizedBox(height: 8.h),
            _buildMontoRow(
              'Descuentos',
              cotizacion.totalDescuentos > 0 ? -cotizacion.totalDescuentos : 0,
              color: cotizacion.totalDescuentos > 0 ? AppColors.success : null,
            ),
            SizedBox(height: 8.h),
            _buildMontoRow('Impuestos', cotizacion.totalImpuestos),
            SizedBox(height: 12.h),
            Divider(height: 1.h, thickness: 2),
            SizedBox(height: 12.h),
            _buildMontoRow(
              'TOTAL',
              cotizacion.total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontoRow(
    String label,
    double valor, {
    bool isSubtotal = false,
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: color ??
                (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
          ),
        ),
        Text(
          _formatCurrency(valor),
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: color ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
