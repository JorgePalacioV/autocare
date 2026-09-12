# Firebase Service API

Documentación completa del `FirebaseService` - la capa de datos de AutoCare.

## Inicialización

```dart
final firebase = FirebaseService();  // Singleton
```

## 🔌 Conexión

### verifyConnection()

Verifica que la conexión con Firebase funciona.

```dart
Future<bool> verifyConnection()
```

**Retorna:**
- `true` - Conexión exitosa
- `false` - Error de conexión

**Ejemplo:**
```dart
if (await firebase.verifyConnection()) {
  print('Firebase conectado');
} else {
  print('Error de conexión');
}
```

**Logs:**
```
[FirebaseService] ℹ Verificando conexión con Firebase...
[FirebaseService] ✓ Conexión verificada
```

---

## 🔐 Autenticación

### signUp()

Registra un nuevo usuario.

```dart
Future<UserCredential> signUp(
  String email,
  String password,
  String name,
)
```

**Parámetros:**
- `email` - Email único (validado)
- `password` - Contraseña (≥6 caracteres)
- `name` - Nombre completo (≥2 caracteres)

**Retorna:** `UserCredential` (usuario autenticado)

**Lanza:** `FirebaseException` en caso de error

**Ejemplo:**
```dart
try {
  final cred = await firebase.signUp(
    email: 'user@example.com',
    password: 'pass123',
    name: 'Juan Pérez',
  );
  print('Usuario: ${cred.user!.uid}');
} on FirebaseException catch (e) {
  print('Error: ${e.message} (${e.code})');
}
```

**Errores comunes:**
- `weak-password` - Contraseña muy débil
- `email-already-in-use` - Email ya registrado
- `invalid-email` - Email inválido

### signIn()

Inicia sesión con un usuario existente.

```dart
Future<UserCredential> signIn(
  String email,
  String password,
)
```

**Parámetros:**
- `email` - Email del usuario
- `password` - Contraseña

**Retorna:** `UserCredential`

**Lanza:** `FirebaseException`

**Ejemplo:**
```dart
try {
  await firebase.signIn(
    email: 'user@example.com',
    password: 'pass123',
  );
  print('Sesión iniciada');
} on FirebaseException catch (e) {
  print('Login fallido: ${e.message}');
}
```

**Errores comunes:**
- `user-not-found` - Usuario no existe
- `wrong-password` - Contraseña incorrecta
- `too-many-requests` - Demasiados intentos

### signOut()

Cierra la sesión actual.

```dart
Future<void> signOut()
```

**Ejemplo:**
```dart
await firebase.signOut();
print('Sesión cerrada');
```

### resetPassword()

Envía email de recuperación de contraseña.

```dart
Future<void> resetPassword(String email)
```

**Parámetros:**
- `email` - Email del usuario

**Lanza:** `FirebaseException`

**Ejemplo:**
```dart
try {
  await firebase.resetPassword('user@example.com');
  print('Email de recuperación enviado');
} on FirebaseException catch (e) {
  print('Error: ${e.message}');
}
```

### getCurrentUser()

Obtiene el usuario autenticado actualmente.

```dart
User? getCurrentUser()
```

**Retorna:** `User?` (null si no hay sesión)

**Ejemplo:**
```dart
final user = firebase.getCurrentUser();
if (user != null) {
  print('Usuario: ${user.email}');
}
```

### Propiedades

```dart
bool get isAuthenticated        // ¿Hay usuario autenticado?
String? get currentUserId       // UID del usuario actual
```

---

## 👤 Usuario

### getUserData()

Obtiene datos completos del usuario (consulta única).

```dart
Future<AppUser?> getUserData(String userId)
```

**Parámetros:**
- `userId` - UID del usuario

**Retorna:** `AppUser?` (null si no existe)

**Ejemplo:**
```dart
final user = await firebase.getUserData('user-123');
if (user != null) {
  print('${user.name} - ${user.email}');
  print('Completo: ${user.isComplete}');
}
```

### getUserDataStream()

Escucha cambios en los datos del usuario (tiempo real).

```dart
Stream<AppUser?> getUserDataStream(String userId)
```

**Retorna:** Stream que emite cambios

**Ejemplo:**
```dart
firebase.getUserDataStream('user-123').listen((user) {
  if (user != null) {
    print('Datos actualizados: ${user.phone}');
  }
});
```

