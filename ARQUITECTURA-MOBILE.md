# Arquitectura Mobile - ATENEA POS

## Tabla de Contenidos
- [Visión General](#visión-general)
- [Principios de Arquitectura Clean](#principios-de-arquitectura-clean)
- [Estructura de un Módulo](#estructura-de-un-módulo)
- [Flujo de Datos](#flujo-de-datos)
- [Guía Paso a Paso: Crear un Nuevo Módulo](#guía-paso-a-paso-crear-un-nuevo-módulo)
- [DTOs, Entities y Mappers](#dtos-entities-y-mappers)
- [Gestión de Estado con Riverpod](#gestión-de-estado-con-riverpod)
- [Autenticación Biométrica y Almacenamiento Seguro](#autenticación-biométrica-y-almacenamiento-seguro)
- [Convenciones y Mejores Prácticas](#convenciones-y-mejores-prácticas)

---

## Visión General

La aplicación móvil de ATENEA POS está construida con **Flutter** siguiendo los principios de **Clean Architecture** (Arquitectura Limpia). Esta arquitectura garantiza:

- ✅ **Separación de responsabilidades** - Cada capa tiene un propósito único
- ✅ **Independencia de frameworks** - La lógica de negocio no depende de Flutter
- ✅ **Testabilidad** - Fácil de probar cada capa por separado
- ✅ **Mantenibilidad** - Código organizado y fácil de modificar
- ✅ **Escalabilidad** - Agregar nuevas funcionalidades sin romper lo existente

### Stack Tecnológico

- **Framework**: Flutter 3.29.3
- **Lenguaje**: Dart 3.7.2
- **Gestión de Estado**: Riverpod
- **Navegación**: go_router
- **HTTP Client**: Dio
- **Serialización JSON**: json_serializable + build_runner
- **UI**: flutter_screenutil (responsive)

---

## Principios de Arquitectura Clean

### Las 3 Capas

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Screens  │  Widgets  │  Providers (State)           │  │
│  │  - UI Components                                      │  │
│  │  - User Interaction                                   │  │
│  │  - State Management (Riverpod)                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Entities  │  Repository Interfaces                   │  │
│  │  - Business Logic                                     │  │
│  │  - Pure Dart Objects                                  │  │
│  │  - No Dependencies                                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  DTOs/Models  │  Datasources  │  Repository Impl     │  │
│  │  Mappers                                              │  │
│  │  - API Communication                                  │  │
│  │  - Data Transformation                                │  │
│  │  - External Dependencies                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Regla de Dependencias

**Las dependencias siempre fluyen hacia adentro:**
- **Presentation** → depende de → **Domain**
- **Data** → depende de → **Domain**
- **Domain** → NO depende de nadie ✅

---

## Estructura de un Módulo

Cada módulo (feature) en `lib/features/{nombre_modulo}/` debe tener la siguiente estructura:

```
features/
└── {nombre_modulo}/
    ├── data/                           # Capa de Datos
    │   ├── datasources/               # Llamadas a API/BD
    │   │   └── {nombre}_remote_datasource.dart
    │   ├── models/                    # DTOs con @JsonSerializable
    │   │   ├── {nombre}_model.dart
    │   │   └── {nombre}_model.g.dart  # Generado por build_runner
    │   ├── mappers/                   # Convierte DTOs → Entities
    │   │   └── {nombre}_mapper.dart
    │   └── repositories/              # Implementación del repositorio
    │       └── {nombre}_repository_impl.dart
    │
    ├── domain/                         # Capa de Dominio
    │   ├── entities/                  # Objetos puros de negocio
    │   │   └── {nombre}_entity.dart
    │   └── repositories/              # Interfaces abstractas
    │       └── {nombre}_repository.dart
    │
    └── presentation/                   # Capa de Presentación
        ├── providers/                 # Estado con Riverpod ✅
        │   └── {nombre}_provider.dart
        ├── screens/                   # Pantallas completas
        │   └── {nombre}_screen.dart
        └── widgets/                   # Componentes reutilizables
            └── {nombre}_widget.dart
```

### Ejemplo Real: Módulo de Movimientos

```
features/
└── movimientos/
    ├── data/
    │   ├── datasources/
    │   │   └── movimientos_remote_datasource.dart
    │   ├── models/
    │   │   ├── movimiento_model.dart
    │   │   └── movimiento_model.g.dart
    │   ├── mappers/
    │   │   └── movimiento_mapper.dart
    │   └── repositories/
    │       └── movimientos_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── movimiento_entity.dart
    │   └── repositories/
    │       └── movimientos_repository.dart
    └── presentation/
        ├── providers/                   # ✅ Dentro de presentation
        │   └── movimientos_provider.dart
        ├── screens/
        │   └── movimientos_screen.dart
        └── widgets/
            └── movimiento_card.dart
```

---

## Flujo de Datos

### Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                            USER ACTION                               │
│                      (Tap button, scroll, etc)                       │
└────────────────────────────────┬────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                                 │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Widget/Screen                                              │    │
│  │  - User taps "Load Data"                                    │    │
│  │  - Calls: ref.read(provider.notifier).loadData()           │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          PROVIDER (State)                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  StateNotifier/Notifier                                     │    │
│  │  - loadData() method called                                 │    │
│  │  - Calls: repository.getData()                              │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Repository Interface (Abstract)                            │    │
│  │  abstract class Repository {                                │    │
│  │    Future<Entity> getData();                                │    │
│  │  }                                                           │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Repository Implementation                                  │    │
│  │  - Implements abstract repository                           │    │
│  │  - Calls: datasource.fetchData()                            │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
│                                  ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Remote Datasource                                          │    │
│  │  - Makes HTTP call using Dio                                │    │
│  │  - GET /api/v1/pos/endpoint                                 │    │
│  │  - Returns: Response<JSON>                                  │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          API SERVER                                  │
│                  https://api.atenea.com/v1/pos/...                  │
│                     Returns JSON Response                            │
└────────────────────────────────┬────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      DATA TRANSFORMATION                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 1: JSON → DTO/Model                                  │    │
│  │  - Datasource receives JSON                                 │    │
│  │  - json_serializable deserializes to Model                  │    │
│  │  - Example: MovimientoModel.fromJson(json)                  │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
│                                  ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 2: DTO → Entity (via Mapper)                         │    │
│  │  - Repository calls Mapper                                  │    │
│  │  - Mapper.toEntity(model)                                   │    │
│  │  - Converts snake_case → camelCase                          │    │
│  │  - Parses strings to proper types                           │    │
│  │  - Example: "123.45" → double 123.45                        │    │
│  └──────────────────────────────┬──────────────────────────────┘    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      RETURN TO PROVIDER                              │
│  - Repository returns Entity to Provider                            │
│  - Provider updates state                                           │
│  - state = state.copyWith(data: entity)                             │
└────────────────────────────────┬────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          UI UPDATE                                   │
│  - Widget watches provider                                          │
│  - ref.watch(provider) detects state change                         │
│  - Widget rebuilds with new data                                    │
│  - User sees updated information                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### Flujo Resumido

1. **UI** → Llama al provider
2. **Provider** → Llama al repository (interface)
3. **Repository Impl** → Llama al datasource
4. **Datasource** → HTTP Request (Dio)
5. **API** → Retorna JSON
6. **DTO/Model** → Deserializa JSON (@JsonSerializable)
7. **Mapper** → Convierte DTO a Entity
8. **Repository** → Retorna Entity al Provider
9. **Provider** → Actualiza state
10. **UI** → Se redibuja automáticamente

---

## Guía Paso a Paso: Crear un Nuevo Módulo

### Paso 1: Crear la Estructura de Carpetas

```bash
cd lib/features
mkdir -p {nombre_modulo}/data/{datasources,repositories,models,mappers}
mkdir -p {nombre_modulo}/domain/{repositories,entities}
mkdir -p {nombre_modulo}/presentation/{providers,screens,widgets}
```

**Nota importante**: Los providers SIEMPRE van dentro de `presentation/providers/` para mantener consistencia en toda la app.

### Paso 2: Crear la Entity (Domain)

**Ubicación**: `domain/entities/{nombre}_entity.dart`

```dart
/// Entidad de dominio - Objeto puro de negocio
class MovimientoEntity {
  final int id;
  final String nombre;
  final DateTime fecha;
  final double total;

  const MovimientoEntity({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.total,
  });

  // Computed properties
  bool get isRecent =>
    fecha.isAfter(DateTime.now().subtract(Duration(days: 7)));
}
```

**Características de una Entity:**
- ✅ Objetos **inmutables** (final fields)
- ✅ Solo tipos de Dart (int, String, DateTime, bool, etc.)
- ✅ Sin dependencias de frameworks
- ✅ Puede tener computed properties (getters)
- ✅ Puede tener lógica de negocio simple
- ❌ NO conoce la UI
- ❌ NO conoce la base de datos o API

### Paso 3: Crear el Repository Interface (Domain)

**Ubicación**: `domain/repositories/{nombre}_repository.dart`

```dart
import '../entities/{nombre}_entity.dart';

/// Contrato que debe cumplir cualquier implementación
abstract class MovimientosRepository {
  /// Obtiene lista de movimientos
  Future<List<MovimientoEntity>> getMovimientos({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Crea un nuevo movimiento
  Future<MovimientoEntity> createMovimiento({
    required String nombre,
    required double total,
  });

  /// Actualiza un movimiento
  Future<MovimientoEntity> updateMovimiento({
    required int id,
    required String nombre,
  });

  /// Elimina un movimiento
  Future<void> deleteMovimiento({
    required int id,
  });
}
```

### Paso 4: Crear el DTO/Model (Data)

**Ubicación**: `data/models/{nombre}_model.dart`

```dart
import 'package:json_serializable/json_serializable.dart';

part '{nombre}_model.g.dart';

/// DTO que representa la estructura JSON de la API
@JsonSerializable(fieldRename: FieldRename.snake)
class MovimientoModel {
  final int movimientoId;           // snake_case desde API
  final String nombre;
  final String fecha;                // ISO string desde API
  final String total;                // DECIMAL como string desde API

  const MovimientoModel({
    required this.movimientoId,
    required this.nombre,
    required this.fecha,
    required this.total,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) =>
      _$MovimientoModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientoModelToJson(this);
}

/// Response wrapper de la API
@JsonSerializable()
class MovimientosResponse {
  final MovimientosData data;

  const MovimientosResponse({required this.data});

  factory MovimientosResponse.fromJson(Map<String, dynamic> json) =>
      _$MovimientosResponseFromJson(json);
}

@JsonSerializable()
class MovimientosData {
  final List<MovimientoModel> movimientos;

  const MovimientosData({required this.movimientos});

  factory MovimientosData.fromJson(Map<String, dynamic> json) =>
      _$MovimientosDataFromJson(json);
}
```

**Después de crear el modelo, generar el archivo .g.dart:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Paso 5: Crear el Mapper (Data)

**Ubicación**: `data/mappers/{nombre}_mapper.dart`

```dart
import '../../domain/entities/{nombre}_entity.dart';
import '../models/{nombre}_model.dart';

/// Convierte DTOs a Entities
class MovimientoMapper {
  /// Model → Entity
  static MovimientoEntity toEntity(MovimientoModel model) {
    return MovimientoEntity(
      id: model.movimientoId,
      nombre: model.nombre,
      fecha: DateTime.parse(model.fecha),        // String → DateTime
      total: double.parse(model.total),          // String → double
    );
  }

  /// Lista de Models → Lista de Entities
  static List<MovimientoEntity> toEntityList(List<MovimientoModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Entity → JSON (para POST/PUT)
  static Map<String, dynamic> toJson(MovimientoEntity entity) {
    return {
      'nombre': entity.nombre,
      'fecha': entity.fecha.toIso8601String(),
      'total': entity.total,
    };
  }
}
```

**Responsabilidades del Mapper:**
- ✅ Convertir **DTO → Entity**
- ✅ Convertir **Entity → JSON** (para crear/actualizar)
- ✅ Parsear tipos (String → DateTime, String → double)
- ✅ Renombrar campos (snake_case → camelCase)
- ✅ Transformar estructuras (flatten, nested objects)

### Paso 6: Crear el Datasource (Data)

**Ubicación**: `data/datasources/{nombre}_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/{nombre}_model.dart';

/// Responsable de las llamadas HTTP
class MovimientosRemoteDatasource {
  final Dio _dio;

  MovimientosRemoteDatasource(this._dio);

  /// GET /movimientos
  Future<MovimientosResponse> getMovimientos({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/movimientos'),
      queryParameters: {
        'clienteId': clienteId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return MovimientosResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener movimientos',
      );
    }
  }

  /// POST /movimientos
  Future<MovimientoModel> createMovimiento({
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildUrl('/movimientos'),
      data: data,
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return MovimientoModel.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al crear movimiento',
      );
    }
  }
}
```

### Paso 7: Crear Repository Implementation (Data)

**Ubicación**: `data/repositories/{nombre}_repository_impl.dart`

```dart
import '../../domain/entities/{nombre}_entity.dart';
import '../../domain/repositories/{nombre}_repository.dart';
import '../datasources/{nombre}_remote_datasource.dart';
import '../mappers/{nombre}_mapper.dart';

/// Implementación concreta del repositorio
class MovimientosRepositoryImpl implements MovimientosRepository {
  final MovimientosRemoteDatasource _datasource;

  MovimientosRepositoryImpl(this._datasource);

  @override
  Future<List<MovimientoEntity>> getMovimientos({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    // 1. Llamar al datasource (obtiene DTOs)
    final response = await _datasource.getMovimientos(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    // 2. Convertir DTOs a Entities usando Mapper
    return MovimientoMapper.toEntityList(response.data.movimientos);
  }

  @override
  Future<MovimientoEntity> createMovimiento({
    required String nombre,
    required double total,
  }) async {
    // 1. Preparar datos para enviar
    final data = {
      'nombre': nombre,
      'total': total,
      'fecha': DateTime.now().toIso8601String(),
    };

    // 2. Llamar al datasource
    final model = await _datasource.createMovimiento(data: data);

    // 3. Convertir a Entity
    return MovimientoMapper.toEntity(model);
  }
}
```

### Paso 8: Crear Providers (Riverpod)

**Ubicación**: `presentation/providers/{nombre}_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/{nombre}_remote_datasource.dart';
import '../../data/repositories/{nombre}_repository_impl.dart';
import '../../domain/entities/{nombre}_entity.dart';
import '../../domain/repositories/{nombre}_repository.dart';

// ============================================================================
// INFRASTRUCTURE PROVIDERS
// ============================================================================

final movimientosRemoteDatasourceProvider =
    Provider<MovimientosRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MovimientosRemoteDatasource(dioClient.dio);
});

final movimientosRepositoryProvider = Provider<MovimientosRepository>((ref) {
  final datasource = ref.watch(movimientosRemoteDatasourceProvider);
  return MovimientosRepositoryImpl(datasource);
});

// ============================================================================
// STATE
// ============================================================================

class MovimientosState {
  final List<MovimientoEntity> movimientos;
  final bool isLoading;
  final String? error;

  const MovimientosState({
    this.movimientos = const [],
    this.isLoading = false,
    this.error,
  });

  MovimientosState copyWith({
    List<MovimientoEntity>? movimientos,
    bool? isLoading,
    String? error,
  }) {
    return MovimientosState(
      movimientos: movimientos ?? this.movimientos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================================
// NOTIFIER
// ============================================================================

class MovimientosNotifier extends StateNotifier<MovimientosState> {
  final MovimientosRepository _repository;

  MovimientosNotifier(this._repository) : super(const MovimientosState());

  Future<void> loadMovimientos({required int clienteId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final movimientos = await _repository.getMovimientos(
        clienteId: clienteId,
      );

      state = state.copyWith(
        movimientos: movimientos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createMovimiento({
    required String nombre,
    required double total,
  }) async {
    try {
      await _repository.createMovimiento(
        nombre: nombre,
        total: total,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final movimientosProvider =
    StateNotifierProvider<MovimientosNotifier, MovimientosState>((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return MovimientosNotifier(repository);
});
```

### Paso 9: Crear la Pantalla (Presentation)

**Ubicación**: `presentation/screens/{nombre}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/{nombre}_provider.dart';

class MovimientosScreen extends ConsumerStatefulWidget {
  const MovimientosScreen({super.key});

  @override
  ConsumerState<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends ConsumerState<MovimientosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(movimientosProvider.notifier).loadMovimientos(
      clienteId: user.clienteId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movimientosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : ListView.builder(
                  itemCount: state.movimientos.length,
                  itemBuilder: (context, index) {
                    final movimiento = state.movimientos[index];
                    return ListTile(
                      title: Text(movimiento.nombre),
                      subtitle: Text('\$${movimiento.total}'),
                    );
                  },
                ),
    );
  }
}
```

### Paso 10: Agregar Ruta de Navegación

**Ubicación**: `lib/core/config/router_config.dart`

```dart
// 1. Importar la pantalla
import '../../features/{nombre}/presentation/screens/{nombre}_screen.dart';

// 2. Agregar la ruta
GoRoute(
  path: '/{nombre}',
  name: '{nombre}',
  builder: (context, state) => const {Nombre}Screen(),
),
```

### Paso 11: Agregar al Menú (Drawer)

**Ubicación**: `lib/shared/widgets/app_drawer.dart`

```dart
_DrawerItem(
  icon: Icons.{icono},
  title: '{Título}',
  isSelected: currentRoute == '/{nombre}',
  onTap: () {
    Navigator.pop(context);
    if (currentRoute != '/{nombre}') {
      context.push('/{nombre}');
    }
  },
),
```

---

## DTOs, Entities y Mappers

### ¿Por qué necesitamos 3 capas de datos?

```
API JSON → DTO/Model → Mapper → Entity → UI
```

#### 1. **DTO/Model** (Data Transfer Object)

**Propósito**: Representar EXACTAMENTE la estructura JSON de la API

**Características:**
- Usa `@JsonSerializable` para deserialización automática
- Campos en `snake_case` (como vienen de la API)
- Tipos como vienen de la BD (String para DECIMAL, etc.)
- Incluye campos técnicos (created_at, updated_at, etc.)

**Ejemplo:**
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class MovimientoModel {
  final int movimiento_id;        // ← Como viene de la API
  final String total;              // ← DECIMAL como String
  final String fecha;              // ← ISO String
  final String? deleted_at;        // ← Campos de auditoría
}
```

#### 2. **Entity** (Dominio)

**Propósito**: Representar el concepto de negocio

**Características:**
- Objetos puros de Dart
- Campos en `camelCase`
- Tipos correctos (double, DateTime, etc.)
- Solo campos relevantes para el negocio
- Puede tener lógica de negocio

**Ejemplo:**
```dart
class MovimientoEntity {
  final int movimientoId;         // ← camelCase
  final double total;              // ← Tipo correcto
  final DateTime fecha;            // ← DateTime

  // Computed property
  bool get isRecent =>
    fecha.isAfter(DateTime.now().subtract(Duration(days: 7)));
}
```

#### 3. **Mapper**

**Propósito**: Convertir entre DTOs y Entities

**Responsabilidades:**
- Transformar nombres de campos
- Parsear tipos
- Filtrar campos innecesarios
- Manejar valores null

**Ejemplo:**
```dart
class MovimientoMapper {
  static MovimientoEntity toEntity(MovimientoModel model) {
    return MovimientoEntity(
      movimientoId: model.movimiento_id,     // Renombrar
      total: double.parse(model.total),       // String → double
      fecha: DateTime.parse(model.fecha),     // String → DateTime
    );
  }
}
```

### Flujo Completo de Transformación

```
┌─────────────────────────────────────────────────────────────┐
│  API Response (JSON)                                         │
│  {                                                           │
│    "movimiento_id": 123,                                     │
│    "total": "456.78",                                        │
│    "fecha": "2024-10-25T10:30:00Z",                         │
│    "created_at": "2024-10-01T08:00:00Z"                     │
│  }                                                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
                 json_serializable
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  MovimientoModel (DTO)                                       │
│  movimiento_id: 123                                          │
│  total: "456.78"                                             │
│  fecha: "2024-10-25T10:30:00Z"                              │
│  created_at: "2024-10-01T08:00:00Z"                         │
└────────────────────────┬────────────────────────────────────┘
                         ↓
                      Mapper
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  MovimientoEntity (Domain)                                   │
│  movimientoId: 123                                           │
│  total: 456.78                                               │
│  fecha: DateTime(2024, 10, 25, 10, 30)                      │
│  (created_at omitido - no relevante para UI)                │
└─────────────────────────────────────────────────────────────┘
```

---

## Gestión de Estado con Riverpod

### Tipos de Providers

```dart
// 1. Provider - Inmutable, no cambia
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// 2. StateProvider - Estado simple
final counterProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider - Estado complejo con lógica
final movimientosProvider =
  StateNotifierProvider<MovimientosNotifier, MovimientosState>((ref) {
    return MovimientosNotifier();
  });

// 4. FutureProvider - Operaciones asíncronas
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});
```

### Patrón de State Class

```dart
// Estado inmutable
class MovimientosState {
  final List<MovimientoEntity> data;
  final bool isLoading;
  final String? error;

  const MovimientosState({
    this.data = const [],
    this.isLoading = false,
    this.error,
  });

  // copyWith para actualizaciones inmutables
  MovimientosState copyWith({
    List<MovimientoEntity>? data,
    bool? isLoading,
    String? error,
  }) {
    return MovimientosState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
```

### Uso en Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch - Reconstruye cuando cambia
    final state = ref.watch(movimientosProvider);

    // read - Lee valor sin reconstruir (para callbacks)
    final loadData = () {
      ref.read(movimientosProvider.notifier).loadMovimientos();
    };

    // listen - Ejecuta callback cuando cambia
    ref.listen(movimientosProvider, (previous, next) {
      if (next.error != null) {
        showSnackbar(next.error!);
      }
    });

    return /* ... */;
  }
}
```

---

## Autenticación Biométrica y Almacenamiento Seguro

### Funcionalidad "Recordar Credenciales"

La app implementa un sistema seguro para recordar las credenciales del usuario usando:
- **Almacenamiento encriptado** (`flutter_secure_storage`)
- **Autenticación biométrica** (`local_auth`)

### Arquitectura del Sistema

```
┌──────────────────────────────────────────────────────────────┐
│                    LOGIN SCREEN                               │
│  - Checkbox "Recordar mis datos"                             │
│  - Llama a CredentialsStorageService                         │
└────────────────────────┬─────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────────┐
│           CredentialsStorageService                          │
│  lib/core/services/credentials_storage_service.dart          │
│                                                               │
│  Métodos:                                                     │
│  - isBiometricAvailable() → bool                             │
│  - authenticateWithBiometrics() → bool                       │
│  - saveCredentials(email, password, rememberMe)              │
│  - getCredentials() → SavedCredentials?                      │
│  - clearCredentials()                                         │
└────────────────────────┬─────────────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────────────┐
│                  SECURE STORAGE                               │
│  - iOS: Keychain                                             │
│  - Android: Keystore                                         │
│                                                               │
│  Keys guardados:                                             │
│  - saved_email                                                │
│  - saved_password (encriptado)                               │
│  - remember_me                                                │
└──────────────────────────────────────────────────────────────┘
```

### Flujo de Funcionamiento

#### 1. Al Hacer Login (Guardar Credenciales)

```dart
// login_screen.dart
Future<void> _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  // 1. Autenticar con la API
  await ref.read(authProvider.notifier).login(email, password);

  // 2. Guardar credenciales si marcó "Recordar"
  await _credentialsService.saveCredentials(
    email: email,
    password: password,
    rememberMe: _rememberMe,  // Estado del checkbox
  );
}
```

#### 2. Al Abrir la App (Cargar Credenciales)

```dart
// login_screen.dart - initState
Future<void> _loadSavedCredentials() async {
  // 1. Verificar si hay credenciales guardadas
  final hasCredentials = await _credentialsService.hasCredentials();
  if (!hasCredentials) return;

  // 2. Solicitar autenticación biométrica (Face ID / Huella)
  final credentials = await _credentialsService.getCredentials();

  // 3. Si autenticación exitosa, pre-llenar campos
  if (credentials != null) {
    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;
    _rememberMe = true;
  }
}
```

#### 3. Lógica Interna del Servicio

```dart
// credentials_storage_service.dart
Future<SavedCredentials?> getCredentials() async {
  // 1. Verificar que está habilitado "recordar"
  final rememberMe = await _secureStorage.read(key: 'remember_me');
  if (rememberMe != 'true') return null;

  // 2. Verificar si el dispositivo tiene biometría
  final hasBiometrics = await isBiometricAvailable();

  // 3. Si tiene biometría, solicitar autenticación
  if (hasBiometrics) {
    final authenticated = await authenticateWithBiometrics();
    if (!authenticated) return null;  // Usuario canceló o falló
  }

  // 4. Si no tiene biometría O autenticación exitosa → retornar credenciales
  final email = await _secureStorage.read(key: 'saved_email');
  final password = await _secureStorage.read(key: 'saved_password');

  return SavedCredentials(email: email!, password: password!);
}
```

### Configuración de Permisos

#### iOS - Info.plist

```xml
<key>NSFaceIDUsageDescription</key>
<string>ATENEA POS usa Face ID para autenticar tu acceso de forma rápida y segura</string>
```

#### Android - AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

### Dependencias Necesarias

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.2.2    # Almacenamiento encriptado
  local_auth: ^2.2.0                 # Autenticación biométrica
```

### Casos de Uso

| Escenario | Comportamiento |
|-----------|---------------|
| **Dispositivo con Face ID (iPhone)** | Al volver al login, pide Face ID → Pre-llena credenciales |
| **Dispositivo con huella (Android)** | Al volver al login, pide huella digital → Pre-llena credenciales |
| **Dispositivo sin biometría** | Al volver al login, pre-llena directamente (sin autenticación adicional) |
| **Usuario cancela Face ID/Huella** | Campos quedan vacíos, debe ingresar manualmente |
| **Usuario desmarca "Recordar"** | Al hacer login, se borran credenciales guardadas |
| **Cierre de sesión manual** | Credenciales se MANTIENEN guardadas (no se borran) |
| **Cambio de contraseña** | Al hacer login con nueva contraseña + "Recordar" marcado → Actualiza credenciales automáticamente |

### Seguridad

✅ **Encriptación**: Keychain (iOS) y Keystore (Android) usan encriptación por hardware
✅ **Biometría**: Capa adicional de seguridad cuando está disponible
✅ **Sin sincronización**: Credenciales solo en el dispositivo local
✅ **Aislamiento**: Cada app tiene su propio contenedor seguro
✅ **Actualización automática**: Si cambia la contraseña, se actualiza al hacer login

⚠️ **Consideración**: En dispositivos sin biometría, las credenciales se pre-llenan directamente. Para mayor seguridad, se podría agregar PIN de app.

### Código del Servicio Completo

```dart
// lib/core/services/credentials_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class CredentialsStorageService {
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  CredentialsStorageService()
      : _secureStorage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo tiene biometría disponible
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Autentica con biometría (Face ID o huella)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final hasBiometrics = await isBiometricAvailable();
      if (!hasBiometrics) return true; // Sin biometría, permitir acceso

      return await _localAuth.authenticate(
        localizedReason: 'Verifica tu identidad para acceder',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Guarda las credenciales de forma segura
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _secureStorage.write(key: _keyEmail, value: email);
      await _secureStorage.write(key: _keyPassword, value: password);
      await _secureStorage.write(key: _keyRememberMe, value: 'true');
    } else {
      await clearCredentials();
    }
  }

  /// Obtiene las credenciales guardadas (requiere biometría si disponible)
  Future<SavedCredentials?> getCredentials() async {
    try {
      final rememberMe = await _secureStorage.read(key: _keyRememberMe);
      if (rememberMe != 'true') return null;

      // Verificar biometría si está disponible
      final hasBiometrics = await isBiometricAvailable();
      if (hasBiometrics) {
        final authenticated = await authenticateWithBiometrics();
        if (!authenticated) return null;
      }

      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);

      if (email != null && password != null) {
        return SavedCredentials(email: email, password: password);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay credenciales guardadas (sin autenticar)
  Future<bool> hasCredentials() async {
    final rememberMe = await _secureStorage.read(key: _keyRememberMe);
    return rememberMe == 'true';
  }

  /// Borra las credenciales guardadas
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
    await _secureStorage.delete(key: _keyRememberMe);
  }
}

class SavedCredentials {
  final String email;
  final String password;

  SavedCredentials({required this.email, required this.password});
}
```

---

## Convenciones y Mejores Prácticas

### Nomenclatura

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Archivo | snake_case | `movimiento_entity.dart` |
| Clase | PascalCase | `MovimientoEntity` |
| Variable/método | camelCase | `loadMovimientos()` |
| Constante | lowerCamelCase | `const defaultPageSize = 10;` |
| Provider | camelCase + Provider | `movimientosProvider` |

### Organización de Imports

```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter packages
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

// 4. Proyecto - Features
import '../../../features/auth/domain/entities/user.dart';

// 5. Proyecto - Core
import '../../../core/constants/api_constants.dart';
```

### Reglas de Oro

1. ✅ **Domain nunca depende de Data o Presentation**
2. ✅ **Entities son inmutables** (final fields)
3. ✅ **Un mapper por cada DTO**
4. ✅ **Datasource solo conoce HTTP, no lógica de negocio**
5. ✅ **Repository devuelve Entities, no DTOs**
6. ✅ **Provider maneja estado, no lógica de negocio compleja**
7. ✅ **Widgets solo leen estado, no lo modifican directamente**
8. ✅ **Siempre usar `const` cuando sea posible**
9. ✅ **Manejo de errores en todas las capas**
10. ✅ **Generar archivos .g.dart después de crear/modificar Models**

### Comandos Útiles

```bash
# Generar archivos de serialización JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (regenera automáticamente)
flutter pub run build_runner watch

# Compilar para iOS
flutter build ios --release

# Compilar para Android
flutter build apk --release

# Instalar en dispositivo
flutter install --device-id=DEVICE_ID
```

---

## Checklist para Nuevo Módulo

- [ ] Crear estructura de carpetas (data/domain/presentation)
- [ ] Crear Entity en domain/entities/
- [ ] Crear Repository interface en domain/repositories/
- [ ] Crear Model en data/models/ con @JsonSerializable
- [ ] Ejecutar `build_runner build` para generar .g.dart
- [ ] Crear Mapper en data/mappers/
- [ ] Crear Datasource en data/datasources/
- [ ] Crear Repository implementation en data/repositories/
- [ ] Crear Providers en **presentation/providers/** ✅ (NO en raíz)
- [ ] Crear Screen en presentation/screens/
- [ ] Agregar ruta en router_config.dart
- [ ] Agregar opción en app_drawer.dart (si aplica)
- [ ] Probar compilación y funcionalidad

---

## Referencias

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod](https://riverpod.dev/)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [Dio HTTP Client](https://pub.dev/packages/dio)

---

**Última actualización**: Octubre 2026
**Versión**: 2.0.0
**Autor**: Equipo de Desarrollo ATENEA

**Changelog v2.0.0:**
- ✅ Actualizada estructura de módulos: providers ahora en `presentation/providers/`
- ✅ Agregada sección completa de Autenticación Biométrica y Almacenamiento Seguro
- ✅ Documentado sistema de "Recordar Credenciales" con Face ID/Huella
- ✅ Ejemplos actualizados con rutas correctas de imports
- ✅ Checklist actualizado para reflejar nueva estructura
