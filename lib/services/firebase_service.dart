import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const String _logTag = '[FirebaseService]';

  // ============ EMULADORES ============

  Future<void> connectToEmulators() async {
    try {
      Logger.info('Conectando a emuladores locales...', tag: _logTag);

      await _auth.useAuthEmulator('localhost', 9099);
      Logger.success('✓ Auth Emulator conectado (localhost:9099)', tag: _logTag);

      _firestore.useFirestoreEmulator('localhost', 8080);
      Logger.success('✓ Firestore Emulator conectado (localhost:8080)', tag: _logTag);
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
