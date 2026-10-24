# ✅ Menú Lateral (Drawer) Global - ATENEA Mobile

**Fecha:** 2026-10-23
**Funcionalidad:** Menú hamburguesa (☰) con navegación global

---

## 🎯 Implementación

### Nuevo Widget Creado:

**Archivo:** `lib/shared/widgets/app_drawer.dart`

### Características del Drawer:

✅ **Header con información del usuario:**
- Foto de perfil (avatar con icono)
- Nombre del usuario
- Email del usuario

✅ **Opciones de navegación:**
1. **Dashboard** - Navega a la pantalla principal
2. **Reportes** - Navega a los 6 reportes
3. **Punto de Venta** - (Deshabilitado - "Próximamente")
4. **Productos** - (Deshabilitado - "Próximamente")
5. **Clientes** - (Deshabilitado - "Próximamente")

✅ **Footer:**
- **Cerrar Sesión** - Con diálogo de confirmación

---

## 📱 Cómo Se Ve:

### Icono Hamburguesa (☰):
- **Ubicación:** Parte superior izquierda del AppBar
- **Acción:** Al tocar, se desliza el menú de izquierda a derecha

### Menú Lateral:
```
┌─────────────────────────┐
│ [👤]                    │
│ Nombre Usuario          │
│ email@example.com       │
├─────────────────────────┤
│ 🏠 Dashboard            │
│ 📊 Reportes            │
├─────────────────────────┤
│ 🛒 Punto de Venta      │ Próximamente
│ 📦 Productos           │ Próximamente
│ 👥 Clientes            │ Próximamente
├─────────────────────────┤
│ 🚪 Cerrar Sesión       │
└─────────────────────────┘
```

---

## 🔧 Archivos Modificados:

### 1. **CREADO:** `lib/shared/widgets/app_drawer.dart`

**Código Principal:**
```dart
class AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(...),

          // Opciones de menú
          Expanded(
            child: ListView(
              children: [
                _DrawerItem(icon: Icons.dashboard, title: 'Dashboard', ...),
                _DrawerItem(icon: Icons.bar_chart, title: 'Reportes', ...),
                // ... más opciones
              ],
            ),
          ),

          // Cerrar Sesión
          _DrawerItem(icon: Icons.logout, title: 'Cerrar Sesión', ...),
        ],
      ),
    );
  }
}
```

**Funcionalidades:**
- ✅ Resalta la opción activa (ruta actual)
- ✅ Deshabilita opciones no implementadas
- ✅ Muestra "Próximamente" en módulos pendientes
- ✅ Cierra el drawer automáticamente después de navegar
- ✅ Usa context.go('/') para Dashboard (reemplaza toda la pila)
- ✅ Usa context.push('/reportes') para otras rutas (agrega a la pila)

---

### 2. **MODIFICADO:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Cambios:**

#### Importación:
```dart
import '../../../../shared/widgets/app_drawer.dart';
```

#### Agregado al Scaffold:
```dart
Scaffold(
  drawer: const AppDrawer(),  // ← NUEVO
  appBar: AppBar(
    title: const Text('Dashboard'),
    // Botón de logout ELIMINADO (ahora está en el drawer)
    actions: [
      IconButton(icon: const Icon(Icons.notifications_outlined), ...),
    ],
  ),
  ...
)
```

**Antes:**
- AppBar tenía 2 botones: Notificaciones y Logout
- No había drawer

**Después:**
- AppBar tiene 1 botón: Notificaciones
- Logout movido al drawer
- Icono hamburguesa (☰) aparece automáticamente al agregar drawer

---

### 3. **MODIFICADO:** `lib/features/reportes/presentation/screens/reportes_screen.dart`

**Cambios:**

#### Importación:
```dart
import '../../../../shared/widgets/app_drawer.dart';
```

#### Agregado al Scaffold:
```dart
Scaffold(
  drawer: const AppDrawer(),  // ← NUEVO
  appBar: AppBar(
    title: const Text('Reportes'),
    bottom: TabBar(...),
  ),
  ...
)
```

**Beneficio:** Navegación consistente desde cualquier pantalla

---

## 🎨 Diseño y Estilos:

### Header del Drawer:
- **Fondo:** Gradiente primario (AppColors.primaryGradient)
- **Avatar:** Círculo blanco con icono de persona
- **Texto:** Blanco sobre gradiente

### Items del Menú:
- **Seleccionado:** Fondo azul claro + texto azul + negrita
- **Normal:** Fondo blanco + texto gris oscuro
- **Deshabilitado:** Texto gris claro + badge "Próximamente"
- **Cerrar Sesión:** Texto e icono rojo

### Interacciones:
- **Efecto Ripple:** Al tocar cada opción
- **Auto-cierre:** El drawer se cierra automáticamente al navegar
- **Diálogo de confirmación:** Al cerrar sesión

---

## 📊 Navegación Implementada:

### Dashboard → Reportes:
```dart
_DrawerItem(
  icon: Icons.bar_chart,
  title: 'Reportes',
  isSelected: currentRoute == '/reportes',
  onTap: () {
    Navigator.pop(context); // Cierra drawer
    if (currentRoute != '/reportes') {
      context.push('/reportes'); // Navega
    }
  },
)
```

