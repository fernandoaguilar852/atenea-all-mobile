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
import '../../features/resoluciones/providers/resoluciones_provider.dart';
import '../../features/ventas/providers/ventas_provider.dart';
import '../../features/movimientos/providers/movimientos_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../core/events/auth_events.dart';
import '../../shared/widgets/app_drawer.dart';
import '../providers/navigation_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Pantalla principal con BottomNavigationBar estilo Instagram
/// Contiene 5 secciones: Facturas, Movimientos, Dashboard (centro), Reportes, Chat IA
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final movimientosKey = GlobalKey<ConsumerState<MovimientosScreen>>();
  final ventasKey = GlobalKey<ConsumerState<VentasScreen>>();
  final dashboardKey = GlobalKey<ConsumerState<DashboardScreen>>();
  final resolucionesKey = GlobalKey<ConsumerState<ResolucionesScreen>>();
  final alertasStockKey = GlobalKey<ConsumerState<AlertasStockScreen>>();
  StreamSubscription<void>? _unauthorizedSubscription;

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

    // Escuchar eventos de sesión no autorizada
    _unauthorizedSubscription = AuthEvents().onUnauthorized.listen((_) {
      // Ejecutar logout y navegar al login
      ref.read(authProvider.notifier).logout().then((_) {
        if (mounted) {
          context.go('/login');
        }
      });
    });
  }

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainScreenIndexProvider);
    final currentUser = ref.watch(currentUserProvider);
    final clienteId = currentUser?.clienteId ?? 0;

    // Escuchar cambios en el índice de navegación
    ref.listen<int>(mainScreenIndexProvider, (previous, next) {
      // Recargar datos cuando se navega a una vista
      if (clienteId <= 0) return;

      switch (next) {
        case 0: // Ventas/Facturas
          final ventasState = ventasKey.currentState;
          if (ventasState != null && ventasState.mounted) {
            (ventasState as dynamic).reloadData();
          }
          break;
        case 1: // Movimientos
          final movimientosState = movimientosKey.currentState;
          if (movimientosState != null && movimientosState.mounted) {
            (movimientosState as dynamic).reloadData();
          }
          break;
        case 2: // Dashboard
          final dashboardState = dashboardKey.currentState;
          if (dashboardState != null && dashboardState.mounted) {
            (dashboardState as dynamic).reloadData();
          }
          break;
        case 3: // Reportes
          // Los reportes recargan individualmente cuando se selecciona cada tab
          break;
        case 4: // Alertas Stock
          final alertasStockState = alertasStockKey.currentState;
          if (alertasStockState != null && alertasStockState.mounted) {
            (alertasStockState as dynamic).reloadData();
          }
          break;
        case 5: // Resoluciones
          final resolucionesState = resolucionesKey.currentState;
          if (resolucionesState != null && resolucionesState.mounted) {
            (resolucionesState as dynamic).reloadData();
          }
          break;
      }
    });

    final screens = [
      VentasScreen(key: ventasKey, showScaffold: false),
      MovimientosScreen(key: movimientosKey, showScaffold: false),
      DashboardScreen(key: dashboardKey, showScaffold: false),
      const ReportesScreen(showScaffold: false),
      AlertasStockScreen(key: alertasStockKey),
      ResolucionesScreen(key: resolucionesKey, showScaffold: false),
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