**Ventaja:** Se actualiza automáticamente si datos cambian en otra pantalla/dispositivo

### updateUserData()

Actualiza todos los datos del usuario.

```dart
Future<void> updateUserData(
  String userId,
  AppUser user,
)
```

**Ejemplo:**
```dart
final updatedUser = user.copyWith(
  name: 'Nuevo Nombre',
  updatedAt: DateTime.now(),
);
await firebase.updateUserData('user-123', updatedUser);
```

### updateUserProfile()

Actualiza solo campos específicos del perfil.

```dart
Future<void> updateUserProfile(
  String userId,
  {String? phone, String? photoUrl},
)
```

**Ejemplo:**
```dart
await firebase.updateUserProfile(
  'user-123',
  phone: '+5711234567',
  photoUrl: 'https://storage.google.com/...',
);
```

**Ventaja:** Más eficiente que `updateUserData()` para cambios parciales

---

## 🚗 Vehículos

### addVehicle()

Agrega un vehículo nuevo.

```dart
Future<void> addVehicle(Vehicle vehicle)
```

**Ejemplo:**
```dart
final vehicle = Vehicle(
  id: firebase.generateId(),
  userId: firebase.currentUserId!,
  brand: 'Toyota',
  model: 'Corolla',
  plate: 'ABC-123',
  year: 2020,
  currentKm: 45000,
  createdAt: DateTime.now(),
);
await firebase.addVehicle(vehicle);
```

### getVehicle()

Obtiene un vehículo por ID.

```dart
Future<Vehicle?> getVehicle(String vehicleId)
```

**Retorna:** `Vehicle?` (null si no existe)

### getUserVehicles()

Obtiene todos los vehículos del usuario (consulta única).

```dart
Future<List<Vehicle>> getUserVehicles(String userId)
```

**Retorna:** List<Vehicle>

**Orden:** Más recientes primero

**Ejemplo:**
```dart
final vehicles = await firebase.getUserVehicles('user-123');
for (final v in vehicles) {
  print('${v.displayName} - ${v.formattedKm}');
  print('Edad: ${v.age} años');
}
```

### getUserVehiclesStream()

Escucha cambios en vehículos del usuario (tiempo real).

```dart
Stream<List<Vehicle>> getUserVehiclesStream(String userId)
```

**Ejemplo:**
```dart
firebase.getUserVehiclesStream('user-123').listen((vehicles) {
  print('${vehicles.length} vehículos');
});
```

### updateVehicle()

Actualiza un vehículo.

```dart
Future<void> updateVehicle(Vehicle vehicle)
```

**Ejemplo:**
```dart
final updated = vehicle.updateKm(50000);  // Incrementar km
await firebase.updateVehicle(updated);
```

**Nota:** `updateKm()` valida que km no disminuya

### deleteVehicle()

Elimina un vehículo.

```dart
Future<void> deleteVehicle(String vehicleId)
```

**Precaución:** Elimina el vehículo pero no sus mantenimientos

---

## 🔧 Mantenimientos

### addMaintenance()

Registra un nuevo mantenimiento.

```dart
Future<void> addMaintenance(Maintenance maintenance)
```

**Ejemplo:**
```dart
final maintenance = Maintenance(
  id: firebase.generateId(),
  vehicleId: 'vehicle-123',
  userId: 'user-123',
  type: MaintenanceType.oil,
  date: DateTime.now(),
  km: 50000,
  cost: 45.50,
  workshop: 'Taller ABC',
  notes: 'Cambio de aceite 5W30',
  createdAt: DateTime.now(),
);
await firebase.addMaintenance(maintenance);
```

### getMaintenance()

Obtiene un mantenimiento por ID.

```dart
Future<Maintenance?> getMaintenance(String maintenanceId)
```

### getVehicleMaintenances()

Obtiene historial de mantenimientos de un vehículo (consulta única).

```dart
Future<List<Maintenance>> getVehicleMaintenances(String vehicleId)
```

**Orden:** Más recientes primero

**Ejemplo:**
```dart
final maintenances = await firebase.getVehicleMaintenances('vehicle-123');
double totalCost = 0;
for (final m in maintenances) {
  print('${m.type.displayName}: ${m.formattedCost}');
  totalCost += m.cost;
}
print('Total: \$${totalCost.toStringAsFixed(2)}');
```

