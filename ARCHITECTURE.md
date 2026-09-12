# 🏗️ Arquitectura de AutoCare

## Estructura General

```
autocare/
├── lib/
│   ├── main.dart                 # Entrada de la app
│   ├── models/                   # Modelos de datos
│   ├── screens/                  # Pantallas (UI)
│   ├── services/                 # Servicios (lógica)
│   ├── widgets/                  # Componentes reutilizables
│   └── utils/                    # Utilidades
├── android/                      # Configuración Android
├── ios/                          # Configuración iOS
├── pubspec.yaml                  # Dependencias
└── firebase.json                 # Configuración emuladores
```

---

## Capas de la Aplicación

### 1. Presentation Layer (Screens)
Responsable de la UI y la interacción del usuario.

**Pantallas principales:**
- `screens/auth/` - Login y registro
- `screens/home_screen.dart` - Dashboard
- `screens/vehicles/` - Gestión de vehículos
- `screens/maintenance/` - Mantenimientos
- `screens/drivers/` - Conductores
- `screens/reports/` - Reportes

**Patrones:**
- StatefulWidget para estado local
- StreamBuilder para datos en tiempo real
- FutureBuilder para datos asincronos

### 2. Business Logic Layer (Services)
Contiene la lógica de negocio y acceso a datos.

**FirebaseService:**
```dart
- Autenticación
- CRUD de vehículos
- CRUD de mantenimientos
- CRUD de conductores
- Cálculo de estadísticas
- Upload de fotos
```

**Logger:**
```dart
- Logging estructurado
- Debug/Info/Warning/Error levels
```

### 3. Data Layer (Models)
Define la estructura de datos.

**Modelos:**
- `Vehicle` - Información del vehículo
- `Maintenance` - Registro de mantenimiento
- `Driver` - Información del conductor
- `MaintenanceSchedule` - Configuración de alertas
- `AppUser` - Datos del usuario

**Métodos comunes:**
- `toMap()` - Serializar a Firestore
- `fromMap()` - Deserializar desde Firestore
- `copyWith()` - Crear copia modificada
- Validadores en constructor

---

## Flujo de Datos

### Crear Vehículo
```
AddVehicleScreen (UI)
    ↓
Form validation
    ↓
FirebaseService.addVehicle()
    ↓
Firestore (escritura)
    ↓
VehiclesListScreen (actualiza vía Stream)
```

### Cargar Vehículos
```
VehiclesListScreen
    ↓
StreamBuilder + getUserVehiclesStream()
    ↓
FirebaseService.getUserVehiclesStream()
    ↓
Firestore (Stream de cambios en tiempo real)
    ↓
ListView renderiza datos actualizados
```

### Generar Estadísticas
```
HomeScreen
    ↓
FutureBuilder + getDashboardStats()
    ↓
FirebaseService.getDashboardStats()
    ↓
Itera todos los vehículos y mantenimientos
    ↓
Calcula totales y promedios
    ↓
Retorna Map<String, dynamic>
    ↓
Dashboard renderiza resultados
```

---

## Patrones Utilizados

### 1. Singleton Pattern
```dart
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();
}
```

### 2. Model Pattern
Cada entidad (Vehicle, Maintenance, etc.) sigue:
- Constructor con validación
- `toMap()` y `fromMap()` para Firestore
- `copyWith()` para inmutabilidad
- Propiedades calculadas como getters

### 3. Stream Pattern
Para datos en tiempo real:
```dart
Stream<List<Vehicle>> getUserVehiclesStream(String userId)
```

### 4. Repository Pattern
FirebaseService actúa como repositorio centralizado.

### 5. Validator Pattern
Funciones validadoras centralizadas:
```dart
class Validators {
  static String? validateName(String? value) { ... }
  static String? validateEmail(String? value) { ... }
  // etc.
}
```

---

## Firebase Integration

### Authentication
- Email/Password
- Emulador local en puerto 9099
- Manejo de sesiones

### Firestore Collections
```
users/
├── {userId}/
│   ├── name (string)
│   ├── email (string)
│   ├── phone (string)
│   ├── createdAt (timestamp)
│   └── updatedAt (timestamp)
vehicles/
├── {vehicleId}/
│   ├── userId (FK)
│   ├── brand (string)
│   ├── model (string)
│   ├── plate (string)
│   ├── year (number)
│   ├── currentKm (number)
│   ├── primaryDriverId (FK)
│   ├── photoUrl (string)
│   ├── createdAt (timestamp)
│   └── updatedAt (timestamp)
maintenances/
├── {maintenanceId}/
│   ├── vehicleId (FK)
│   ├── userId (FK)
│   ├── type (string)
│   ├── date (timestamp)
│   ├── km (number)
│   ├── cost (number)
│   ├── workshop (string)
│   ├── notes (string)
│   ├── createdAt (timestamp)
│   └── updatedAt (timestamp)
drivers/
├── {userId}/
│   ├── {driverId}/
│   │   ├── name (string)
│   │   ├── phone (string)
│   │   ├── email (string)
│   │   ├── licenseNumber (string)
│   │   ├── licenseExpiry (timestamp)
│   │   ├── photoUrl (string)
│   │   ├── licensePhotoUrl (string)
│   │   ├── createdAt (timestamp)
│   │   └── updatedAt (timestamp)
```

### Storage
```
/users/{userId}/
├── vehicles/{vehicleId}/{filename}
└── drivers/{driverId}/
    ├── profile/{filename}
    └── license/{filename}
```

---

## Seguridad

### Firebase Rules
- Firestore: Solo usuario autenticado puede acceder a sus datos
- Storage: Acceso restringido por userId

### Validación
- Validación en cliente (antes de enviar)
- Validación implícita en servidor (Firestore rules)

### Manejo de Errores
- Try-catch en operaciones Firebase
- Logging de errores
- Mensajes amigables al usuario

---

## Performance

### Optimizaciones
- StreamBuilder para datos en tiempo real (sin polling)
- Paginación en historial (opcional)
- Caché implícito de Firestore
- Índices en Firestore para queries frecuentes

### Consideraciones
- Límite de 50 vehículos (escalable)
- Límite de 1000 mantenimientos por vehículo (escalable)
- Compresión de fotos recomendada

---

## Extensibilidad

### Agregar nuevo Feature
1. Crear modelo en `models/`
2. Agregar métodos en `FirebaseService`
3. Crear screens en `screens/`
4. Agregar rutas en `main.dart`

### Agregar nueva Screen
```dart
class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: Center(child: Text('Content here')),
    );
  }
}
```

---

## Testing

### Estructura de Testing
- Unit tests para modelos
- Integration tests para Firebase
- Widget tests para screens

### Ejemplo
```dart
test('Vehicle validation', () {
  expect(
    () => Vehicle(
      id: '1',
      userId: 'user1',
      brand: '',  // Invalido
      model: 'Model',
      plate: 'ABC-123',
      year: 2020,
      currentKm: 10000,
      createdAt: DateTime.now(),
    ),
    throwsArgumentError,
  );
});
```

---

## Deployment

### Build APK
```bash
flutter build apk --release
```

### Build AppBundle (Play Store)
```bash
flutter build appbundle --release
```

### Configurar en Firebase
- Descargar `google-services.json`
- Configurar en `android/app/`