### Reportes → Dashboard:
```dart
_DrawerItem(
  icon: Icons.dashboard,
  title: 'Dashboard',
  isSelected: currentRoute == '/',
  onTap: () {
    Navigator.pop(context); // Cierra drawer
    if (currentRoute != '/') {
      context.go('/'); // Navega (reemplaza pila)
    }
  },
)
```

---

## ⚠️ Módulos Pendientes:

Estos módulos aparecen en el drawer pero están deshabilitados:

1. **Punto de Venta**
   - Estado: 🟡 No implementado
   - Acción: Muestra SnackBar "Módulo en desarrollo"

2. **Productos**
   - Estado: 🟡 No implementado
   - Acción: Muestra SnackBar "Módulo en desarrollo"

3. **Clientes**
   - Estado: 🟡 No implementado
   - Acción: Muestra SnackBar "Módulo en desarrollo"

**Para implementarlos en el futuro:**
1. Crear las pantallas correspondientes
2. Agregar rutas en `router_config.dart`
3. En `app_drawer.dart`, cambiar `isDisabled: true` a `false`
4. Implementar la navegación real

---

## 🧪 Testing:

### Pasos para Probar:

1. **Abrir la app ATENEA**
2. **Hacer login**
3. **En el Dashboard:**
   - ✅ Ver icono hamburguesa (☰) arriba a la izquierda
   - ✅ Tocar el icono
   - ✅ Verificar que el drawer se desliza de izquierda a derecha
   - ✅ Ver nombre y email del usuario en el header
   - ✅ Ver "Dashboard" resaltado (opción actual)

4. **Tocar "Reportes":**
   - ✅ El drawer se cierra
   - ✅ Navega a la pantalla de Reportes
   - ✅ Ver los 6 tabs de reportes

5. **Abrir el drawer de nuevo (desde Reportes):**
   - ✅ Ver "Reportes" resaltado (opción actual)
   - ✅ Tocar "Dashboard"
   - ✅ Regresa al Dashboard

6. **Probar opciones deshabilitadas:**
   - ✅ Tocar "Punto de Venta"
   - ✅ Ver mensaje "Módulo en desarrollo"
   - ✅ El drawer se cierra

7. **Cerrar Sesión:**
   - ✅ Tocar "Cerrar Sesión" (opción roja al final)
   - ✅ Ver diálogo de confirmación
   - ✅ Tocar "Salir"
   - ✅ Regresa al Login

---

## 📱 Actualizar la App:

### Android (APK):
```bash
flutter build apk --debug
# Ubicación: build/app/outputs/flutter-apk/app-debug.apk
```

### iOS (iPhone 14):
```bash
# Conectar iPhone por USB
flutter run --release -d 00008120-000868600A87A01E
```

---

## 🔄 Consistencia Global:

El drawer está implementado en:
- ✅ Dashboard
- ✅ Reportes
- 🟡 POS (cuando se implemente)
- 🟡 Productos (cuando se implemente)
- 🟡 Clientes (cuando se implemente)

**Recomendación:** Al crear nuevas pantallas, siempre agregar:
```dart
Scaffold(
  drawer: const AppDrawer(),
  appBar: AppBar(...),
  body: ...,
)
```

---

## 📊 Comparación: Antes vs Después

### ANTES:
- ❌ Solo botón de Logout en AppBar
- ❌ No había menú lateral
- ❌ Navegación solo por botones en el Dashboard
- ❌ Desde Reportes, solo se podía regresar con botón back

### DESPUÉS:
- ✅ Menú lateral global en todas las pantallas
- ✅ Navegación rápida Dashboard ↔ Reportes
- ✅ Información del usuario siempre visible
- ✅ Cerrar Sesión accesible desde cualquier pantalla
- ✅ Preparado para futuros módulos (POS, Productos, Clientes)

---

## 🎯 Beneficios:

1. **UX Mejorada:**
   - Navegación más intuitiva y estándar
   - Acceso rápido a todas las secciones

2. **Consistencia:**
   - Mismo menú en todas las pantallas
   - Diseño uniforme

3. **Escalabilidad:**
   - Fácil agregar nuevas opciones
   - Widget reutilizable

4. **Información del Usuario:**
   - Siempre visible quién está usando la app
   - Contexto claro

5. **Mobile-First:**
   - Patrón estándar de navegación en apps móviles
   - Los usuarios conocen este patrón

---

## 🚀 Próximos Pasos:

1. **Probar el drawer en Android e iOS**
2. **Implementar módulos pendientes:**
   - Punto de Venta
   - Productos
   - Clientes
3. **Agregar drawer a futuras pantallas**
4. **Considerar agregar:**
   - Notificaciones en el drawer
   - Configuración/ajustes
   - Ayuda/soporte

---

**Estado:** ✅ COMPLETADO
**Probado:** ⏳ Pendiente
**Plataformas:** Android + iOS
**Widget:** Reutilizable y global
