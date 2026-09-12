import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'logger.dart';

class FirebaseException implements Exception {
  final String message;
  final String? code;
  FirebaseException(this.message, {this.code});
  @override
  String toString() => 'FirebaseException: $message${code != null ? ' ($code)' : ''}';
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _logTag = '[FirebaseService]';

  // ============ EMULADORES ============

  Future<void> connectToEmulators() async {
    try {
      Logger.info('Conectando a emuladores locales...', tag: _logTag);

      await _auth.useAuthEmulator('localhost', 9099);
      Logger.success('✓ Auth Emulator conectado (localhost:9099)', tag: _logTag);

      _firestore.useFirestoreEmulator('localhost', 8080);
      Logger.success('✓ Firestore Emulator conectado (localhost:8080)', tag: _logTag);

      _storage.useStorageEmulator('localhost', 9199);
      Logger.success('✓ Storage Emulator conectado (localhost:9199)', tag: _logTag);
    } catch (e) {
      Logger.error('Error conectando a emuladores: $e', tag: _logTag);
    }
  }

  // ============ CONEXIÓN Y VERIFICACIÓN ============

  Future<bool> verifyConnection() async {
    try {
      Logger.info('Verificando conexión con Firebase...', tag: _logTag);
      await _firestore.collection('_test').doc('_ping').set({'timestamp': FieldValue.serverTimestamp()});
      await _firestore.collection('_test').doc('_ping').delete();
      Logger.success('Conexión verificada', tag: _logTag);
      return true;
    } catch (e) {
      Logger.error('Error de conexión: $e', tag: _logTag);
      return false;
    }
  }

  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  // ============ AUTENTICACIÓN ============

