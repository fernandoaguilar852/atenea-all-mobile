import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../widgets/arqueo_reporte_tab.dart';
import '../widgets/costo_beneficio_reporte_tab.dart';
import '../widgets/inventario_reporte_tab.dart';
import '../widgets/stock_reporte_tab.dart';
import '../widgets/venta_detalle_reporte_tab.dart';
import '../widgets/ventas_reporte_tab.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const ReportesScreen({super.key, this.showScaffold = true});

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
    final tabBar = TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_cart, size: 20),
              text: 'Ventas',
            ),
            Tab(
              icon: Icon(Icons.receipt_long, size: 20),
              text: 'Venta Detallada',
            ),
            Tab(
              icon: Icon(Icons.inventory, size: 20),
              text: 'Consumo de Inventario',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet, size: 20),
              text: 'Arqueo Caja',
            ),
            Tab(
              icon: Icon(Icons.warehouse, size: 20),
              text: 'Stock',
            ),
            Tab(
              icon: Icon(Icons.analytics, size: 20),
              text: 'Costo-Beneficio',
            ),
          ],
        );

    final bodyContent = TabBarView(
        controller: _tabController,
        children: const [
          VentasReporteTab(),
          VentaDetalleReporteTab(),
          InventarioReporteTab(),
          ArqueoReporteTab(),
          StockReporteTab(),
          CostoBeneficioReporteTab(),
        ],
      );

    if (!widget.showScaffold) {
      return Column(
        children: [
          Container(
            color: AppColors.primary,
            child: tabBar,
          ),
          Expanded(child: bodyContent),
        ],
      );
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reportes'),
        bottom: tabBar,
      ),
      body: bodyContent,
    );
  }
}
