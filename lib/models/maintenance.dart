enum MaintenanceType {
  oil,
  filter,
  tires,
  brakes,
  battery,
  inspection,
  transmission,
  suspension,
  electrical,
  bodywork,
  other,
}

extension MaintenanceTypeExt on MaintenanceType {
  String get displayName {
    const names = {
      MaintenanceType.oil: 'Cambio de Aceite',
      MaintenanceType.filter: 'Filtro',
      MaintenanceType.tires: 'Llantas',
      MaintenanceType.brakes: 'Frenos',
      MaintenanceType.battery: 'Batería',
      MaintenanceType.inspection: 'Inspección',
      MaintenanceType.transmission: 'Transmisión',
      MaintenanceType.suspension: 'Suspensión',
      MaintenanceType.electrical: 'Eléctrica',
      MaintenanceType.bodywork: 'Chapa y Pintura',
      MaintenanceType.other: 'Otro',
    };
    return names[this] ?? 'Desconocido';
  }

  String get shortName {
    return displayName.split(' ').first;
  }

  bool get isRoutine => [MaintenanceType.oil, MaintenanceType.filter, MaintenanceType.inspection]
      .contains(this);
}

class Maintenance {
  final String id;
  final String vehicleId;
  final String userId;
  final MaintenanceType type;
  final DateTime date;
  final int km;
  final double cost;
  final String? workshop;
  final String? notes;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.type,
    required this.date,
    required this.km,
    required this.cost,
    this.workshop,
    this.notes,
    this.photoUrls,
    required this.createdAt,
    this.updatedAt,
  }) {
    _validateCost(cost);
    _validateKm(km);
    _validateDate(date);
  }

  static void _validateCost(double cost) {
    if (cost < 0) {
      throw ArgumentError('Costo no puede ser negativo');
    }
  }

  static void _validateKm(int km) {
    if (km < 0) {
      throw ArgumentError('Kilometraje no puede ser negativo');
    }
  }

  static void _validateDate(DateTime date) {
    if (date.isAfter(DateTime.now())) {
      throw ArgumentError('Fecha no puede ser en el futuro');
    }
  }

  bool get isRecent => DateTime.now().difference(date).inDays < 30;
  int get daysAgo => DateTime.now().difference(date).inDays;
  int get monthsAgo => (daysAgo / 30).floor();
  String get formattedCost => '\$${cost.toStringAsFixed(2)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  bool get hasPhotos => photoUrls != null && photoUrls!.isNotEmpty;
  bool get isRoutineService => type.isRoutine;

  Maintenance copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    MaintenanceType? type,
    DateTime? date,
    int? km,
    double? cost,
    String? workshop,
    String? notes,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Maintenance(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      km: km ?? this.km,
      cost: cost ?? this.cost,
      workshop: workshop ?? this.workshop,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'date': date.toIso8601String(),
      'km': km,
      'cost': cost,
      'workshop': workshop,
      'notes': notes,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      userId: map['userId'] ?? '',
      type: _parseMaintenanceType(map['type'] ?? 'other'),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      km: map['km'] ?? 0,
      cost: (map['cost'] ?? 0).toDouble(),
      workshop: map['workshop'],
      notes: map['notes'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  static MaintenanceType _parseMaintenanceType(String typeString) {
    try {
      return MaintenanceType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => MaintenanceType.other,
      );
    } catch (_) {
      return MaintenanceType.other;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Maintenance &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehicleId == other.vehicleId;

  @override
  int get hashCode => id.hashCode ^ vehicleId.hashCode;
}
