enum VehicleCondition { newVehicle, used, damaged, salvage }

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
  });

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
}
