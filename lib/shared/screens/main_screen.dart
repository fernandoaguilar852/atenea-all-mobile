import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/theme_config.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/movimientos/presentation/screens/movimientos_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/ventas/presentation/screens/ventas_screen.dart';
import '../../features/chat/widgets/chat_widget.dart';
import '../../features/notificaciones/presentation/widgets/notificaciones_drawer.dart';
import '../../features/notificaciones/presentation/providers/notificaciones_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/alertas_stock/presentation/screens/alertas_stock_screen.dart';
import '../../features/alertas_stock/presentation/providers/alertas_stock_provider.dart';
import '../../features/resoluciones/presentation/screens/resoluciones_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/widgets/app_drawer.dart';
import '../providers/navigation_provider.dart';

/// Pantalla principal con BottomNavigationBar estilo Instagram
/// Contiene 5 secciones: Facturas, Movimientos, Dashboard (centro), Reportes, Chat IA
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar notificaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      final clienteId = currentUser?.clienteId ?? 0;
      if (clienteId > 0) {
        ref
            .read(notificacionesProvider(clienteId).notifier)
            .fetchPendientes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainScreenIndexProvider);
    final movimientosKey = GlobalKey<ConsumerState<MovimientosScreen>>();
    final currentUser = ref.watch(currentUserProvider);
    final clienteId = currentUser?.clienteId ?? 0;

    // Escuchar cambios en el índice de navegación
    ref.listen<int>(mainScreenIndexProvider, (previous, next) {
      // Si cambiamos al Dashboard (index 2), recargar notificaciones y stats
      if (next == 2 && clienteId > 0) {
        ref
            .read(notificacionesProvider(clienteId).notifier)
            .fetchPendientes();
        ref
            .read(dashboardProvider.notifier)
            .loadStats();
      }
      // Si cambiamos a Alertas Stock (index 4), cargar alertas
      if (next == 4 && clienteId > 0) {
        ref
            .read(alertasStockProvider(clienteId).notifier)
            .fetchAlertas();
      }
    });

    final screens = [
      const VentasScreen(showScaffold: false),
      MovimientosScreen(key: movimientosKey, showScaffold: false),
      const DashboardScreen(showScaffold: false),
      const ReportesScreen(showScaffold: false),
      const AlertasStockScreen(),
      const ResolucionesScreen(showScaffold: false),
    ];

    final titles = const [
      'Facturas',
      'Movimientos de Inventario',
      'Dashboard',
      'Reportes',
      'Alertas de Stock',
      'Resoluciones',
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      endDrawer: clienteId > 0
          ? NotificacionesDrawer(clienteId: clienteId)
          : null,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        actions: currentIndex == 2
            ? [
                // Notificaciones solo en Dashboard
                Builder(
                  builder: (context) {
                    if (clienteId <= 0) {
                      return const SizedBox.shrink();
                    }

                    final notificacionesState =
                        ref.watch(notificacionesProvider(clienteId));

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                            // Refrescar notificaciones al abrir el drawer
                            ref
                                .read(notificacionesProvider(clienteId).notifier)
                                .fetchPendientes();
                          },
                        ),
                        if (notificacionesState.totalElement > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                notificacionesState.totalElement > 99
                                    ? '99+'
                                    : '${notificacionesState.totalElement}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ]
            : currentIndex == 1
                ? [
                    // Botón agregar en Movimientos
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final state = movimientosKey.currentState;
                        if (state != null && state.mounted) {
                          (state as dynamic).showMovimientoTypeSelector();
                        }
                      },
                    ),
                  ]
                : null,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: (currentIndex == 4 || currentIndex == 5) ? 2 : currentIndex,
          onTap: (index) {
            if (index == 4) {
              // Abrir ChatDialog en lugar de cambiar de pantalla
              showDialog(
                context: context,
                builder: (context) => const ChatDialog(),
              );
            } else {
              ref.read(mainScreenIndexProvider.notifier).state = index;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          selectedFontSize: 12.sp,
          unselectedFontSize: 11.sp,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11.sp,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, size: 24.sp),
              activeIcon: Icon(Icons.receipt_long, size: 26.sp),
              label: 'Facturas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.move_down, size: 24.sp),
              activeIcon: Icon(Icons.move_down, size: 26.sp),
              label: 'Movimientos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: currentIndex == 2
                      ? AppColors.primaryGradient
                      : null,
                  color: currentIndex == 2
                      ? null
                      : AppColors.grey300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home,
                  size: 24.sp,
                  color: currentIndex == 2
                      ? AppColors.white
                      : AppColors.grey600,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, size: 24.sp),
              activeIcon: Icon(Icons.bar_chart, size: 26.sp),
              label: 'Reportes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 24.sp),
              activeIcon: Icon(Icons.chat_bubble, size: 26.sp),
              label: 'Chat IA',
            ),
          ],
        ),
      ),
    );
  }
}