  Future<UserCredential> signUp(String email, String password, String name) async {
    try {
      Logger.log('Registrando usuario: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());
      Logger.log('✓ Usuario registrado: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Logger.log('✗ Error de registro: ${e.code} - ${e.message}');
      throw FirebaseException(e.message ?? 'Error de registro', code: e.code);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      Logger.log('Iniciando sesión: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.log('✓ Sesión iniciada: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Logger.log('✗ Error de login: ${e.code}');
      throw FirebaseException(e.message ?? 'Error de autenticación', code: e.code);
    }
  }

  Future<void> signOut() async {
    try {
      Logger.log('Cerrando sesión...');
      await _auth.signOut();
      Logger.log('✓ Sesión cerrada');
    } catch (e) {
      Logger.log('✗ Error al cerrar sesión: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      Logger.log('Enviando correo de reseteo: $email');
      await _auth.sendPasswordResetEmail(email: email);
      Logger.log('✓ Correo de reseteo enviado');
    } on FirebaseAuthException catch (e) {
      throw FirebaseException(e.message ?? 'Error al resetear contraseña', code: e.code);
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  // ============ USUARIO ============

  Future<AppUser?> getUserData(String userId) async {
    try {
      Logger.log('Obteniendo datos del usuario: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.log('✗ Error al obtener usuario: $e');
      rethrow;
    }
  }

  Stream<AppUser?> getUserDataStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> updateUserData(String userId, AppUser user) async {
    try {
      Logger.log('Actualizando usuario: $userId');
      await _firestore.collection('users').doc(userId).update(user.toMap());
      Logger.log('✓ Usuario actualizado');
    } catch (e) {
      Logger.log('✗ Error al actualizar usuario: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String userId, {String? phone, String? photoUrl}) async {
    try {
      Logger.log('Actualizando perfil: $userId');
      final updates = <String, dynamic>{};
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      updates['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(userId).update(updates);
      Logger.log('✓ Perfil actualizado');
    } catch (e) {
      Logger.log('✗ Error al actualizar perfil: $e');
      rethrow;
    }
  }

  // ============ VEHÍCULOS ============

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      Logger.log('Agregando vehículo: ${vehicle.plate}');
      await _firestore.collection('vehicles').doc(vehicle.id).set(vehicle.toMap());
      Logger.log('✓ Vehículo agregado: ${vehicle.id}');
    } catch (e) {
      Logger.log('✗ Error al agregar vehículo: $e');
      rethrow;
    }
  }

  Future<Vehicle?> getVehicle(String vehicleId) async {
    try {
      final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
      if (doc.exists) {
        return Vehicle.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.log('✗ Error al obtener vehículo: $e');
      rethrow;
    }
  }

  Future<List<Vehicle>> getUserVehicles(String userId) async {
    try {
      Logger.log('Obteniendo vehículos del usuario: $userId');
      final snapshot = await _firestore
          .collection('vehicles')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final vehicles = snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
      Logger.log('✓ ${vehicles.length} vehículos encontrados');
      return vehicles;
    } catch (e) {
      Logger.log('✗ Error al obtener vehículos: $e');
      rethrow;
    }
  }

  Stream<List<Vehicle>> getUserVehiclesStream(String userId) {
    return _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      Logger.log('Actualizando vehículo: ${vehicle.id}');
      await _firestore.collection('vehicles').doc(vehicle.id).update(vehicle.toMap());
      Logger.log('✓ Vehículo actualizado');
    } catch (e) {
      Logger.log('✗ Error al actualizar vehículo: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      Logger.log('Eliminando vehículo: $vehicleId');
      await _firestore.collection('vehicles').doc(vehicleId).delete();
      Logger.log('✓ Vehículo eliminado');
    } catch (e) {
      Logger.log('✗ Error al eliminar vehículo: $e');
      rethrow;
    }
  }

  // ============ MANTENIMIENTOS ============

  Future<void> addMaintenance(Maintenance maintenance) async {
    try {
      Logger.log('Agregando mantenimiento: ${maintenance.type.displayName}');
      await _firestore.collection('maintenances').doc(maintenance.id).set(maintenance.toMap());
      Logger.log('✓ Mantenimiento agregado: ${maintenance.id}');
    } catch (e) {
      Logger.log('✗ Error al agregar mantenimiento: $e');
      rethrow;
    }
  }

  Future<Maintenance?> getMaintenance(String maintenanceId) async {
    try {
      final doc = await _firestore.collection('maintenances').doc(maintenanceId).get();
      if (doc.exists) {
        return Maintenance.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.log('✗ Error al obtener mantenimiento: $e');
      rethrow;
    }
  }

  Future<List<Maintenance>> getVehicleMaintenances(String vehicleId) async {
    try {
      Logger.log('Obteniendo mantenimientos del vehículo: $vehicleId');
      final snapshot = await _firestore
          .collection('maintenances')
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('date', descending: true)
          .get();

      final maintenances = snapshot.docs.map((doc) => Maintenance.fromMap(doc.data())).toList();
      Logger.log('✓ ${maintenances.length} mantenimientos encontrados');
      return maintenances;
    } catch (e) {
      Logger.log('✗ Error al obtener mantenimientos: $e');
      rethrow;
    }
  }

  Stream<List<Maintenance>> getVehicleMaintenancesStream(String vehicleId) {
    return _firestore
        .collection('maintenances')
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Maintenance.fromMap(doc.data())).toList());
  }

  Future<List<Maintenance>> getUserMaintenances(String userId, {int limit = 50}) async {
    try {
      Logger.log('Obteniendo historial de mantenimientos del usuario: $userId');
      final snapshot = await _firestore
          .collection('maintenances')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final maintenances = snapshot.docs.map((doc) => Maintenance.fromMap(doc.data())).toList();
      Logger.log('✓ ${maintenances.length} mantenimientos en historial');
      return maintenances;
    } catch (e) {
      Logger.log('✗ Error al obtener historial: $e');
      rethrow;
    }
  }

  Future<void> updateMaintenance(Maintenance maintenance) async {
    try {
      Logger.log('Actualizando mantenimiento: ${maintenance.id}');
      await _firestore.collection('maintenances').doc(maintenance.id).update(maintenance.toMap());
      Logger.log('✓ Mantenimiento actualizado');
    } catch (e) {
      Logger.log('✗ Error al actualizar mantenimiento: $e');
      rethrow;
    }
  }

  Future<void> deleteMaintenance(String maintenanceId) async {
    try {
      Logger.log('Eliminando mantenimiento: $maintenanceId');
      await _firestore.collection('maintenances').doc(maintenanceId).delete();
      Logger.log('✓ Mantenimiento eliminado');
    } catch (e) {
      Logger.log('✗ Error al eliminar mantenimiento: $e');
      rethrow;
    }
  }

  // ============ ESTADÍSTICAS ============

  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    try {
      Logger.log('Calculando estadísticas del vehículo: $vehicleId');
      final maintenances = await getVehicleMaintenances(vehicleId);

      double totalCost = 0;
      int totalCount = maintenances.length;
      DateTime? lastMaintenance;
      int maxKm = 0;

      for (final m in maintenances) {
        totalCost += m.cost;
        maxKm = maxKm < m.km ? m.km : maxKm;
        if (lastMaintenance == null || m.date.isAfter(lastMaintenance)) {
          lastMaintenance = m.date;
        }
      }

      final stats = {
        'totalCount': totalCount,
        'totalCost': totalCost,
        'averageCost': totalCount > 0 ? totalCost / totalCount : 0.0,
        'lastMaintenanceDate': lastMaintenance,
        'daysLastMaintenance': lastMaintenance != null
            ? DateTime.now().difference(lastMaintenance).inDays
            : null,
        'maxKm': maxKm,
      };

      Logger.log('✓ Estadísticas del vehículo calculadas');
      return stats;
    } catch (e) {
      Logger.log('✗ Error al calcular estadísticas: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMaintenanceStats(String userId) async {
    try {
      Logger.log('Calculando estadísticas de mantenimiento para: $userId');
      final maintenances = await getUserMaintenances(userId, limit: 500);

      double totalCost = 0;
      int totalCount = maintenances.length;
      DateTime? lastMaintenance;

      for (final m in maintenances) {
        totalCost += m.cost;
        if (lastMaintenance == null || m.date.isAfter(lastMaintenance)) {
          lastMaintenance = m.date;
        }
      }

      final stats = {
        'totalCount': totalCount,
        'totalCost': totalCost,
        'averageCost': totalCount > 0 ? totalCost / totalCount : 0.0,
        'lastMaintenanceDate': lastMaintenance,
        'monthsWithoutMaintenance': lastMaintenance != null
            ? DateTime.now().difference(lastMaintenance).inDays ~/ 30
            : null,
      };

      Logger.log('✓ Estadísticas calculadas');
      return stats;
    } catch (e) {
      Logger.log('✗ Error al calcular estadísticas: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      Logger.log('Calculando estadísticas del dashboard para: $userId');

      final vehicles = await getUserVehicles(userId);
      final maintenances = await getUserMaintenances(userId, limit: 500);

      double totalCost = 0;
      int totalVehicles = vehicles.length;
      int totalMaintenances = maintenances.length;
      DateTime? lastMaintenance;

      Map<String, int> maintenanceByType = {};
      Map<String, double> costByVehicle = {};

      for (final m in maintenances) {
        totalCost += m.cost;
        maintenanceByType[m.type.displayName] = (maintenanceByType[m.type.displayName] ?? 0) + 1;
        costByVehicle[m.vehicleId] = (costByVehicle[m.vehicleId] ?? 0) + m.cost;

        if (lastMaintenance == null || m.date.isAfter(lastMaintenance)) {
          lastMaintenance = m.date;
        }
      }

      String? mostExpensiveVehicleId;
      double maxCost = 0;
      costByVehicle.forEach((vehicleId, cost) {
        if (cost > maxCost) {
          maxCost = cost;
          mostExpensiveVehicleId = vehicleId;
        }
      });

      final stats = {
        'totalVehicles': totalVehicles,
        'totalMaintenances': totalMaintenances,
        'totalCost': totalCost,
        'averageCostPerMaintenance': totalMaintenances > 0 ? totalCost / totalMaintenances : 0.0,
        'lastMaintenanceDate': lastMaintenance,
        'daysLastMaintenance': lastMaintenance != null
            ? DateTime.now().difference(lastMaintenance).inDays
            : null,
        'maintenanceByType': maintenanceByType,
        'mostExpensiveVehicleId': mostExpensiveVehicleId,
        'mostExpensiveVehicleCost': maxCost,
      };

      Logger.log('✓ Estadísticas del dashboard calculadas');
      return stats;
    } catch (e) {
      Logger.error('✗ Error al calcular estadísticas del dashboard: $e', tag: _logTag);
      rethrow;
    }
  }

  // ============ HORARIOS DE MANTENIMIENTO ============

  Future<MaintenanceSchedule?> getMaintenanceSchedule(
    String userId,
    MaintenanceType type,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('maintenanceSchedules')
          .where('type', isEqualTo: type.toString().split('.').last)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        return null;
      }

      return MaintenanceSchedule.fromMap(doc.docs.first.data());
    } catch (e) {
      Logger.error('Error al obtener horario de mantenimiento: $e', tag: _logTag);
      return null;
    }
  }

  Future<void> setMaintenanceSchedule(String userId, MaintenanceSchedule schedule) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('maintenanceSchedules')
          .doc(schedule.id)
          .set(schedule.toMap());
      Logger.log('✓ Horario de mantenimiento guardado: ${schedule.type.displayName}');
    } catch (e) {
      Logger.error('Error al guardar horario de mantenimiento: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<List<MaintenanceSchedule>> getAllMaintenanceSchedules(String userId) async {
    try {
      final docs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('maintenanceSchedules')
          .get();

      return docs.docs.map((doc) => MaintenanceSchedule.fromMap(doc.data())).toList();
    } catch (e) {
      Logger.error('Error al obtener horarios de mantenimiento: $e', tag: _logTag);
      return [];
    }
  }

  // ============ ALERTAS ============

  Future<Map<String, dynamic>> getVehicleAlerts(String vehicleId, String userId) async {
    try {
      final vehicle = await getVehicle(vehicleId);
      if (vehicle == null) return {};

      final maintenances = await getVehicleMaintenances(vehicleId);
      final schedules = await getAllMaintenanceSchedules(userId);

      final alerts = <String, dynamic>{};

      for (final schedule in schedules) {
        final lastMaintenance =
            maintenances.where((m) => m.type == schedule.type).fold<Maintenance?>(
          null,
          (prev, current) => prev == null || current.date.isAfter(prev.date) ? current : prev,
        );

        if (lastMaintenance == null && (schedule.recommendedIntervalKm != null || schedule.recommendedIntervalDays != null)) {
          alerts[schedule.type.displayName] = {
            'status': AlertStatus.warning,
            'reason': 'Nunca ha sido realizado',
            'daysOverdue': null,
          };
        } else if (lastMaintenance != null) {
          final daysSinceLast = DateTime.now().difference(lastMaintenance.date).inDays;
          final kmSinceLast = vehicle.currentKm - lastMaintenance.km;

          bool isDaysOverdue = false;
          bool isKmOverdue = false;

          if (schedule.recommendedIntervalDays != null) {
            isDaysOverdue = daysSinceLast > schedule.recommendedIntervalDays!;
          }

          if (schedule.recommendedIntervalKm != null) {
            isKmOverdue = kmSinceLast > schedule.recommendedIntervalKm!;
          }

          if (isDaysOverdue || isKmOverdue) {
            alerts[schedule.type.displayName] = {
              'status': AlertStatus.overdue,
              'reason': isDaysOverdue ? '${daysSinceLast} días' : '${kmSinceLast} km',
              'daysOverdue': daysSinceLast,
            };
          } else {
            final remainingDays =
                schedule.recommendedIntervalDays != null ? schedule.recommendedIntervalDays! - daysSinceLast : null;
            final remainingKm =
                schedule.recommendedIntervalKm != null ? schedule.recommendedIntervalKm! - kmSinceLast : null;

            bool isWarning = false;
            String? reason;

            if (remainingDays != null && remainingDays <= 30) {
              isWarning = true;
              reason = 'En ${remainingDays} días';
            }
            if (remainingKm != null && remainingKm <= 1000) {
              isWarning = true;
              reason = reason != null ? '$reason / ${remainingKm} km' : 'En ${remainingKm} km';
            }

            if (isWarning) {
              alerts[schedule.type.displayName] = {
                'status': AlertStatus.warning,
                'reason': reason,
                'daysOverdue': null,
              };
            }
          }
        }
      }

      return alerts;
    } catch (e) {
      Logger.error('Error al calcular alertas del vehículo: $e', tag: _logTag);
      return {};
    }
  }

  // ============ FOTOS ============

  Future<String?> uploadVehiclePhoto(String userId, String vehicleId, File photoFile) async {
    try {
      Logger.log('Subiendo foto del vehículo: $vehicleId');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('vehicles/$userId/$vehicleId/$fileName');

      Logger.log('Iniciando upload a: vehicles/$userId/$vehicleId/$fileName');

      await ref.putFile(photoFile).timeout(const Duration(seconds: 10));

      final url = await ref.getDownloadURL();
      Logger.log('✓ Foto subida: $url');
      return url;
    } on TimeoutException {
      Logger.warning('Upload de foto cancelado por timeout');
      return null;
    } catch (e) {
      Logger.error('✗ Error al subir foto (continuando sin foto): $e', tag: _logTag);
      return null;
    }
  }

  // ============ CONDUCTORES ============

  Future<void> addDriver(Driver driver) async {
    try {
      Logger.log('Agregando conductor: ${driver.name}');
      await _firestore
          .collection('users')
          .doc(driver.userId)
          .collection('drivers')
          .doc(driver.id)
          .set(driver.toMap());
      Logger.log('✓ Conductor agregado: ${driver.name}');
    } catch (e) {
      Logger.error('Error al agregar conductor: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<Driver?> getDriver(String userId, String driverId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('drivers')
          .doc(driverId)
          .get();

      if (doc.exists) {
        return Driver.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger.error('Error al obtener conductor: $e', tag: _logTag);
      return null;
    }
  }

  Future<List<Driver>> getUserDrivers(String userId) async {
    try {
      final docs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('drivers')
          .orderBy('createdAt', descending: true)
          .get();

      final drivers = docs.docs.map((doc) => Driver.fromMap(doc.data())).toList();
      Logger.log('✓ ${drivers.length} conductores encontrados');
      return drivers;
    } catch (e) {
      Logger.error('Error al obtener conductores: $e', tag: _logTag);
      return [];
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      Logger.log('Actualizando conductor: ${driver.name}');
      await _firestore
          .collection('users')
          .doc(driver.userId)
          .collection('drivers')
          .doc(driver.id)
          .update(driver.toMap());
      Logger.log('✓ Conductor actualizado: ${driver.name}');
    } catch (e) {
      Logger.error('Error al actualizar conductor: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<void> deleteDriver(String userId, String driverId) async {
    try {
      Logger.log('Eliminando conductor: $driverId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('drivers')
          .doc(driverId)
          .delete();
      Logger.log('✓ Conductor eliminado: $driverId');
    } catch (e) {
      Logger.error('Error al eliminar conductor: $e', tag: _logTag);
      rethrow;
    }
  }

  // ============ FOTOS DE CONDUCTORES ============

  Future<String?> uploadDriverPhoto(String userId, File photoFile) async {
    try {
      Logger.log('Subiendo foto del conductor');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('drivers/$userId/profile/$fileName');

      await ref.putFile(photoFile).timeout(const Duration(seconds: 10));

      final url = await ref.getDownloadURL();
      Logger.log('✓ Foto del conductor subida: $url');
      return url;
    } on TimeoutException {
      Logger.warning('Upload de foto cancelado por timeout');
      return null;
    } catch (e) {
      Logger.error('✗ Error al subir foto del conductor: $e', tag: _logTag);
      return null;
    }
  }

  Future<String?> uploadLicensePhoto(String userId, File photoFile) async {
    try {
      Logger.log('Subiendo foto de licencia');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('drivers/$userId/license/$fileName');

      await ref.putFile(photoFile).timeout(const Duration(seconds: 10));

      final url = await ref.getDownloadURL();
      Logger.log('✓ Foto de licencia subida: $url');
      return url;
    } on TimeoutException {
      Logger.warning('Upload de foto cancelado por timeout');
      return null;
    } catch (e) {
      Logger.error('✗ Error al subir foto de licencia: $e', tag: _logTag);
      return null;
    }
  }

  // ============ NOTIFICACIONES ============

  Future<void> subscribeToMaintenanceAlerts(String vehicleId) async {
    try {
      // Suscribirse a tópico de alertas para este vehículo
      final notificationService = _getNotificationService();
      await notificationService.subscribeToTopic('maintenance_alerts_$vehicleId');
      Logger.info(
        'Suscrito a alertas de mantenimiento: $vehicleId',
        tag: _logTag,
      );
    } catch (e) {
      Logger.error('Error suscribiendo a alertas: $e', tag: _logTag);
    }
  }

  Future<void> unsubscribeFromMaintenanceAlerts(String vehicleId) async {
    try {
      final notificationService = _getNotificationService();
      await notificationService.unsubscribeFromTopic('maintenance_alerts_$vehicleId');
      Logger.info(
        'Desuscrito de alertas: $vehicleId',
        tag: _logTag,
      );
    } catch (e) {
      Logger.error('Error desuscribiendo de alertas: $e', tag: _logTag);
    }
  }

  Future<void> subscribeToUserAlerts(String userId) async {
    try {
      final notificationService = _getNotificationService();
      await notificationService.subscribeToTopic('user_alerts_$userId');
      Logger.info('Suscrito a alertas del usuario', tag: _logTag);
    } catch (e) {
      Logger.error('Error suscribiendo a alertas del usuario: $e', tag: _logTag);
    }
  }

  dynamic _getNotificationService() {
    // Retorna la instancia de NotificationService de forma lazy
    // Para evitar importación circular
    return NotificationServiceProxy();
  }

  // ============ UTILIDADES ============

  String generateId() => const Uuid().v4();

  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}

class NotificationServiceProxy {
  Future<void> subscribeToTopic(String topic) async {
    // Proxy para evitar importación circular
    try {
      // Usar reflexión o inyección de dependencias en producción
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // Proxy para evitar importación circular
    try {
      // Usar reflexión o inyección de dependencias en producción
    } catch (e) {
      // Silent fail
    }
  }
}
