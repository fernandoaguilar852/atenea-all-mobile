import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/venta_entity.dart';
import '../providers/ventas_provider.dart';
import '../../data/models/pago_model.dart';
import '../../data/mappers/venta_mapper.dart';

class VentaDetalleScreen extends ConsumerStatefulWidget {
  final int ventaId;

  const VentaDetalleScreen({super.key, required this.ventaId});

  @override
  ConsumerState<VentaDetalleScreen> createState() => _VentaDetalleScreenState();
}

class _VentaDetalleScreenState extends ConsumerState<VentaDetalleScreen> {
  VentaEntity? _venta;
  bool _isLoading = true;
  String? _error;
  Map<int, PagoModel> _metodoPagos = {}; // pagoId -> PagoModel

  @override
  void initState() {
    super.initState();
    _loadVentaCompleta();
  }

  Future<void> _loadVentaCompleta() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var venta = await ref
          .read(ventasRepositoryProvider)
          .getVentaCompleta(clienteId: user.clienteId, ventaId: widget.ventaId);

      // Cargar consumidor completo si existe pero no tiene dirección/teléfono
      if (venta.consumidorId != null &&
          (venta.consumidor == null ||
           venta.consumidor!.direccion == null)) {
        try {
          final consumidorDatasource = ref.read(consumidoresRemoteDatasourceProvider);
          final consumidorCompleto = await consumidorDatasource.getConsumidorById(
            clienteId: user.clienteId,
            consumidorId: venta.consumidorId!,
          );

          // Actualizar la venta con el consumidor completo
          final consumidorEntity = VentaMapper.toConsumidorEntity(consumidorCompleto);
          venta = VentaEntity(
            ventaId: venta.ventaId,
            clienteId: venta.clienteId,
            consumidorId: venta.consumidorId,
            consumidorNombre: consumidorEntity?.nombreRazonSocial,
            consumidor: consumidorEntity,
            cajaId: venta.cajaId,
            ordenServicioId: venta.ordenServicioId,
            formaPagoId: venta.formaPagoId,
            formaPagoNombre: venta.formaPagoNombre,
            formaPagoTipo: venta.formaPagoTipo,
            fechaVencimiento: venta.fechaVencimiento,
            codigoVoucher: venta.codigoVoucher,
            subtotalSinImpuestos: venta.subtotalSinImpuestos,
            totalDescuentos: venta.totalDescuentos,
            totalImpuestos: venta.totalImpuestos,
            totalIva: venta.totalIva,
            totalInc: venta.totalInc,
            totalIca: venta.totalIca,
            total: venta.total,
            porcentajeFinanciamiento: venta.porcentajeFinanciamiento,
            valorFinanciamiento: venta.valorFinanciamiento,
            estado: venta.estado,
            observacion: venta.observacion,
            tipoDocumento: venta.tipoDocumento,
            prefijoFactura: venta.prefijoFactura,
            numeroFactura: venta.numeroFactura,
            fechaEmision: venta.fechaEmision,
            cufe: venta.cufe,
            qrCode: venta.qrCode,
            estadoDian: venta.estadoDian,
            dianTrackId: venta.dianTrackId,
            createdAt: venta.createdAt,
            pagos: venta.pagos,
            detalles: venta.detalles,
          );
        } catch (e) {
          debugPrint('Error al cargar consumidor completo: $e');
        }
      }

