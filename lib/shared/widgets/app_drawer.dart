import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/theme_config.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          // Header del Drawer con info del usuario
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.person,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
            accountName: Text(
              user?.nombre ?? 'Usuario',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isSelected: currentRoute == '/',
                  onTap: () {
                    Navigator.pop(context); // Cerrar drawer
                    if (currentRoute != '/') {
                      context.go('/');
                    }
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Reportes',
                  isSelected: currentRoute == '/reportes',
                  onTap: () {
                    Navigator.pop(context); // Cerrar drawer
                    if (currentRoute != '/reportes') {
                      context.push('/reportes');
                    }
                  },
                ),
                Divider(height: 1.h, color: AppColors.grey300),
                _DrawerItem(
                  icon: Icons.point_of_sale,
                  title: 'Punto de Venta',
                  isDisabled: true,
                  onTap: () {
                    // TODO: Implementar navegación a POS
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Módulo en desarrollo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Productos',
                  isDisabled: true,
                  onTap: () {
                    // TODO: Implementar navegación a Productos
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Módulo en desarrollo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  title: 'Clientes',
                  isDisabled: true,
                  onTap: () {
                    // TODO: Implementar navegación a Clientes
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Módulo en desarrollo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer con Cerrar Sesión
          Divider(height: 1.h, color: AppColors.grey300),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            textColor: AppColors.danger,
            iconColor: AppColors.danger,
            onTap: () async {
              Navigator.pop(context); // Cerrar drawer

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Salir',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
              }
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isDisabled;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.isDisabled = false,
    this.textColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = isDisabled
        ? AppColors.grey400
        : (textColor ?? (isSelected ? AppColors.primary : AppColors.textPrimary));

    final effectiveIconColor = isDisabled
        ? AppColors.grey400
        : (iconColor ?? (isSelected ? AppColors.primary : AppColors.textSecondary));

    return ListTile(
      leading: Icon(
        icon,
        color: effectiveIconColor,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: effectiveTextColor,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      onTap: isDisabled ? null : onTap,
      trailing: isDisabled
          ? Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.grey400,
              ),
            )
          : null,
    );
  }
}
