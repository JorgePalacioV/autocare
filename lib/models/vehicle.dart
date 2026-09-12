import 'dart:math';

class Vehicle {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final String plate;
  final int year;
  final int currentKm;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? color;
  final String? vin;

  Vehicle({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.currentKm,
    required this.createdAt,
    this.updatedAt,
    this.color,
    this.vin,
  }) {
    _validateYear(year);
    _validateKm(currentKm);
    _validatePlate(plate);
  }

  static void _validateYear(int year) {
    final currentYear = DateTime.now().year;
    if (year < 1886 || year > currentYear + 1) {
      throw ArgumentError('Año inválido: $year');
    }
  }

  static void _validateKm(int km) {
    if (km < 0) {
      throw ArgumentError('Kilometraje no puede ser negativo');
    }
  }

  static void _validatePlate(String plate) {
    if (plate.trim().isEmpty) {
      throw ArgumentError('Placa no puede estar vacía');
    }
  }

  String get displayName => '$brand $model';
  int get age => DateTime.now().year - year;
  bool get isNewCar => age <= 2;
  bool get isHighMileage => currentKm > 200000;
  String get formattedKm => '$currentKm km';

  double get estimatedValue {
    final depreciationRate = 0.15;
    final baseValue = 15000.0;
    return baseValue * pow(1 - depreciationRate, age);
  }

  Vehicle updateKm(int newKm) {
    if (newKm < currentKm) {
      throw ArgumentError('Kilometraje no puede disminuir');
    }
    return Vehicle(
      id: id,
      userId: userId,
      brand: brand,
      model: model,
      plate: plate,
      year: year,
      currentKm: newKm,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      color: color,
      vin: vin,
    );
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    String? plate,
    int? year,
    int? currentKm,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    String? vin,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      year: year ?? this.year,
      currentKm: currentKm ?? this.currentKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
      color: color ?? this.color,
      vin: vin ?? this.vin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'plate': plate,
      'year': year,
      'currentKm': currentKm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'color': color,
      'vin': vin,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      plate: map['plate'] ?? '',
      year: map['year'] ?? 0,
      currentKm: map['currentKm'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      color: map['color'],
      vin: map['vin'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          plate == other.plate;

  @override
  int get hashCode => id.hashCode ^ plate.hashCode;
}
