# 🚀 Referencia Rápida - AutoCare

## Comenzar

```bash
cd /Users/jorgepalacio/Documentos/autocare
flutter pub get
flutter run -d emulator-5554
```

## Servicio Firebase

```dart
final firebase = FirebaseService();

// Autenticación
await firebase.signUp(email, password, name);
await firebase.signIn(email, password);
await firebase.signOut();

// Vehículos
await firebase.addVehicle(vehicle);
final vehicles = await firebase.getUserVehicles(userId);
firebase.getUserVehiclesStream(userId).listen(...);

// Mantenimientos
await firebase.addMaintenance(maintenance);
final history = await firebase.getVehicleMaintenances(vehicleId);
firebase.getVehicleMaintenancesStream(vehicleId).listen(...);

// Estadísticas
final stats = await firebase.getMaintenanceStats(userId);
```

## Crear Modelo

```dart
class MyModel {
  final String id;
  final String userId;
  // Otros campos...

  MyModel({
    required this.id,
    required this.userId,
    // Parámetros...
  }) {
    // Validaciones
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, /* ... */};
  }

  factory MyModel.fromMap(Map<String, dynamic> map) {
    return MyModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      // ...
    );
  }

  MyModel copyWith({String? id, String? userId}) {
    return MyModel(id: id ?? this.id, userId: userId ?? this.userId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

## Crear Pantalla

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _firebase = FirebaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Título')),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Column(children: [/* Contenido */]),
    );
  }

  Future<void> _doSomething() async {
    setState(() => _isLoading = true);
    try {
      // Acción
      Logger.success('Éxito', tag: '[MyScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('OK')));
      }
    } catch (e) {
      Logger.error('Error: $e', tag: '[MyScreen]');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

## Validar Email

```dart
bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
}
```

## Tipos de Mantenimiento

```dart
MaintenanceType.oil         // Cambio de Aceite
MaintenanceType.filter      // Filtro
MaintenanceType.tires       // Llantas
MaintenanceType.brakes      // Frenos
MaintenanceType.battery     // Batería
MaintenanceType.inspection  // Inspección
MaintenanceType.transmission // Transmisión
MaintenanceType.suspension  // Suspensión
MaintenanceType.electrical  // Eléctrica
MaintenanceType.bodywork    // Chapa y Pintura
MaintenanceType.other       // Otro

// Usar displayName
print(MaintenanceType.oil.displayName);  // "Cambio de Aceite"
```

## Logger

```dart
Logger.log('Mensaje', tag: '[Tag]');
Logger.success('Éxito', tag: '[Tag]');
Logger.error('Error', tag: '[Tag]');
Logger.info('Info', tag: '[Tag]');
Logger.warning('Advertencia', tag: '[Tag]');

// Activar/desactivar
Logger.setDebugMode(true);
Logger.setDebugMode(false);
```

## Documentación

| Qué necesito | Archivo |
|-------------|---------|
| Visión general | [README.md](./README.md) |
| Arquitectura | [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) |
| Modelos | [docs/MODELS.md](./docs/MODELS.md) |
| API Firebase | [docs/FIREBASE_API.md](./docs/FIREBASE_API.md) |
| Desarrollar | [docs/DEVELOPMENT.md](./docs/DEVELOPMENT.md) |
| Índice | [docs/INDEX.md](./docs/INDEX.md) |

## Errores comunes

```dart
// ❌ No hacer
print('debug');  // Usar Logger
await firebase.addVehicle(vehicle);  // Falta try-catch

// ✅ Hacer
Logger.log('debug', tag: '[Tag]');
try {
  await firebase.addVehicle(vehicle);
} catch (e) {
  Logger.error('Error: $e', tag: '[Tag]');
}
```

## Estructura de directorios

```
lib/
├── main.dart                 # Punto entrada + Tema
├── models/
│   ├── user.dart            # AppUser
│   ├── vehicle.dart         # Vehicle
│   ├── maintenance.dart     # Maintenance
│   └── models.dart          # Exports
├── services/
│   ├── firebase_service.dart # Firebase API
│   └── logger.dart          # Logging
├── screens/                 # Pantallas (crear Fase 2+)
├── widgets/                 # Componentes (crear)
└── utils/                   # Utilidades (crear)
```

## Compilar y Ejecutar

```bash
# Obtener dependencias
flutter pub get

# Analizar código
flutter analyze

# Ejecutar en emulador
flutter run -d emulator-5554

# Hot reload
r

# Hot restart
R

# Salir
q
```

## URLs Útiles

- [Flutter Docs](https://docs.flutter.dev)
- [Firebase Console](https://console.firebase.google.com/u/0/project/autocare-2f41c)
- [Dart Docs](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io)

## Contacto

**Email:** jpalaciovillamizar@gmail.com  
**Proyecto:** AutoCare v1.0.0  
**Estado:** Fase 1 ✅ | Fase 2 ⏳  

---

**Última actualización:** 2026-09-10

Ver [docs/INDEX.md](./docs/INDEX.md) para documentación completa
