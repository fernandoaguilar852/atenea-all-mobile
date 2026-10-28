import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/theme_config.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/movimientos/presentation/screens/movimientos_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/chat/widgets/chat_widget.dart';
import '../../shared/widgets/app_drawer.dart';
import '../providers/navigation_provider.dart';
import 'facturas_screen.dart';

/// Pantalla principal con BottomNavigationBar estilo Instagram
/// Contiene 5 secciones: Facturas, Movimientos, Dashboard (centro), Reportes, Chat IA
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenIndexProvider);
    final movimientosKey = GlobalKey<ConsumerState<MovimientosScreen>>();

    final screens = [
      const FacturasScreen(),
      MovimientosScreen(key: movimientosKey, showScaffold: false),
      const DashboardScreen(showScaffold: false),
      const ReportesScreen(showScaffold: false),
    ];

    final titles = const [
      'Facturas',
      'Movimientos de Inventario',
      'Dashboard',
      'Reportes',
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        actions: currentIndex == 2
            ? [
                // Notificaciones solo en Dashboard
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications
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
          currentIndex: currentIndex,
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
