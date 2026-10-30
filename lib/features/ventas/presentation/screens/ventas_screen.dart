import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/venta_entity.dart';
import '../providers/ventas_provider.dart';
import '../../data/models/venta_model.dart';
import 'venta_detalle_screen.dart';

class VentasScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const VentasScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends ConsumerState<VentasScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filtros
  String? _estadoFilter;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  int? _consumidorIdFilter;
  String? _consumidorNombreFilter;

  // Búsqueda de consumidores
  final TextEditingController _searchController = TextEditingController();
  List<ConsumidorModel> _consumidoresEncontrados = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha actual por defecto
    final now = DateTime.now();
    _fechaDesde = DateTime(now.year, now.month, now.day);
    _fechaHasta = DateTime(now.year, now.month, now.day, 23, 59, 59);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(ventasProvider.notifier).loadVentas(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          estado: _estadoFilter,
          consumidorId: _consumidorIdFilter,
          startDate: _fechaDesde,
          endDate: _fechaHasta,
        );
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
  }

  void _buscarConsumidores(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.length < 3) {
      setState(() {
        _consumidoresEncontrados = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      setState(() {
        _isSearching = true;
      });

      try {
        final consumidoresDatasource = ref.read(consumidoresRemoteDatasourceProvider);
        final result = await consumidoresDatasource.searchConsumidores(
          clienteId: user.clienteId,
          search: query,
          pageSize: 10,
          pageNumber: 1,
        );

        setState(() {
          _consumidoresEncontrados = result.data;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _consumidoresEncontrados = [];
          _isSearching = false;
        });
        debugPrint('Error al buscar consumidores: $e');
      }
    });
  }

  void _seleccionarConsumidor(ConsumidorModel? consumidor) {
    setState(() {
      if (consumidor != null) {
        _consumidorIdFilter = consumidor.consumidorId;
        _consumidorNombreFilter = consumidor.nombreRazonSocial;
        _searchController.text = consumidor.nombreRazonSocial;
      } else {
        _consumidorIdFilter = null;
        _consumidorNombreFilter = null;
        _searchController.clear();
      }
      _consumidoresEncontrados = [];
      _currentPage = 1;
    });
    _loadData();
  }

  void _limpiarFiltros() {
    final now = DateTime.now();
    setState(() {
      _estadoFilter = null;
      _fechaDesde = DateTime(now.year, now.month, now.day);
      _fechaHasta = DateTime(now.year, now.month, now.day, 23, 59, 59);
      _consumidorIdFilter = null;
      _consumidorNombreFilter = null;
      _searchController.clear();
      _consumidoresEncontrados = [];
      _currentPage = 1;
    });
    _loadData();
  }

  bool get _tieneFiltrosActivos {
    final now = DateTime.now();
    final hoyInicio = DateTime(now.year, now.month, now.day);
    final hoyFin = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final fechasModificadas = _fechaDesde?.year != hoyInicio.year ||
        _fechaDesde?.month != hoyInicio.month ||
        _fechaDesde?.day != hoyInicio.day ||
        _fechaHasta?.year != hoyFin.year ||
        _fechaHasta?.month != hoyFin.month ||
        _fechaHasta?.day != hoyFin.day;

    return _estadoFilter != null || fechasModificadas || _consumidorIdFilter != null;
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);

    final bodyContent = Column(
      children: [
        // Filtros
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          color: AppColors.surfaceVariant,
          child: Column(
            children: [
              // Filtro por estado
              DropdownButtonFormField<String>(
                value: _estadoFilter,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'pendiente',
                    child: Text('Pendiente'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'pagada',
                    child: Text('Pagada'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'anulada',
                    child: Text('Anulada'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _estadoFilter = value;
                    _currentPage = 1;
                  });
                  _loadData();
                },
              ),
              SizedBox(height: AppSpacing.md),

              // Filtro de rango de fechas
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: DateTimeRange(start: _fechaDesde!, end: _fechaHasta!),
                  );

                  if (picked != null) {
                    setState(() {
                      _fechaDesde = picked.start;
                      _fechaHasta = picked.end;
                      _currentPage = 1;
                    });
                    _loadData();
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Rango de Fechas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${DateFormat('dd/MM/yyyy').format(_fechaDesde!)} - ${DateFormat('dd/MM/yyyy').format(_fechaHasta!)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Búsqueda de consumidores
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar cliente',
                      hintText: 'Digite al menos 3 caracteres...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _consumidorIdFilter != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _seleccionarConsumidor(null),
                            )
                          : _isSearching
                              ? Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                    ),
                    onChanged: _buscarConsumidores,
                    enabled: _consumidorIdFilter == null,
                  ),
                  if (_consumidoresEncontrados.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.borderMedium,
                          width: 1,
                        ),
                      ),
                      constraints: BoxConstraints(maxHeight: 200.h),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _consumidoresEncontrados.length,
                        separatorBuilder: (_, __) => Divider(height: 1.h),
                        itemBuilder: (context, index) {
                          final consumidor = _consumidoresEncontrados[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              consumidor.nombreRazonSocial,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                            subtitle: Text(
                              '${consumidor.tipoIdentificacion}: ${consumidor.numeroIdentificacion}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter',
                              ),
                            ),
                            onTap: () => _seleccionarConsumidor(consumidor),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              // Botón limpiar filtros
              if (_tieneFiltrosActivos) ...[
                SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpiar filtros'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Lista de ventas
        Expanded(
          child: ventasState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ventasState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48.sp, color: AppColors.danger),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            ventasState.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : ventasState.ventas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 64.sp, color: AppColors.grey300),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'No hay ventas para mostrar',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.all(AppSpacing.md),
                                itemCount: ventasState.ventas.length,
                                itemBuilder: (context, index) {
                                  final venta = ventasState.ventas[index];
                                  return _VentaCard(venta: venta);
                                },
                              ),
                            ),
                            // Controles de paginación
                            if (ventasState.totalElements > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Información de paginación
                                    Text(
                                      'Mostrando ${ventasState.ventas.length} de ${ventasState.totalElements}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    // Botones de navegación
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: _currentPage > 1
                                              ? () {
                                                  setState(() {
                                                    _currentPage--;
                                                  });
                                                  _loadData();
                                                }
                                              : null,
                                          iconSize: 24.sp,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.sm,
                                            ),
                                            border: Border.all(
                                              color: AppColors.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            'Pág. $_currentPage',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: ventasState.hasMoreElements
                                              ? () {
                                                  setState(() {
                                                    _currentPage++;
                                                  });
                                                  _loadData();
                                                }
                                              : null,
                                          iconSize: 24.sp,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
        ),
      ],
    );

    if (!widget.showScaffold) {
      return bodyContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas / Facturas'),
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada venta
class _VentaCard extends StatelessWidget {
  final VentaEntity venta;

  const _VentaCard({required this.venta});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VentaDetalleScreen(ventaId: venta.ventaId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con número de factura y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      venta.numeroCompletoFactura ?? 'Venta #${venta.ventaId}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(venta.estado).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      venta.estado.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _getEstadoColor(venta.estado),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Consumidor si existe
              if (venta.consumidorNombre != null) ...[
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16.sp, color: AppColors.grey600),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        venta.consumidorNombre!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
              ],

              // Fecha y Forma de Pago
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16.sp, color: AppColors.grey600),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(venta.createdAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  if (venta.formaPagoNombre != null) ...[
                    Icon(Icons.payment, size: 16.sp, color: AppColors.grey600),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      venta.formaPagoNombre!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: AppSpacing.md),
              Divider(height: 1.h, color: AppColors.borderColor),
              SizedBox(height: AppSpacing.md),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                        .format(venta.total),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