### getVehicleMaintenancesStream()

Escucha cambios en mantenimientos (tiempo real).

```dart
Stream<List<Maintenance>> getVehicleMaintenancesStream(String vehicleId)
```

**Ejemplo:**
```dart
firebase.getVehicleMaintenancesStream('vehicle-123').listen((maintenances) {
  print('${maintenances.length} registros');
});
```

### getUserMaintenances()

Obtiene historial completo del usuario (últimos 50 por defecto).

```dart
Future<List<Maintenance>> getUserMaintenances(
  String userId,
  {int limit = 50},
)
```

**Orden:** Más recientes primero

**Ejemplo:**
```dart
final all = await firebase.getUserMaintenances('user-123', limit: 100);
final recent30 = all.where((m) => m.isRecent).toList();
```

### updateMaintenance()

Actualiza un mantenimiento existente.

```dart
Future<void> updateMaintenance(Maintenance maintenance)
```

### deleteMaintenance()

Elimina un mantenimiento.

```dart
Future<void> deleteMaintenance(String maintenanceId)
```

---

## 📊 Estadísticas

### getMaintenanceStats()

Calcula estadísticas de mantenimiento del usuario.

```dart
Future<Map<String, dynamic>> getMaintenanceStats(String userId)
```

**Retorna:**
```dart
{
  'totalCount': int,              // Total de mantenimientos
  'totalCost': double,            // Suma de costos
  'averageCost': double,          // Costo promedio
  'lastMaintenanceDate': DateTime?,
  'monthsWithoutMaintenance': int?,
}
```

**Ejemplo:**
```dart
final stats = await firebase.getMaintenanceStats('user-123');
print('Total gastado: \$${stats['totalCost']}');
print('Promedio: \$${stats['averageCost']}');
print('Últimos meses sin servicio: ${stats['monthsWithoutMaintenance']}');
```

---

## 🛠️ Utilidades

### generateId()

Genera un ID único (UUID v4).

```dart
String generateId()
```

**Ejemplo:**
```dart
final id = firebase.generateId();
// "550e8400-e29b-41d4-a716-446655440000"
```

### userExists()

Verifica si un usuario existe.

```dart
Future<bool> userExists(String userId)
```

**Retorna:** `true` si existe, `false` si no

---

## 🐛 Manejo de Errores

### FirebaseException

Excepción personalizada del servicio.

```dart
class FirebaseException implements Exception {
  final String message;
  final String? code;  // Código de error Firebase
}
```

**Ejemplo:**
```dart
try {
  await firebase.signIn(email, password);
} on FirebaseException catch (e) {
  if (e.code == 'user-not-found') {
    print('Usuario no existe');
  } else if (e.code == 'wrong-password') {
    print('Contraseña incorrecta');
  } else {
    print('Error: ${e.message}');
  }
}
```

---

## 📝 Logging

Todos los métodos generan logs automáticamente.

```dart
Logger.info('Iniciando operación', tag: '[FirebaseService]');
Logger.success('Operación exitosa', tag: '[FirebaseService]');
Logger.error('Error en operación', tag: '[FirebaseService]');
```

**Deshabilitar logs en producción:**
```dart
Logger.setDebugMode(false);
```

---

## 💡 Buenas Prácticas

### ✅ Hacer

```dart
// Usar generateId() para nuevos registros
final id = firebase.generateId();

// Usar try-catch para operaciones
try {
  await firebase.addVehicle(vehicle);
} catch (e) {
  Logger.error('Error: $e', tag: '[MyScreen]');
}

// Usar Streams para datos que cambian frecuentemente
firebase.getUserVehiclesStream(userId).listen((vehicles) {
  setState(() => this.vehicles = vehicles);
});

// Usar copyWith() para actualizaciones
final updated = user.copyWith(phone: newPhone);
await firebase.updateUserData(userId, updated);
```

### ❌ No Hacer

```dart
// No usar print() - usar Logger
print('debug');  // ❌ Usar Logger.log() en su lugar

// No ignorar excepciones
await firebase.addVehicle(vehicle);  // ❌ Necesita try-catch

// No hacer queries sin filtro
// (Si fuese posible - Firestore bloquea esto)

// No actualizar sin validar primero
await firebase.updateVehicle(vehicle);  // Sin validar datos
```

---

**Versión:** 1.0.0  
**Actualizado:** 2026-09-10
