# ATENEA POS Mobile - Implementación Inicial

## Estado del Proyecto

✅ **Fase 0 Completada**: Configuración Inicial
✅ **Fase 1 Parcial Completada**: Autenticación y Dashboard

---

## Estructura Implementada

### 1. Core (Núcleo)

#### ✅ Networking
- `lib/core/network/dio_client.dart` - Cliente HTTP con Dio
  - Interceptores de headers (UUID, App ID)
  - Interceptor de autenticación (Bearer token)
  - Manejo automático de refresh token en 401
  - Logger para debug (solo en modo desarrollo)

#### ✅ Storage
- `lib/core/storage/secure_storage.dart` - Storage seguro para tokens
  - Tokens de acceso y refresh
  - Datos de usuario
  - Configuraciones (tema, biométrico)
- `lib/core/storage/hive_storage.dart` - Storage local para caché
  - Cache box para datos temporales
  - Settings box para preferencias

#### ✅ Configuration
- `lib/core/config/theme_config.dart` - Tema profesional
  - Colores corporativos (#1E3A5F, #4A90A4)
  - Light theme completo
  - Dark theme base
  - Spacing, radius, shadows constants
- `lib/core/config/env_config.dart` - Variables de entorno
- `lib/core/config/router_config.dart` - Router con go_router
  - Redirección automática según estado de auth
  - Rutas protegidas

#### ✅ Constants
- `lib/core/constants/api_constants.dart` - URLs y endpoints
- `lib/core/constants/app_constants.dart` - Constantes generales
- `lib/core/constants/storage_keys.dart` - Keys de storage

#### ✅ Providers
- `lib/core/providers/dio_provider.dart` - Provider de Dio y SecureStorage

---

### 2. Auth Module (Completo)

#### ✅ Domain Layer
**Entities**:
- `user.dart` - Entidad de usuario con propiedades computed

**Repositories**:
- `auth_repository.dart` - Interfaz del repositorio

**Use Cases**:
- `login_usecase.dart` - Login
- `logout_usecase.dart` - Logout
- `get_current_user_usecase.dart` - Obtener usuario actual

#### ✅ Data Layer
**Models**:
- `user_model.dart` - Modelo JSON de usuario
- `login_request.dart` - Request de login
- `login_response.dart` - Response de login

**DataSources**:
- `auth_remote_datasource.dart` - Llamadas al API
  - Login, logout, refresh token
  - Forgot password, reset password
  - Change password, validate token
- `auth_local_datasource.dart` - Storage local de auth

**Repositories**:
- `auth_repository_impl.dart` - Implementación del repositorio

#### ✅ Presentation Layer
**Providers**:
- `auth_providers.dart` - Providers de Riverpod
  - DataSources providers
  - Repository provider
  - Use cases providers
  - AuthNotifier (state management)
  - Computed providers (isAuthenticated, currentUser)

**Screens**:
- `login_screen.dart` - Pantalla de login
  - Form validation
  - Error handling
  - Loading states
  - Professional UI con logo

---

### 3. Dashboard Module (Básico)

#### ✅ Presentation Layer
**Screens**:
- `dashboard_screen.dart` - Pantalla principal
  - Welcome card personalizada
  - KPIs grid (Ventas Hoy, Mes, Productos, Clientes)
  - Quick actions grid (POS, Productos, Clientes, Reportes)
  - Recent activity list
  - Pull to refresh
  - FAB para nueva venta
  - Logout con confirmación

---

### 4. Shared Widgets

#### ✅ Widgets Compartidos
- `lib/shared/widgets/app_text_field.dart` - Input personalizado
- `lib/shared/widgets/app_button.dart` - Botones (primary, secondary, outline, text)
- `lib/shared/widgets/app_loading.dart` - Loading indicator

---

## Flujo de Autenticación

### Login Flow
1. Usuario ingresa email y password
2. `LoginScreen` valida el formulario
3. `AuthNotifier.login()` se llama
4. `LoginUseCase` ejecuta la lógica
5. `AuthRepository` hace la llamada HTTP
6. Si es exitoso:
   - Tokens se guardan en SecureStorage
   - User data se guarda en SecureStorage
   - AuthState se actualiza con el usuario
   - Router redirige a `/` (Dashboard)
7. Si falla:
   - Error se muestra en la UI
   - State se actualiza con el error

### Auto-login Flow
1. App inicia
2. `AuthNotifier` ejecuta `checkAuth()` en el constructor
3. `GetCurrentUserUseCase` lee datos de SecureStorage
4. Si hay datos:
   - AuthState se actualiza con el usuario
   - Router permite acceso a rutas protegidas
5. Si no hay datos:
   - Router redirige a `/login`

### Logout Flow
1. Usuario toca botón de logout
2. Diálogo de confirmación aparece
3. Si confirma:
   - `AuthNotifier.logout()` se llama
   - `LogoutUseCase` ejecuta
   - Backend endpoint de logout se llama (opcional)
   - SecureStorage se limpia completamente
   - AuthState se resetea
   - Router redirige a `/login`

### Token Refresh Flow (Automático)
1. Request falla con 401
2. `AuthInterceptor` captura el error
3. Obtiene refreshToken de SecureStorage
4. Llama endpoint `/login/refresh-token`
5. Si es exitoso:
   - Guarda nuevos tokens
   - Reintenta request original
   - Usuario no nota nada
6. Si falla:
   - Limpia storage
   - Redirige a login
   - Usuario debe volver a autenticarse

---

## API Integration

### Base URL - API Gateway Global (Balanceador)
```
https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod
```

**Nota**: Este API Gateway actúa como balanceador global que invoca todos los endpoints de las lambdas.

**Ejemplo de URL completa**:
```
https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod/v1/pos/monedas?pageNumber=1&pageSize=10
```

### Headers Automáticos
```
Content-Type: application/json
message-uuid: {generated-uuid}
request-app-id: ATENEA-MOBILE-APP
Authorization: Bearer {access-token} (excepto en endpoints públicos)
```

### Endpoints Implementados

**Auth**:
- `POST /v1/pos/login` - Login
- `POST /v1/pos/login/refresh-token` - Refresh token
- `POST /v1/pos/login/logout` - Logout
- `POST /v1/pos/login/recuperar` - Forgot password
- `POST /v1/pos/login/reset-password-with-code` - Reset password
- `POST /v1/pos/login/cambiar-password` - Change password
- `GET /v1/pos/login/validar-token` - Validate token

---

## Cómo Ejecutar

### 1. Instalar Dependencias
```bash
cd /Users/fernandoaguilarcamacho/Documents/ATENEA-ALL/atenea-all-mobile
flutter pub get
```

### 2. Generar Código (si es necesario)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Ejecutar App
```bash
flutter run
```

### 4. Ejecutar en Modo Release
```bash
flutter run --release
```

### 5. Ejecutar Tests
```bash
flutter test
```

### 6. Analizar Código
```bash
flutter analyze
```

---

## Credenciales de Prueba

Según el frontend web, usar:
```
Email: jfer_agui@hotmail.com
Password: Fer13720704
```

---

## Siguientes Pasos (Fase 1 Continuación)

### Pendientes para completar MVP:

1. **Auth Module - Completar**:
   - [ ] Pantalla de Forgot Password
   - [ ] Pantalla de Reset Password
   - [ ] Pantalla de Change Password

2. **Dashboard - Completar**:
   - [ ] Integrar API de reportes para KPIs reales
   - [ ] Implementar refresh de datos
   - [ ] Actividad reciente real
   - [ ] Navegación a módulos desde quick actions

3. **POS Module** (Nueva funcionalidad):
   - [ ] Pantalla de POS
   - [ ] Búsqueda de productos
   - [ ] Carrito de compras
   - [ ] Procesamiento de venta
   - [ ] Selección de cliente
   - [ ] Formas de pago
   - [ ] Impresión de ticket (simulada)

4. **Caja Module** (Nueva funcionalidad):
   - [ ] Apertura de caja
   - [ ] Cierre de caja / Arqueo
   - [ ] Movimientos de caja
   - [ ] Estado actual de caja

---

## Problemas Conocidos

### ⚠️ Warnings
- `withOpacity` deprecated - Se puede actualizar a `withValues()` en el futuro
- No afecta funcionalidad

### ✅ Resueltos
- ✅ Imports no utilizados - Limpiados
- ✅ Test widget actualizado para nueva app structure

---

## Notas Técnicas

### State Management
- **Riverpod 2.x** para gestión de estado
- Patrón StateNotifier para estado mutable
- Providers computed para estado derivado
- Separación clara entre UI y lógica

### Arquitectura
- **Clean Architecture** en cada feature
- Separación en 3 capas (Data, Domain, Presentation)
- Inyección de dependencias con Riverpod
- Repository pattern para abstracción de datos

### Seguridad
- Tokens en FlutterSecureStorage (encriptado)
- Refresh automático de tokens
- Headers de seguridad en cada request
- Logout limpia todo el storage

### Performance
- Lazy loading de módulos
- Images con caching
- Responsive design con ScreenUtil
- Build optimizado con código generado

---

## Recursos

### Assets
- Logo: `assets/images/atenea-logo.png`
- Logo completo: `assets/images/atenea-logo-full.jpeg`
- Emblema: `assets/images/atenea-emblem.png`

### Fuentes
- Inter (pendiente de agregar archivos .ttf)

### Colores
- Primary: #1E3A5F
- Secondary: #4A90A4
- Background: #F0F4F8
- Success: #48BB78
- Danger: #E53E3E
- Warning: #ECC94B

---

**Última Actualización**: Octubre 23, 2026
**Versión**: 1.0.0+1
**Estado**: MVP - Auth y Dashboard Base Completados
