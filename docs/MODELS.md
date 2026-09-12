# Especificación de Modelos

## AppUser (Usuario)

Representa un usuario de la aplicación.

### Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | `String` | ✅ | UID de Firebase Auth |
| `email` | `String` | ✅ | Email único, validado |
| `name` | `String` | ✅ | Nombre completo (min 2 caracteres) |
| `phone` | `String?` | ⬜ | Teléfono de contacto |
| `photoUrl` | `String?` | ⬜ | URL de foto de perfil |
| `createdAt` | `DateTime` | ✅ | Fecha de creación |
| `updatedAt` | `DateTime?` | ⬜ | Última actualización |

### Validaciones

```dart
AppUser(
  id: 'abc123',
  email: 'user@example.com',  // Debe ser email válido
  name: 'Juan Pérez',         // Min 2 caracteres
  phone: '+5711234567',
  photoUrl: 'https://...',
  createdAt: DateTime.now(),
);
// Lanza: ArgumentError si email o name inválidos
```

### Getters

| Getter | Tipo | Descripción |
|--------|------|-------------|
| `displayName` | `String` | Primer nombre |
| `isComplete` | `bool` | Tiene phone y photoUrl |
| `hasPhone` | `bool` | Tiene teléfono |
| `isNewUser` | `bool` | Registrado hace menos de 7 días |

### Métodos

```dart
// Actualizar parcialmente
AppUser copiedUser = user.copyWith(
  phone: '+5711234567',
  updatedAt: DateTime.now(),
);

// Convertir
Map<String, dynamic> map = user.toMap();
AppUser fromMap = AppUser.fromMap(map);

// Comparación
bool same = user1 == user2;  // Por id y email
```

### Firestore

**Colección:** `users`  
**Documento:** `{userId}`

```json
{
  "id": "uid123",
  "email": "user@example.com",
  "name": "Juan Pérez",
  "phone": "+5711234567",
  "photoUrl": "https://...",
  "createdAt": "2026-09-10T00:00:00.000Z",
  "updatedAt": "2026-09-10T12:30:00.000Z"
}
```

---

## Vehicle (Vehículo)

Representa un vehículo registrado por un usuario.

### Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | `String` | ✅ | UUID único |
| `userId` | `String` | ✅ | Propietario |
| `brand` | `String` | ✅ | Marca (Toyota, Honda, etc) |
| `model` | `String` | ✅ | Modelo (Corolla, Civic, etc) |
| `plate` | `String` | ✅ | Placa (no puede estar vacía) |
| `year` | `int` | ✅ | Año (1886-presente+1) |
| `currentKm` | `int` | ✅ | Kilometraje actual (≥0) |
| `color` | `String?` | ⬜ | Color del vehículo |
| `vin` | `String?` | ⬜ | Número VIN |
| `createdAt` | `DateTime` | ✅ | Fecha de registro |
| `updatedAt` | `DateTime?` | ⬜ | Última actualización |

### Validaciones

```dart
Vehicle(
  id: 'uuid-123',
  userId: 'user-123',
  brand: 'Toyota',
  model: 'Corolla',
  plate: 'ABC-123',         // No vacía
  year: 2020,               // 1886 a 2027
  currentKm: 45000,         // ≥ 0
  createdAt: DateTime.now(),
);
// Lanza: ArgumentError si datos inválidos
```

### Getters

| Getter | Tipo | Descripción |
|--------|------|-------------|
| `displayName` | `String` | "Brand Model" (Toyota Corolla) |
| `age` | `int` | Años desde año de fabricación |
| `isNewCar` | `bool` | Menos de 2 años |
| `isHighMileage` | `bool` | Más de 200k km |
| `formattedKm` | `String` | "45000 km" |
| `estimatedValue` | `double` | Valor estimado (depreciación) |

### Métodos

```dart
// Actualizar kilometraje (no puede disminuir)
Vehicle updatedVehicle = vehicle.updateKm(50000);
// Lanza: ArgumentError si newKm < currentKm

// Actualizar parcialmente
Vehicle copied = vehicle.copyWith(
  currentKm: 50000,
  updatedAt: DateTime.now(),
);

// Conversión
Map<String, dynamic> map = vehicle.toMap();
Vehicle fromMap = Vehicle.fromMap(map);
```

### Firestore

**Colección:** `vehicles`  
**Documento:** `{vehicleId}`

```json
{
  "id": "uuid-123",
  "userId": "user-123",
  "brand": "Toyota",
  "model": "Corolla",
  "plate": "ABC-123",
  "year": 2020,
  "currentKm": 45000,
  "color": "Blanco",
  "vin": "JTDKP5C23G0123456",
  "createdAt": "2026-08-01T00:00:00.000Z",
  "updatedAt": "2026-09-10T00:00:00.000Z"
}
```

### Índices Firestore

```
Collection: vehicles
- Índice 1: userId (Asc), createdAt (Desc)
```

---

## Maintenance (Mantenimiento)

Representa un servicio de mantenimiento realizado en un vehículo.