      // Cargar métodos de pago para cada pago registrado
      if (venta.pagos != null && venta.pagos!.isNotEmpty) {
        final pagosDatasource = ref.read(pagosRemoteDatasourceProvider);
        final metodoPagosTemp = <int, PagoModel>{};

        for (final pago in venta.pagos!) {
          try {
            final metodoPago = await pagosDatasource.getPagoById(pago.pagoId);
            metodoPagosTemp[pago.pagoId] = metodoPago;
          } catch (e) {
            // Si falla la carga de un método de pago, continuar con los demás
            debugPrint('Error al cargar método de pago ${pago.pagoId}: $e');
          }
        }

        setState(() {
          _venta = venta;
          _metodoPagos = metodoPagosTemp;
          _isLoading = false;
        });
      } else {
        setState(() {
          _venta = venta;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar detalle: $e';
        _isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
        return AppColors.success;
      case 'pendiente':
        return AppColors.warning;
      case 'anulada':
        return AppColors.danger;
      default:
        return AppColors.grey400;
    }
  }

  String _getMetodoPagoNombre(int pagoId) {
    final metodoPago = _metodoPagos[pagoId];
    if (metodoPago != null) {
      // Convertir snake_case a formato legible
      final metodo = metodoPago.metodo
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
      return metodo;
    }
    return 'Pago #$pagoId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_venta?.numeroCompletoFactura ?? 'Detalle de Venta'),
        actions: [
          if (_venta != null && !_venta!.esAnulada)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Anular venta',
              onPressed: () {
                // TODO: Implementar anular venta
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de anular venta próximamente'),
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: AppColors.danger),
                      SizedBox(height: 16.h),
                      Text(_error!, textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadVentaCompleta,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _venta == null
                  ? const Center(child: Text('No se encontró la venta'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información general
                          _buildGeneralInfo(),
                          SizedBox(height: 16.h),

                          // Detalles de productos
                          if (_venta!.detalles != null && _venta!.detalles!.isNotEmpty) ...[
                            _buildSectionTitle('Productos'),
                            SizedBox(height: 8.h),
                            _buildDetallesSection(),
                            SizedBox(height: 16.h),
                          ],

                          // Resumen de montos
                          _buildMontosTotales(),
                          SizedBox(height: 16.h),

                          // Pagos
                          if (_venta!.pagos != null && _venta!.pagos!.isNotEmpty) ...[
                            _buildSectionTitle('Pagos Registrados'),
                            SizedBox(height: 8.h),
                            _buildPagosSection(),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildGeneralInfo() {
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
                    color: _getEstadoColor(_venta!.estado).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _venta!.estado.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getEstadoColor(_venta!.estado),
                    ),
                  ),
                ),
              ],
            ),
            if (_venta!.consumidor != null) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow('Cliente', _venta!.consumidor!.nombreRazonSocial),
              SizedBox(height: 8.h),
              _buildInfoRow(
                _venta!.consumidor!.tipoIdentificacion,
                _venta!.consumidor!.numeroIdentificacion,
              ),
              if (_venta!.consumidor!.direccion != null) ...[
                SizedBox(height: 8.h),
                _buildInfoRow('Dirección', _venta!.consumidor!.direccion!),
              ],
              if (_venta!.consumidor!.telefono != null) ...[
                SizedBox(height: 8.h),
                _buildInfoRow('Teléfono', _venta!.consumidor!.telefono!),
              ],
            ],
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Fecha emisión',
              DateFormat('dd/MM/yyyy HH:mm').format(_venta!.createdAt),
            ),
            if (_venta!.formaPagoNombre != null) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow('Forma de pago', _venta!.formaPagoNombre!),
            ],
            if (_venta!.formaPagoTipo == 'CREDITO' && _venta!.fechaVencimiento != null) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Fecha vencimiento',
                DateFormat('dd/MM/yyyy').format(_venta!.fechaVencimiento!),
              ),
            ],
            if (_venta!.observacion != null) ...[
              SizedBox(height: 12.h),
              Divider(height: 1.h),
              SizedBox(height: 12.h),
              _buildInfoRow('Observación', _venta!.observacion!),
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
        children: _venta!.detalles!.asMap().entries.map((entry) {
          final index = entry.key;
          final detalle = entry.value;
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
                            detalle.productoNombre,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                              .format(detalle.totalLinea),
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
                          '${detalle.cantidad.toStringAsFixed(0)} x ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(detalle.precioUnitario)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (detalle.descuentoValor > 0) ...[
                          SizedBox(width: 8.w),
                          Text(
                            'Desc: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(detalle.descuentoValor)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildMontoRow(
              'Subtotal',
              _venta!.subtotalSinImpuestos,
              isSubtotal: true,
            ),
            if (_venta!.totalDescuentos > 0) ...[
              SizedBox(height: 8.h),
              _buildMontoRow(
                'Descuentos',
                -_venta!.totalDescuentos,
                color: AppColors.success,
              ),
            ],
            if (_venta!.totalImpuestos > 0) ...[
              SizedBox(height: 8.h),
              _buildMontoRow('Impuestos', _venta!.totalImpuestos),
            ],
            if (_venta!.porcentajeFinanciamiento > 0) ...[
              SizedBox(height: 8.h),
              _buildMontoRow(
                'Financiamiento (${_venta!.porcentajeFinanciamiento.toStringAsFixed(2)}%)',
                _venta!.valorFinanciamiento,
              ),
            ],
            SizedBox(height: 12.h),
            Divider(height: 1.h, thickness: 2),
            SizedBox(height: 12.h),
            _buildMontoRow(
              'TOTAL',
              _venta!.total,
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
            color: color ?? (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(valor),
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: color ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPagosSection() {
    double totalPagado = _venta!.pagos!.fold(0, (sum, pago) => sum + pago.valor);

    return Card(
      child: Column(
        children: [
          ..._venta!.pagos!.asMap().entries.map((entry) {
            final index = entry.key;
            final pago = entry.value;
            return Column(
              children: [
                if (index > 0) Divider(height: 1.h, color: AppColors.grey300),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getMetodoPagoNombre(pago.pagoId),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (pago.numeroComprobante != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'Comprobante: ${pago.numeroComprobante}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(pago.createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(pago.valor),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          Divider(height: 1.h, thickness: 2, color: AppColors.grey400),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total pagado',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                      .format(totalPagado),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          if (totalPagado < _venta!.total) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo pendiente',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                        .format(_venta!.total - totalPagado),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
