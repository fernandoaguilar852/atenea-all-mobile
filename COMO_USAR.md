# 🚀 ATENEA POS Mobile - Cómo Usar

## Ejecutar la App

### Opción 1: Desde Terminal

```bash
cd /Users/fernandoaguilarcamacho/Documents/ATENEA-ALL/atenea-all-mobile
flutter run
```

### Opción 2: Ver dispositivos disponibles y elegir uno

```bash
flutter devices
flutter run -d <device-id>
```

---

## 🔐 Credenciales de Prueba

```
Email: jfer_agui@hotmail.com
Password: Fer13720704
```

---

## 📱 Flujo de la Aplicación

### 1️⃣ Primera Pantalla - Login

Al abrir la app verás:
- Logo de ATENEA POS
- Campo de Email
- Campo de Password (con botón para mostrar/ocultar)
- Botón "Iniciar Sesión"
- Link "¿Olvidaste tu contraseña?"

**Acciones**:
1. Ingresa el email: `jfer_agui@hotmail.com`
2. Ingresa la password: `Fer13720704`
3. Presiona "Iniciar Sesión"
4. La app mostrará un loading mientras se conecta al servidor
5. Si es exitoso → Dashboard
6. Si falla → Muestra mensaje de error

### 2️⃣ Segunda Pantalla - Dashboard

Verás:

**Welcome Card** (arriba con gradiente azul):
- Mensaje de bienvenida
- Tu nombre (Fernando Aguilar)
- Fecha actual

**KPIs Grid** (4 tarjetas):
- 📈 Ventas Hoy: $0.00
- 📅 Ventas Mes: $0.00
- 📦 Productos: 0
- 👥 Clientes: 0

**Quick Actions** (4 botones con iconos):
- 💳 Punto de Venta
- 📦 Productos
- 👥 Clientes
- 📊 Reportes

**Actividad Reciente**:
- Lista vacía (se llenará con datos reales después)

**Botones de Acción**:
- 🔔 Notificaciones (arriba derecha)
- 🚪 Logout (arriba derecha)
- ➕ FAB "Nueva Venta" (botón flotante abajo)

**Acciones Disponibles**:
- Deslizar hacia abajo para refrescar (Pull to Refresh)
- Tocar Logout para cerrar sesión (aparece confirmación)

---

## ✅ MVP Completado

### Lo que FUNCIONA ahora:

✅ **Login**:
- Validación de formulario (email válido, password mínimo 6 caracteres)
- Conexión real al backend AWS
- Guardado seguro de tokens
- Manejo de errores con mensajes claros
- Loading states

✅ **Dashboard**:
- Muestra nombre de usuario real
- KPIs estructurados (listos para datos reales)
- Quick actions organizadas
- Navegación lista para expandir
- Logout funcional

✅ **Autenticación**:
- Session persistence (si cierras y abres la app, sigue logueado)
- Auto-refresh de tokens (transparente para el usuario)
- Logout limpia todo y regresa a login

✅ **UI/UX Profesional**:
- Diseño moderno con colores corporativos ATENEA
- Animaciones suaves
- Responsive (se adapta a diferentes tamaños de pantalla)
- Material Design 3

---

## 🔄 Flujos Completos

### Flujo de Login
```
1. Usuario abre app
2. App verifica si hay sesión guardada
   → Si hay sesión válida: ir a Dashboard
   → Si no hay sesión: mostrar Login
3. Usuario ingresa credenciales
4. Presiona "Iniciar Sesión"
5. App envía request a:
   POST https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod/v1/pos/login
6. Si exitoso:
   - Guarda tokens en storage seguro
   - Guarda datos de usuario
   - Navega a Dashboard
7. Si falla:
   - Muestra error específico
   - Usuario puede reintentar
```

### Flujo de Logout
```
1. Usuario presiona botón de Logout
2. Aparece diálogo de confirmación
3. Si confirma:
   - App llama endpoint de logout (backend)
   - Limpia todos los tokens y datos
   - Navega a Login
4. Si cancela:
   - Permanece en Dashboard
```

### Flujo de Auto-login
```
1. Usuario cierra la app
2. Al volver a abrirla:
   - App lee tokens de storage
   - Si encuentra tokens válidos:
     → Carga datos de usuario
     → Navega directo a Dashboard
   - Si no encuentra tokens:
     → Muestra Login
```

---

## 🎯 Próximos Pasos (No implementados aún)

Los siguientes elementos están en la UI pero no funcionales todavía:

❌ "¿Olvidaste tu contraseña?" - Ir a pantalla de recuperación
❌ Quick Actions - Navegar a módulos (POS, Productos, Clientes, Reportes)
❌ FAB "Nueva Venta" - Abrir módulo POS
❌ KPIs con datos reales - Conectar con API de reportes
❌ Actividad Reciente - Mostrar transacciones reales
❌ Pull to Refresh - Actualizar datos del dashboard

---

## 🔧 Comandos Rápidos

```bash
# Ejecutar app
flutter run

# Ver dispositivos
flutter devices

# Hot reload (mientras corre)
Presiona 'r' en terminal

# Hot restart
Presiona 'R' en terminal

# Detener app
Presiona 'q' en terminal

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

---

## 📞 Si Algo Falla

### Error: No se puede conectar
- Verificar conexión a internet
- Verificar que el backend esté activo
- Ver logs en consola para detalles

### Error: Credenciales incorrectas
- Verificar email: `jfer_agui@hotmail.com`
- Verificar password: `Fer13720704`
- Verificar que no haya espacios extras

### Error: App no compila
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

**¡Listo para usar!** 🎉

La app está completamente funcional para login y ver el dashboard.
