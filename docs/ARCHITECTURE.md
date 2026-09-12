# Arquitectura de AutoCare

## 🏗️ Visión General

AutoCare usa una arquitectura **3-tier** con separación clara entre:
1. **Presentación** (UI - Flutter Widgets)
2. **Lógica de Negocio** (Services - Firebase, Logger)
3. **Datos** (Models - Entidades con validaciones)

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  - Login/Registro                   │
│  - Home                             │
│  - Vehículos                        │
│  - Mantenimientos                   │
│  - Reportes                         │
└──────────────┬──────────────────────┘
               │ Widgets reutilizables
┌──────────────▼──────────────────────┐
│   Business Logic Layer (Services)   │
│  - FirebaseService (CRUD + Streams) │
│  - Logger (Logging)                 │
│  - Validaciones                     │
└──────────────┬──────────────────────┘
               │ Métodos tipados
┌──────────────▼──────────────────────┐
│        Data Layer (Models)          │
│  - AppUser                          │
│  - Vehicle                          │
│  - Maintenance                      │
│  - Enums (MaintenanceType)          │
└──────────────┬──────────────────────┘
               │ toMap/fromMap
┌──────────────▼──────────────────────┐
│      External Layer (Firebase)      │
│  - Firebase Auth                    │
│  - Cloud Firestore                  │
│  - Firebase Storage                 │
└─────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### Lectura (Future)
```
UI Screen
  ↓ (onClick)
FirebaseService.getUser()
  ↓ (query)
Firestore
  ↓ (snapshot)
AppUser.fromMap()
  ↓ (widget)
UI actualizada
```

### Escucha (Stream)
```
UI Screen
  ↓ (streamBuilder)
FirebaseService.getUserDataStream()
  ↓ (listen)
Firestore (cambios en tiempo real)
  ↓ (snapshot)
AppUser.fromMap()
  ↓ (rebuild automático)
UI actualizada
```

## 📦 Modelos (Data Layer)

### Estructura Base
```dart
class Entity {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Validaciones en constructor
  Entity({...}) {
    _validate();
  }

  // Conversión a/desde Firestore
  Map<String, dynamic> toMap() { ... }
  factory Entity.fromMap(Map<String, dynamic> map) { ... }

  // Utilidades
  Entity copyWith({...}) { ... }
  
  @override
  bool operator == (Object other) { ... }
  
  @override
  int get hashCode { ... }
}
```

### Principios de Modelos
- ✅ Inmutables (final fields)
- ✅ Validaciones en constructor
- ✅ Getters calculados (no lógica pesada)
- ✅ Métodos helper (`copyWith`, `toString`)
- ✅ Comparación correcta (`==`, `hashCode`)

## 🔐 FirebaseService (Business Logic)

### Organización por secciones

```dart
class FirebaseService {
  // ============ CONEXIÓN ============
  Future<bool> verifyConnection()
  
  // ============ AUTENTICACIÓN ============
  Future<UserCredential> signUp()
  Future<UserCredential> signIn()
  Future<void> signOut()
  Future<void> resetPassword()
  
  // ============ USUARIO ============
  Future<AppUser?> getUserData()
  Stream<AppUser?> getUserDataStream()
  Future<void> updateUserData()
  Future<void> updateUserProfile()
  
  // ============ VEHÍCULOS ============
  Future<void> addVehicle()
  Future<Vehicle?> getVehicle()
  Future<List<Vehicle>> getUserVehicles()
  Stream<List<Vehicle>> getUserVehiclesStream()
  Future<void> updateVehicle()
  Future<void> deleteVehicle()
  
  // ============ MANTENIMIENTOS ============
  Future<void> addMaintenance()
  Future<Maintenance?> getMaintenance()
  Future<List<Maintenance>> getVehicleMaintenances()
  Stream<List<Maintenance>> getVehicleMaintenancesStream()
  Future<List<Maintenance>> getUserMaintenances()
  Future<void> updateMaintenance()
  Future<void> deleteMaintenance()
  
  // ============ ESTADÍSTICAS ============
  Future<Map<String, dynamic>> getMaintenanceStats()
  
  // ============ UTILIDADES ============
  String generateId()
  Future<bool> userExists()
}
```

