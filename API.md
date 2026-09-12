# 📡 API Documentation

## Firebase Service Methods

All Firebase operations are centralized in `lib/services/firebase_service.dart`.

---

## Authentication

### `signUp(String email, String password, String displayName)`
Registers a new user.

**Parameters:**
- `email` (String): User email
- `password` (String): User password
- `displayName` (String): User display name

**Returns:** `Future<void>`

**Throws:** FirebaseAuthException

**Example:**
```dart
await firebaseService.signUp(
  'user@email.com',
  'password123',
  'John Doe',
);
```

---

### `signIn(String email, String password)`
Authenticates user with email and password.

**Parameters:**
- `email` (String): User email
- `password` (String): User password

**Returns:** `Future<void>`

**Throws:** FirebaseAuthException

**Example:**
```dart
await firebaseService.signIn('user@email.com', 'password123');
```

---

### `signOut()`
Signs out the current user.

**Returns:** `Future<void>`

**Example:**
```dart
await firebaseService.signOut();
```

---

### `get currentUserId`
Gets the current authenticated user ID.

**Returns:** `String?` (null if not authenticated)

**Example:**
```dart
final userId = firebaseService.currentUserId;
if (userId != null) {
  // User is authenticated
}
```

---

## Users

### `getUserData(String userId)`
Fetches user profile data.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Future<AppUser>`

**Throws:** FirebaseException

**Example:**
```dart
final user = await firebaseService.getUserData('user123');
print(user.displayName);
```

---

### `updateUserData(String userId, AppUser user)`
Updates user profile.

**Parameters:**
- `userId` (String): User ID
- `user` (AppUser): Updated user data

**Returns:** `Future<void>`

**Example:**
```dart
final updatedUser = currentUser.copyWith(
  phone: '+5735551234',
);
await firebaseService.updateUserData(userId, updatedUser);
```

---

## Vehicles

### `addVehicle(String userId, Vehicle vehicle)`
Creates a new vehicle.

**Parameters:**
- `userId` (String): Owner ID
- `vehicle` (Vehicle): Vehicle data

**Returns:** `Future<void>`

**Throws:** FirebaseException

**Example:**
```dart
final vehicle = Vehicle(
  id: 'auto_generated_id',
  userId: userId,
  brand: 'Toyota',
  model: 'Corolla',
  plate: 'ABC-123',
  year: 2020,
  currentKm: 50000,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await firebaseService.addVehicle(userId, vehicle);
```

---

### `updateVehicle(String vehicleId, Vehicle vehicle)`
Updates vehicle information.

**Parameters:**
- `vehicleId` (String): Vehicle ID
- `vehicle` (Vehicle): Updated data

**Returns:** `Future<void>`

**Example:**
```dart
final updated = vehicle.copyWith(currentKm: 55000);
await firebaseService.updateVehicle(vehicle.id, updated);
```

---

### `deleteVehicle(String vehicleId)`
Deletes a vehicle.

**Parameters:**
- `vehicleId` (String): Vehicle ID

**Returns:** `Future<void>`

**Example:**
```dart
await firebaseService.deleteVehicle('vehicle123');
```

---

### `getUserVehicles(String userId)`
Fetches all vehicles for a user.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Future<List<Vehicle>>`

**Example:**
```dart
final vehicles = await firebaseService.getUserVehicles(userId);
vehicles.forEach((v) => print('${v.brand} ${v.model}'));
```

---

### `getUserVehiclesStream(String userId)`
Real-time stream of user vehicles.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Stream<List<Vehicle>>`

**Example:**
```dart
firebaseService.getUserVehiclesStream(userId).listen((vehicles) {
  print('Vehicles updated: ${vehicles.length}');
});
```

---

## Maintenance Records

### `addMaintenance(String vehicleId, Maintenance maintenance)`
Records a maintenance event.

**Parameters:**
- `vehicleId` (String): Associated vehicle
- `maintenance` (Maintenance): Maintenance data

**Returns:** `Future<void>`

**Example:**
```dart
final maintenance = Maintenance(
  id: 'auto_generated',
  vehicleId: vehicleId,
  userId: userId,
  type: MaintenanceType.oil,
  date: DateTime.now(),
  km: 50000,
  cost: 45.00,
  workshop: 'AutoShop',
  notes: 'Oil change',
  createdAt: DateTime.now(),
);
await firebaseService.addMaintenance(vehicleId, maintenance);
```

---

### `updateMaintenance(String maintenanceId, Maintenance maintenance)`
Updates a maintenance record.

**Parameters:**
- `maintenanceId` (String): Maintenance ID
- `maintenance` (Maintenance): Updated data

**Returns:** `Future<void>`

---

### `deleteMaintenance(String maintenanceId)`
Deletes a maintenance record.

**Parameters:**
- `maintenanceId` (String): Maintenance ID

**Returns:** `Future<void>`

---

### `getVehicleMaintenances(String vehicleId)`
Fetches all maintenance records for a vehicle.

**Parameters:**
- `vehicleId` (String): Vehicle ID

**Returns:** `Future<List<Maintenance>>`

---

### `getVehicleMaintenancesStream(String vehicleId)`
Real-time stream of maintenance records.

**Parameters:**
- `vehicleId` (String): Vehicle ID

**Returns:** `Stream<List<Maintenance>>`

---

## Drivers

### `addDriver(String userId, Driver driver)`
Creates a new driver profile.

**Parameters:**
- `userId` (String): Owner ID
- `driver` (Driver): Driver data

**Returns:** `Future<String>` (driver ID)

**Example:**
```dart
final driver = Driver(
  id: 'auto_generated',
  userId: userId,
  name: 'John Smith',
  phone: '+5735551234',
  email: 'john@email.com',
  licenseNumber: 'DL123456',
  licenseExpiry: DateTime(2026, 12, 31),
  createdAt: DateTime.now(),
);
await firebaseService.addDriver(userId, driver);
```

---

### `updateDriver(String userId, String driverId, Driver driver)`
Updates driver information.

**Parameters:**
- `userId` (String): Owner ID
- `driverId` (String): Driver ID
- `driver` (Driver): Updated data

**Returns:** `Future<void>`

---

### `deleteDriver(String userId, String driverId)`
Removes a driver profile.

**Parameters:**
- `userId` (String): Owner ID
- `driverId` (String): Driver ID

**Returns:** `Future<void>`

---

### `getDriver(String userId, String driverId)`
Fetches driver details.

**Parameters:**
- `userId` (String): Owner ID
- `driverId` (String): Driver ID

**Returns:** `Future<Driver?>`

---

### `getDrivers(String userId)`
Fetches all drivers for a user.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Future<List<Driver>>`

---

## Photos

### `uploadVehiclePhoto(String userId, String vehicleId, File imageFile)`
Uploads vehicle photo to Storage.

**Parameters:**
- `userId` (String): Owner ID
- `vehicleId` (String): Vehicle ID
- `imageFile` (File): Image file

**Returns:** `Future<String>` (download URL)

**Timeout:** 10 seconds

**Example:**
```dart
final file = File('/path/to/image.jpg');
final url = await firebaseService.uploadVehiclePhoto(userId, vehicleId, file);
```

---

### `uploadDriverPhoto(String userId, String driverId, File imageFile)`
Uploads driver profile photo.

**Parameters:**
- `userId` (String): Owner ID
- `driverId` (String): Driver ID
- `imageFile` (File): Image file

**Returns:** `Future<String>` (download URL)

**Timeout:** 10 seconds

---

### `uploadLicensePhoto(String userId, String driverId, File imageFile)`
Uploads driver license photo.

**Parameters:**
- `userId` (String): Owner ID
- `driverId` (String): Driver ID
- `imageFile` (File): Image file

**Returns:** `Future<String>` (download URL)

**Timeout:** 10 seconds

---

## Maintenance Schedules

### `getMaintenanceSchedule(String userId, String vehicleId)`
Fetches alert configuration for a vehicle.

**Parameters:**
- `userId` (String): Owner ID
- `vehicleId` (String): Vehicle ID

**Returns:** `Future<MaintenanceSchedule>`

---

### `setMaintenanceSchedule(String userId, String vehicleId, MaintenanceSchedule schedule)`
Sets alert intervals for a vehicle.

**Parameters:**
- `userId` (String): Owner ID
- `vehicleId` (String): Vehicle ID
- `schedule` (MaintenanceSchedule): Configuration

**Returns:** `Future<void>`

---

### `getAllMaintenanceSchedules(String userId)`
Fetches all alert configurations.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Future<List<MaintenanceSchedule>>`

---

## Analytics

### `getDashboardStats(String userId)`
Calculates dashboard statistics.

**Parameters:**
- `userId` (String): User ID

**Returns:** `Future<Map<String, dynamic>>`

**Response Map:**
```dart
{
  'totalVehicles': int,
  'totalMaintenances': int,
  'totalCost': double,
  'averageCostPerMaintenance': double,
  'daysLastMaintenance': int?,
}
```

**Example:**
```dart
final stats = await firebaseService.getDashboardStats(userId);
print('Total vehicles: ${stats['totalVehicles']}');
print('Total cost: \$${stats['totalCost']}');
```

---

### `getVehicleAlerts(String vehicleId)`
Calculates alert status for a vehicle.

**Parameters:**
- `vehicleId` (String): Vehicle ID

**Returns:** `Future<Map<MaintenanceType, AlertStatus>>`

**Returns AlertStatus:**
- `ok` - No action needed
- `warning` - Approaching interval
- `overdue` - Maintenance due

---

## Error Handling

All Firebase methods throw appropriate exceptions:
- `FirebaseAuthException` - Auth errors
- `FirebaseException` - Firebase/Firestore errors
- `PlatformException` - Platform-specific errors
- `TimeoutException` - Upload timeout (10s)

**Pattern:**
```dart
try {
  await firebaseService.addVehicle(userId, vehicle);
} on FirebaseAuthException catch (e) {
  print('Auth error: ${e.message}');
} on FirebaseException catch (e) {
  print('Firebase error: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

---

## Model Validation

### Vehicle
- `brand` - Required, non-empty
- `model` - Required, non-empty
- `plate` - Required, non-empty
- `year` - 1900-2101
- `currentKm` - Non-negative integer
- `photoUrl` - Optional URL

### Maintenance
- `type` - Required MaintenanceType
- `date` - Required timestamp
- `km` - Non-negative integer
- `cost` - Non-negative double
- `workshop` - Required, non-empty
- `notes` - Optional

### Driver
- `name` - Required, min 2 chars
- `phone` - Optional, min 7 chars
- `email` - Optional, valid format
- `licenseNumber` - Required, min 5 chars
- `licenseExpiry` - Optional timestamp

---

## Best Practices

1. **Always check currentUserId** before operations
2. **Use Streams** for real-time data in UI
3. **Use Futures** for one-off data fetches
4. **Wrap Firebase calls** in try-catch blocks
5. **Log errors** using Logger utility
6. **Validate input** before sending to Firebase
7. **Handle null values** gracefully
8. **Cache frequently accessed data** if needed
9. **Use copyWith()** to ensure immutability
10. **Test with Emulator** before production

