import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme_config.dart';
import '../widgets/arqueo_reporte_tab.dart';
import '../widgets/costo_beneficio_reporte_tab.dart';
import '../widgets/inventario_reporte_tab.dart';
import '../widgets/stock_reporte_tab.dart';
import '../widgets/venta_detalle_reporte_tab.dart';
import '../widgets/ventas_reporte_tab.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Ventas'),
            Tab(text: 'Venta Detallada'),
            Tab(text: 'Inventario'),
            Tab(text: 'Arqueo Caja'),
            Tab(text: 'Stock'),
            Tab(text: 'Costo-Beneficio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VentasReporteTab(),
          VentaDetalleReporteTab(),
          InventarioReporteTab(),
          ArqueoReporteTab(),
          StockReporteTab(),
          CostoBeneficioReporteTab(),
        ],
      ),
    );
  }
}