### MaintenanceType (Enum)

```dart
enum MaintenanceType {
  oil,           // Cambio de Aceite
  filter,        // Filtro
  tires,         // Llantas
  brakes,        // Frenos
  battery,       // Batería
  inspection,    // Inspección
  transmission,  // Transmisión
  suspension,    // Suspensión
  electrical,    // Eléctrica
  bodywork,      // Chapa y Pintura
  other,         // Otro
}

extension MaintenanceTypeExt on MaintenanceType {
  String get displayName;      // "Cambio de Aceite"
  String get shortName;        // "Cambio"
  bool get isRoutine;          // oil, filter, inspection
}
```

### Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | `String` | ✅ | UUID único |
| `vehicleId` | `String` | ✅ | Vehículo asociado |
| `userId` | `String` | ✅ | Usuario propietario |
| `type` | `MaintenanceType` | ✅ | Tipo de servicio |
| `date` | `DateTime` | ✅ | Fecha (no futura) |
| `km` | `int` | ✅ | Kilometraje (≥0) |
| `cost` | `double` | ✅ | Costo en dólares (≥0) |
| `workshop` | `String?` | ⬜ | Nombre del taller |
| `notes` | `String?` | ⬜ | Observaciones |
| `photoUrls` | `List<String>?` | ⬜ | URLs de fotos |
| `createdAt` | `DateTime` | ✅ | Fecha de registro |
| `updatedAt` | `DateTime?` | ⬜ | Última actualización |

### Validaciones

```dart
Maintenance(
  id: 'uuid-456',
  vehicleId: 'vehicle-123',
  userId: 'user-123',
  type: MaintenanceType.oil,
  date: DateTime(2026, 9, 10),    // No futura
  km: 50000,                       // ≥ 0
  cost: 45.50,                     // ≥ 0
  workshop: 'Taller ABC',
  notes: 'Cambio de aceite 5W30',
  photoUrls: ['https://...'],
  createdAt: DateTime.now(),
);
// Lanza: ArgumentError si datos inválidos
```

### Getters

| Getter | Tipo | Descripción |
|--------|------|-------------|
| `isRecent` | `bool` | Dentro de últimos 30 días |
| `daysAgo` | `int` | Días desde la fecha |
| `monthsAgo` | `int` | Meses aproximados |
| `formattedCost` | `String` | "$45.50" |
| `formattedDate` | `String` | "10/9/2026" |
| `hasPhotos` | `bool` | Tiene fotos adjuntas |
| `isRoutineService` | `bool` | Oil, filter o inspection |

### Métodos

```dart
// Actualizar parcialmente
Maintenance updated = maintenance.copyWith(
  cost: 50.00,
  notes: 'Actualizado',
  updatedAt: DateTime.now(),
);

// Conversión
Map<String, dynamic> map = maintenance.toMap();
Maintenance fromMap = Maintenance.fromMap(map);
```

### Firestore

**Colección:** `maintenances`  
**Documento:** `{maintenanceId}`

```json
{
  "id": "uuid-456",
  "vehicleId": "vehicle-123",
  "userId": "user-123",
  "type": "oil",
  "date": "2026-09-10T00:00:00.000Z",
  "km": 50000,
  "cost": 45.50,
  "workshop": "Taller ABC",
  "notes": "Cambio de aceite 5W30",
  "photoUrls": ["https://..."],
  "createdAt": "2026-09-10T00:00:00.000Z",
  "updatedAt": "2026-09-10T12:00:00.000Z"
}
```

### Índices Firestore

```
Collection: maintenances
- Índice 1: vehicleId (Asc), date (Desc)
- Índice 2: userId (Asc), date (Desc)
```

---

## Relaciones

```
AppUser (1)
  ├── → (1:N) Vehicle
  │       └── → (1:N) Maintenance
  └── Propietario de todos sus vehículos
      y todos los mantenimientos

Ejemplo:
User "user-123" Juan Pérez
├── Vehicle "vehicle-1" (Toyota Corolla)
│   ├── Maintenance "m1" (Oil Change)
│   ├── Maintenance "m2" (Tire Rotation)
│   └── Maintenance "m3" (Inspection)
└── Vehicle "vehicle-2" (Honda Civic)
    └── Maintenance "m4" (Battery Replace)
```

---

## Restricciones en Firestore

### Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Solo usuarios autenticados
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /vehicles/{vehicleId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    match /maintenances/{maintenanceId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## Crear Nuevo Modelo

### Checklist

- [ ] Clase con campos finales
- [ ] Validaciones en constructor
- [ ] Implementar `toMap()` y `fromMap()`
- [ ] Agregar getters útiles
- [ ] Implementar `copyWith()`
- [ ] Implementar `==` y `hashCode`
- [ ] Documentar en esta sección
- [ ] Exportar en `models/models.dart`
- [ ] Agregar método en `FirebaseService`
- [ ] Actualizar `FIREBASE_API.md`

---

**Actualizado:** 2026-09-10
