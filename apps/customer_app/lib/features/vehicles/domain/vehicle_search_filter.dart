import 'vehicle.dart';

class VehicleSearchFilter {
  const VehicleSearchFilter({
    this.query,
    this.make,
    this.model,
    this.yearFrom,
    this.yearTo,
    this.condition,
    this.priceMin,
    this.priceMax,
    this.bodyType,
    this.transmission,
    this.fuelType,
    this.newArrivalsOnly = false,
  });

  final String? query;
  final String? make;
  final String? model;
  final int? yearFrom;
  final int? yearTo;
  final VehicleCondition? condition;
  final int? priceMin;
  final int? priceMax;
  final String? bodyType;
  final String? transmission;
  final String? fuelType;
  final bool newArrivalsOnly;

  bool get isEmpty {
    return (query == null || query!.trim().isEmpty) &&
        (make == null || make!.trim().isEmpty) &&
        (model == null || model!.trim().isEmpty) &&
        yearFrom == null &&
        yearTo == null &&
        condition == null &&
        priceMin == null &&
        priceMax == null &&
        (bodyType == null || bodyType!.trim().isEmpty) &&
        (transmission == null || transmission!.trim().isEmpty) &&
        (fuelType == null || fuelType!.trim().isEmpty) &&
        !newArrivalsOnly;
  }

  VehicleSearchFilter copyWith({
    String? query,
    String? make,
    String? model,
    int? yearFrom,
    int? yearTo,
    VehicleCondition? condition,
    int? priceMin,
    int? priceMax,
    String? bodyType,
    String? transmission,
    String? fuelType,
    bool? newArrivalsOnly,
    bool clearQuery = false,
    bool clearMake = false,
    bool clearModel = false,
    bool clearCondition = false,
    bool clearPrice = false,
    bool clearYear = false,
  }) {
    return VehicleSearchFilter(
      query: clearQuery ? null : query ?? this.query,
      make: clearMake ? null : make ?? this.make,
      model: clearModel ? null : model ?? this.model,
      yearFrom: clearYear ? null : yearFrom ?? this.yearFrom,
      yearTo: clearYear ? null : yearTo ?? this.yearTo,
      condition: clearCondition ? null : condition ?? this.condition,
      priceMin: clearPrice ? null : priceMin ?? this.priceMin,
      priceMax: clearPrice ? null : priceMax ?? this.priceMax,
      bodyType: bodyType ?? this.bodyType,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      newArrivalsOnly: newArrivalsOnly ?? this.newArrivalsOnly,
    );
  }
}
