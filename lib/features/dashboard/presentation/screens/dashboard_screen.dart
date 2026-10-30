import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../chat/widgets/chat_widget.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../../data/models/dashboard_stats.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const DashboardScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al iniciar
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadStats());
  }

  // Método público para recargar desde fuera
  void reloadData() {
    final user = ref.read(currentUserProvider);
    final clienteId = user?.clienteId ?? 0;

    // Recargar estadísticas del dashboard
    ref.read(dashboardProvider.notifier).loadStats();

    // Recargar notificaciones si hay clienteId válido
    if (clienteId > 0) {
      ref.read(notificacionesProvider(clienteId).notifier).fetchPendientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final dashboardState = ref.watch(dashboardProvider);

    final bodyContent = RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _WelcomeCard(userName: user?.nombre ?? 'Usuario'),

              SizedBox(height: AppSpacing.lg),

              // KPIs Grid
              dashboardState.isLoading && dashboardState.stats == null
                  ? const Center(child: CircularProgressIndicator())
                  : _KPIsGrid(stats: dashboardState.stats),

              SizedBox(height: AppSpacing.lg),

              // Quick Actions
              Text(
                'Accesos Rápidos',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _QuickActionsGrid(),

              SizedBox(height: AppSpacing.lg),

              // Recent Activity
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _RecentActivityList(),
            ],
          ),
        ),
      );

    if (!widget.showScaffold) {
      return bodyContent;
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: bodyContent,
      floatingActionButton: Stack(
        children: [
          // Chat IA Button
          const ChatFloatingButton(),

          // Nueva Venta Button
          Positioned(
            right: 0,
            bottom: 80.h,
            child: FloatingActionButton.extended(
              heroTag: 'nueva_venta_fab',
              onPressed: () {
                // TODO: Navigate to POS
              },
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Nueva Venta'),
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String userName;

  const _WelcomeCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary, // Flat: fondo sólido en vez de gradient
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido!',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withValues(alpha: 0.9),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              fontFamily: 'Inter',
              height: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14.sp,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KPIsGrid extends ConsumerWidget {
  final DashboardStats? stats;

  const _KPIsGrid({this.stats});

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return format.format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = stats ?? DashboardStats.empty();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.5,
      children: [
        _KPICard(
          title: 'Ventas Hoy',
          value: _formatCurrency(data.ventasDia),
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
        _KPICard(
          title: 'Facturas Hoy',
          value: '${data.cantidadFacturas}',
          icon: Icons.receipt_long,
          color: AppColors.primary,
        ),
        _KPICard(
          title: 'Ingresos',
          value: _formatCurrency(data.totalIngresos),
          icon: Icons.attach_money,
          color: AppColors.info,
        ),
        _KPICard(
          title: 'Gastos',
          value: _formatCurrency(data.totalGastos),
          icon: Icons.money_off,
          color: AppColors.danger,
        ),
        _KPICard(
          title: 'Alertas',
          value: '${data.cantidadAlertas}',
          icon: Icons.notifications_active,
          color: data.cantidadAlertas > 0 ? AppColors.warning : AppColors.grey400,
          onTap: () {
            // Cambiar al index 4 (AlertasStockScreen) en el MainScreen
            ref.read(mainScreenIndexProvider.notifier).state = 4;
          },
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                  height: 1.2,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Solo hacer clickeable si tiene onTap
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Punto de Venta',
        icon: Icons.point_of_sale,
        color: AppColors.primary,
        onTap: () {
          // TODO: Navigate to POS
        },
      ),
      _QuickAction(
        title: 'Productos',
        icon: Icons.inventory_2_outlined,
        color: AppColors.success,
        onTap: () {
          // TODO: Navigate to Products
        },
      ),
      _QuickAction(
        title: 'Clientes',
        icon: Icons.people_outline,
        color: AppColors.info,
        onTap: () {
          // TODO: Navigate to Clients
        },
      ),
      _QuickAction(
        title: 'Reportes',
        icon: Icons.bar_chart,
        color: AppColors.warning,
        onTap: () {
          context.push('/reportes');
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.sp, // Iconos más grandes
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _ActivityItem(
            title: 'No hay actividad reciente',
            subtitle: 'Las ventas y transacciones aparecerán aquí',
            icon: Icons.info_outline,
            iconColor: AppColors.grey400,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