### Patrón de Error Handling

```dart
Future<T> method() async {
  try {
    Logger.info('Iniciando operación...', tag: _logTag);
    // Lógica aquí
    Logger.success('Operación exitosa', tag: _logTag);
    return result;
  } on FirebaseAuthException catch (e) {
    Logger.error('Error: ${e.code}', tag: _logTag);
    throw FirebaseException(e.message ?? 'Error', code: e.code);
  } catch (e) {
    Logger.error('Error inesperado: $e', tag: _logTag);
    rethrow;
  }
}
```

## 📱 UI Layer (Screens)

### Estructura de Screens (Fase 2+)

```
screens/
├── auth/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── forgot_password_screen.dart
├── home/
│   └── home_screen.dart
├── vehicles/
│   ├── vehicles_list_screen.dart
│   ├── vehicle_detail_screen.dart
│   └── add_vehicle_screen.dart
└── maintenance/
    ├── maintenance_list_screen.dart
    ├── add_maintenance_screen.dart
    └── maintenance_stats_screen.dart
```

### Patrón de Screen

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _firebaseService = FirebaseService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Título')),
      body: FutureBuilder<Data>(
        future: _firebaseService.getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return DataWidget(data: snapshot.data!);
        },
      ),
    );
  }
}
```

## 🔌 Integraciones Externas

### Firebase Auth
- Métodos: `signUp()`, `signIn()`, `signOut()`, `resetPassword()`
- Excepciones: `FirebaseAuthException` → `FirebaseException`

### Cloud Firestore
- Colecciones: `users`, `vehicles`, `maintenances`
- Índices: Automáticos (Firebase crea según queries)
- Seguridad: Ver `FIREBASE_CONFIG.md`

### Firebase Storage (Fase 3+)
- Path: `/users/{userId}/maintenances/{maintenanceId}/photos/`
- Tipos: JPG, PNG
- Tamaño máx: 10MB por foto

## 🧪 Patrones de Testing

### Unit Test (Modelos)
```dart
test('Vehicle valida año correctamente', () {
  expect(
    () => Vehicle(..., year: 1800, ...),
    throwsArgumentError,
  );
});
```

### Integration Test (FirebaseService)
```dart
testWidgets('Login funciona end-to-end', (WidgetTester tester) async {
  // Setup Firebase mock o emulator
  // Ejecutar flujo
  // Verificar resultado
});
```

## 📈 Escalabilidad

### Cuando agregar Bloc/Provider
- Si el estado compartido entre pantallas crece
- Si hay lógica compleja de estado
- Recomendado a partir de Fase 4

### Cuando agregar caché local
- Si offline es requerido
- Si hay muchas queries repetidas
- Usar `hive` o `sqflite`

### Cuando agregar API REST
- Si Firebase resulta insuficiente
- Mantener `FirebaseService` como adaptador

## 🔒 Seguridad

### Datos Sensibles
- ✅ Credenciales: Firebase Auth maneja
- ✅ Tokens: Automáticos en cliente
- ⚠️ Credenciales app (publicas) - cambiar en prod

### Validación de Datos
- ✅ En modelos (constructor)
- ✅ En FirebaseService (try-catch)
- ✅ En UI (validadores de formulario)

### Reglas Firestore
Ver `FIREBASE_CONFIG.md` - Configuradas por usuario

## 📊 Decisiones de Diseño

| Decisión | Por Qué |
|----------|---------|
| Singleton FirebaseService | Una sola instancia en toda la app |
| Models inmutables | Evita bugs de mutación |
| Validaciones en constructor | Fail-fast, fácil de testear |
| Streams para tiempo real | Actualizaciones automáticas en UI |
| Logger custom | Control sobre output de debug |
| FirebaseException | Excepciones consistentes |
| Enums para MaintenanceType | Type-safety, facilita UI |

---

**Actualizado:** 2026-09-10
