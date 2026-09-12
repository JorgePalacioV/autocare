import 'maintenance.dart';

class MaintenanceSchedule {
  final String id;
  final String userId;
  final MaintenanceType type;
  final int? recommendedIntervalKm;
  final int? recommendedIntervalDays;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MaintenanceSchedule({
    required this.id,
    required this.userId,
    required this.type,
    this.recommendedIntervalKm,
    this.recommendedIntervalDays,
    required this.createdAt,
    this.updatedAt,
  });

  static const Map<MaintenanceType, int?> defaultIntervalKm = {
    MaintenanceType.oil: 5000,
    MaintenanceType.filter: 10000,
    MaintenanceType.inspection: 10000,
    MaintenanceType.tires: 40000,
    MaintenanceType.brakes: 50000,
    MaintenanceType.battery: 40000,
    MaintenanceType.transmission: null,
    MaintenanceType.suspension: null,
    MaintenanceType.electrical: null,
    MaintenanceType.bodywork: null,
    MaintenanceType.other: null,
  };

  static const Map<MaintenanceType, int?> defaultIntervalDays = {
    MaintenanceType.oil: 365,
    MaintenanceType.filter: 730,
    MaintenanceType.inspection: 180,
    MaintenanceType.tires: null,
    MaintenanceType.brakes: null,
    MaintenanceType.battery: 730,
    MaintenanceType.transmission: null,
    MaintenanceType.suspension: null,
    MaintenanceType.electrical: null,
    MaintenanceType.bodywork: null,
    MaintenanceType.other: null,
  };

  MaintenanceSchedule copyWith({
    String? id,
    String? userId,
    MaintenanceType? type,
    int? recommendedIntervalKm,
    int? recommendedIntervalDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      recommendedIntervalKm: recommendedIntervalKm ?? this.recommendedIntervalKm,
      recommendedIntervalDays: recommendedIntervalDays ?? this.recommendedIntervalDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'recommendedIntervalKm': recommendedIntervalKm,
      'recommendedIntervalDays': recommendedIntervalDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory MaintenanceSchedule.fromMap(Map<String, dynamic> map) {
    return MaintenanceSchedule(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: _parseMaintenanceType(map['type'] ?? 'other'),
      recommendedIntervalKm: map['recommendedIntervalKm'],
      recommendedIntervalDays: map['recommendedIntervalDays'],
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
      other is MaintenanceSchedule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ type.hashCode;
}

enum AlertStatus {
  ok,
  warning,
  overdue,
}

extension AlertStatusExt on AlertStatus {
  String get label {
    switch (this) {
      case AlertStatus.ok:
        return 'OK';
      case AlertStatus.warning:
        return 'Próximo';
      case AlertStatus.overdue:
        return 'Vencido';
    }
  }

  String get emoji {
    switch (this) {
      case AlertStatus.ok:
        return '✅';
      case AlertStatus.warning:
        return '⚠️';
      case AlertStatus.overdue:
        return '🔴';
    }
  }
}
