# ATENEA POS - Aplicación Móvil

Aplicación móvil multiplataforma (iOS y Android) para el sistema de punto de venta ATENEA POS.

## Tecnologías

- **Flutter** 3.24+
- **Dart** 3.7+
- **State Management**: Riverpod 2.x
- **Routing**: go_router 14.x
- **HTTP Client**: Dio 5.x
- **Local Storage**: Hive + Secure Storage
- **Arquitectura**: Clean Architecture + Feature-First

## Estructura del Proyecto

```
lib/
├── core/                  # Núcleo de la aplicación
│   ├── config/           # Configuraciones (tema, env, router)
│   ├── constants/        # Constantes (API, app, storage keys)
│   ├── error/            # Manejo de errores
│   ├── network/          # Cliente HTTP y configuración
│   ├── storage/          # Storage local
│   └── utils/            # Utilidades
│
├── features/             # Módulos de la aplicación
│   ├── auth/            # Autenticación
│   ├── dashboard/       # Dashboard
│   ├── pos/             # Punto de Venta
│   ├── caja/            # Caja
│   ├── productos/       # Productos
│   ├── clientes/        # Clientes
│   ├── cartera/         # Cuentas por Cobrar
│   ├── facturas/        # Facturas
│   ├── apartados/       # Apartados
│   ├── cotizaciones/    # Cotizaciones
│   ├── ordenes/         # Órdenes de Servicio
│   ├── reportes/        # Reportes
│   ├── configuracion/   # Configuración
│   └── notificaciones/  # Notificaciones
│
└── shared/               # Componentes compartidos
    ├── widgets/         # Widgets reutilizables
    ├── models/          # Modelos compartidos
    └── providers/       # Providers compartidos
```

## Instalación y Configuración

### Requisitos Previos

- Flutter SDK 3.24+ instalado
- Dart SDK 3.7+ instalado
- Android Studio / Xcode configurado
- Dispositivo físico o emulador para pruebas

### Instalación

1. Clonar el repositorio (si aplica)
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```

3. Verificar instalación:
   ```bash
   flutter doctor
   ```

### Ejecución

#### Modo Desarrollo
```bash
flutter run
```

#### Modo Release (Android)
```bash
flutter run --release
```

#### Modo Release (iOS)
```bash
flutter run --release
```

### Build

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Configuración de Entornos

El proyecto soporta múltiples entornos (development, staging, production).

### Development
```bash
flutter run --dart-define=ENVIRONMENT=development
```

### Production
```bash
flutter run --dart-define=ENVIRONMENT=production
```

## Configuración del Tema

El tema de la aplicación está basado en los colores corporativos de ATENEA POS:

- **Primary Color**: `#1E3A5F` (Azul oscuro)
- **Secondary Color**: `#4A90A4` (Azul medio)
- **Background**: `#F0F4F8`
- **Typography**: Inter Font Family

Ver `lib/core/config/theme_config.dart` para más detalles.

## API Backend

La aplicación se conecta al backend de ATENEA POS vía AWS API Gateway Global (Balanceador):

**Base URL**: `https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod`
**API Version**: `v1`
**Prefix**: `pos`

**Ejemplo de endpoint completo**:
```
https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod/v1/pos/monedas?pageNumber=1&pageSize=10
```

Ver `lib/core/constants/api_constants.dart` para endpoints disponibles.

## Arquitectura

### Clean Architecture

Cada feature sigue el patrón Clean Architecture con 3 capas:

1. **Data Layer**: Implementaciones concretas, datasources, modelos
2. **Domain Layer**: Entidades, repositorios (interfaces), casos de uso
3. **Presentation Layer**: UI, widgets, state management

### State Management

Utilizamos Riverpod 2.x para la gestión de estado:

- Providers para estado global
- StateNotifiers para estado mutable
- Computed providers para estado derivado

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widgets
```

### Integration Tests
```bash
flutter test integration_test
```

## Código y Calidad

### Análisis Estático
```bash
flutter analyze
```

### Formateo de Código
```bash
dart format .
```

### Linting
El proyecto usa `very_good_analysis` para linting estricto.

## Assets

### Imágenes
Los logos y assets visuales están en `assets/images/`:
- `atenea-logo.png` - Logo principal
- `atenea-logo-full.jpeg` - Logo completo
- `atenea-emblem.png` - Emblema

### Fuentes
Fuente Inter configurada en `pubspec.yaml` (pendiente de agregar archivos de fuente).

## Dependencias Principales

- **flutter_riverpod**: State management
- **go_router**: Routing y navegación
- **dio**: Cliente HTTP
- **hive**: Database local
- **flutter_secure_storage**: Storage seguro
- **flutter_screenutil**: Responsive design
- **mobile_scanner**: Escaneo de códigos de barras
- **permission_handler**: Manejo de permisos

Ver `pubspec.yaml` para lista completa.

## Roadmap

### Fase 1 - MVP (4-6 semanas)
- [x] Configuración inicial del proyecto
- [x] Estructura Clean Architecture
- [x] Tema profesional y moderno
- [ ] Módulo de autenticación
- [ ] Dashboard básico
- [ ] Módulo POS
- [ ] Módulo de Caja

### Fase 2 - Módulos de Gestión (4-5 semanas)
- [ ] Productos
- [ ] Clientes
- [ ] Cartera
- [ ] Facturas

### Fase 3 - Módulos Avanzados (4-5 semanas)
- [ ] Apartados
- [ ] Cotizaciones
- [ ] Órdenes de Servicio
- [ ] Reportes

### Fase 4 - Optimización y Lanzamiento (3-4 semanas)
- [ ] Modo Offline
- [ ] Push Notifications
- [ ] Optimización de rendimiento
- [ ] Testing exhaustivo
- [ ] Publicación en stores

## Contribución

1. Crear branch desde `develop`
2. Seguir convenciones de código
3. Escribir tests
4. Crear Pull Request

## Contacto

Para preguntas o soporte, contactar al equipo de desarrollo de ATENEA POS.

## Licencia

Propietario - ATENEA POS © 2026
