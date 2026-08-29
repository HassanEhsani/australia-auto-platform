import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/purchases/application/purchase_history_service.dart';
import 'package:customer_app/features/purchases/data/purchase_repository.dart';
import 'package:customer_app/features/purchases/domain/purchase_record.dart';
import 'package:customer_app/features/vehicles/domain/vehicle.dart';

void main() {
  late InMemoryPurchaseRepository repository;
  late PurchaseHistoryService service;

  setUp(() {
    repository = InMemoryPurchaseRepository();
    service = PurchaseHistoryService(repository);

    repository.add(
      PurchaseRecord(
        id: 'purchase-1',
        customerId: 'customer-1',
        vehicleId: 'toyota-rav4-2021',
        make: 'Toyota',
        model: 'RAV4',
        year: 2021,
        condition: VehicleCondition.used,
        image: 'assets/images/vehicles/toyota_rav4.jpg',
        finalPrice: 24900,
        purchasedAt: DateTime(2026, 7, 10, 14, 30),
        branchName: 'King Auto - Rocklea',
        salespersonName: 'Sales Manager',
        saleReference: 'SALE-1001',
        status: PurchaseStatus.completed,
      ),
    );

    repository.add(
      PurchaseRecord(
        id: 'purchase-2',
        customerId: 'customer-1',
        vehicleId: 'bmw-320i-2019',
        make: 'BMW',
        model: '320i',
        year: 2019,
        condition: VehicleCondition.damaged,
        image: 'assets/images/vehicles/damaged_bmw.jpg',
        finalPrice: 22500,
        purchasedAt: DateTime(2026, 8, 12, 11, 15),
        branchName: 'King Auto - Rocklea',
        salespersonName: 'Sales Manager',
        saleReference: 'SALE-1002',
        status: PurchaseStatus.completed,
      ),
    );

    repository.add(
      PurchaseRecord(
        id: 'purchase-3',
        customerId: 'customer-1',
        vehicleId: 'cancelled-car',
        make: 'Audi',
        model: 'SUV',
        year: 2025,
        condition: VehicleCondition.newVehicle,
        image: 'assets/images/new_arrivals/new_audi_suv.jpg',
        finalPrice: 74900,
        purchasedAt: DateTime(2026, 8, 20, 16, 0),
        branchName: 'King Auto - Rocklea',
        salespersonName: 'Sales Manager',
        saleReference: 'SALE-1003',
        status: PurchaseStatus.cancelled,
      ),
    );

    repository.add(
      PurchaseRecord(
        id: 'purchase-other-customer',
        customerId: 'customer-2',
        vehicleId: 'other-car',
        make: 'Toyota',
        model: 'Land Cruiser',
        year: 2025,
        condition: VehicleCondition.newVehicle,
        image: 'assets/images/new_arrivals/new_land_cruiser.jpg',
        finalPrice: 89900,
        purchasedAt: DateTime(2026, 8, 25, 10, 0),
        branchName: 'King Auto - Rocklea',
        salespersonName: 'Sales Manager',
        saleReference: 'SALE-2001',
        status: PurchaseStatus.completed,
      ),
    );
  });

  group('PurchaseHistoryService', () {
    test('returns only completed purchases for the customer', () {
      final history = service.getHistory('customer-1');

      expect(history, hasLength(2));

      final ids = history.map((purchase) => purchase.id).toSet();

      expect(ids, containsAll(['purchase-1', 'purchase-2']));

      expect(ids, isNot(contains('purchase-3')));
      expect(ids, isNot(contains('purchase-other-customer')));
    });

    test('history is sorted newest purchase first', () {
      final history = service.getHistory('customer-1');

      expect(history.first.id, 'purchase-2');
      expect(history.last.id, 'purchase-1');
    });

    test('summary calculates total purchased', () {
      final summary = service.getSummary('customer-1');

      expect(summary.totalPurchased, 2);
    });

    test('summary calculates total spent', () {
      final summary = service.getSummary('customer-1');

      expect(summary.totalSpent, 47400);
    });

    test('summary returns latest purchase date', () {
      final summary = service.getSummary('customer-1');

      expect(summary.lastPurchaseAt, DateTime(2026, 8, 12, 11, 15));
    });

    test('empty customer history returns zero summary', () {
      final summary = service.getSummary('customer-with-no-purchases');

      expect(summary.totalPurchased, 0);
      expect(summary.totalSpent, 0);
      expect(summary.lastPurchaseAt, isNull);
    });
  });
}
