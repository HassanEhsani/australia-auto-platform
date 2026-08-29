enum VehicleCondition { newVehicle, used, damaged, salvage }

enum VehicleOilWarningStatus { off, on, notChecked }

class Vehicle {
  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.condition,
    required this.price,
    required this.odometerKm,
    required this.bodyType,
    required this.transmission,
    required this.fuelType,
    required this.location,
    required this.images,
    required this.isNewArrival,
    required this.publishedAt,
    this.engineHealthPercent = 100,
    this.oilWarningStatus = VehicleOilWarningStatus.notChecked,
  }) : assert(
         engineHealthPercent >= 0 && engineHealthPercent <= 100,
         'Engine health must be between 0 and 100.',
       );

  final String id;
  final String make;
  final String model;
  final int year;
  final VehicleCondition condition;
  final int price;
  final int odometerKm;
  final String bodyType;
  final String transmission;
  final String fuelType;
  final String location;
  final List<String> images;
  final bool isNewArrival;
  final DateTime publishedAt;

  final int engineHealthPercent;
  final VehicleOilWarningStatus oilWarningStatus;

  String get displayName => '$make $model';

  String get conditionLabel {
    switch (condition) {
      case VehicleCondition.newVehicle:
        return 'New';
      case VehicleCondition.used:
        return 'Used';
      case VehicleCondition.damaged:
        return 'Damaged';
      case VehicleCondition.salvage:
        return 'Salvage';
    }
  }

  String get oilWarningLabel {
    switch (oilWarningStatus) {
      case VehicleOilWarningStatus.off:
        return 'OFF';
      case VehicleOilWarningStatus.on:
        return 'ON';
      case VehicleOilWarningStatus.notChecked:
        return 'NOT CHECKED';
    }
  }
}
