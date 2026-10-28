import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/config/theme_config.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/movimientos/presentation/screens/movimientos_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/chat/widgets/chat_widget.dart';
import '../../shared/widgets/app_drawer.dart';
import 'facturas_screen.dart';

/// Pantalla principal con BottomNavigationBar estilo Instagram
/// Contiene 5 secciones: Facturas, Movimientos, Dashboard (centro), Reportes, Chat IA
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Empezar en Dashboard

  final List<Widget> _screens = const [
    FacturasScreen(),
    MovimientosScreen(showScaffold: false),
    DashboardScreen(showScaffold: false),
    ReportesScreen(showScaffold: false),
  ];

  final List<String> _titles = const [
    'Facturas',
    'Movimientos de Inventario',
    'Dashboard',
    'Reportes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: _currentIndex == 2
            ? [
                // Notificaciones solo en Dashboard
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
              ]
            : _currentIndex == 1
                ? [
                    // Botón agregar en Movimientos
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Implementar diálogo de agregar movimiento
                      },
                    ),
                  ]
                : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 4) {
              // Abrir ChatDialog en lugar de cambiar de pantalla
              showDialog(
                context: context,
                builder: (context) => const ChatDialog(),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
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
                  gradient: _currentIndex == 2
                      ? AppColors.primaryGradient
                      : null,
                  color: _currentIndex == 2
                      ? null
                      : AppColors.grey300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home,
                  size: 24.sp,
                  color: _currentIndex == 2
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
