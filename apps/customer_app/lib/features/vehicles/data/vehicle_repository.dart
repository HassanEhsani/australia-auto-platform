import '../domain/vehicle.dart';

abstract interface class VehicleRepository {
  List<Vehicle> getAll();

  Vehicle? getById(String id);

  void add(Vehicle vehicle);
}

final class LocalVehicleRepository implements VehicleRepository {
  LocalVehicleRepository({List<Vehicle>? initialVehicles})
    : _vehicles = List<Vehicle>.from(initialVehicles ?? _defaultVehicles);

  static final List<Vehicle> _defaultVehicles = [
    Vehicle(
      id: 'toyota-rav4-2021',
      make: 'Toyota',
      model: 'RAV4',
      year: 2021,
      condition: VehicleCondition.used,
      price: 24900,
      odometerKm: 48000,
      bodyType: 'SUV',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      location: 'King Auto - Rocklea, QLD 4106',
      images: ['assets/images/vehicles/toyota_rav4.jpg'],
      isNewArrival: false,
      publishedAt: DateTime(2026, 8, 20, 9, 0),
    ),
    Vehicle(
      id: 'bmw-320i-2019',
      make: 'BMW',
      model: '320i',
      year: 2019,
      condition: VehicleCondition.damaged,
      price: 22500,
      odometerKm: 72000,
      bodyType: 'Sedan',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      location: 'King Auto - Rocklea, QLD 4106',
      images: ['assets/images/vehicles/damaged_bmw.jpg'],
      isNewArrival: false,
      publishedAt: DateTime(2026, 8, 18, 14, 30),
    ),
    Vehicle(
      id: 'toyota-land-cruiser-2025',
      make: 'Toyota',
      model: 'Land Cruiser',
      year: 2025,
      condition: VehicleCondition.newVehicle,
      price: 89900,
      odometerKm: 20,
      bodyType: 'SUV',
      transmission: 'Automatic',
      fuelType: 'Diesel',
      location: 'King Auto - Rocklea, QLD 4106',
      images: ['assets/images/new_arrivals/new_land_cruiser.jpg'],
      isNewArrival: true,
      publishedAt: DateTime(2026, 8, 26, 16, 0),
    ),
    Vehicle(
      id: 'audi-suv-2025',
      make: 'Audi',
      model: 'SUV',
      year: 2025,
      condition: VehicleCondition.newVehicle,
      price: 74900,
      odometerKm: 15,
      bodyType: 'SUV',
      transmission: 'Automatic',
      fuelType: 'Petrol',
      location: 'King Auto - Rocklea, QLD 4106',
      images: ['assets/images/new_arrivals/new_audi_suv.jpg'],
      isNewArrival: true,
      publishedAt: DateTime(2026, 8, 26, 17, 30),
    ),
  ];

  final List<Vehicle> _vehicles;

  @override
  List<Vehicle> getAll() {
    return List.unmodifiable(_vehicles);
  }

  @override
  Vehicle? getById(String id) {
    for (final vehicle in _vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }

    return null;
  }

  @override
  void add(Vehicle vehicle) {
    final existingIndex = _vehicles.indexWhere((item) => item.id == vehicle.id);

    if (existingIndex != -1) {
      _vehicles[existingIndex] = vehicle;
      return;
    }

    _vehicles.add(vehicle);
  }
}
