import '../../vehicles/domain/vehicle.dart';
import '../domain/purchase_record.dart';

abstract final class MockPurchaseData {
  static final purchases = [
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
      engineHealthPercentAtPurchase: 92,
      oilWarningStatusAtPurchase: VehicleOilWarningStatus.off,
      status: PurchaseStatus.completed,
    ),
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
      engineHealthPercentAtPurchase: 64,
      oilWarningStatusAtPurchase: VehicleOilWarningStatus.on,
      status: PurchaseStatus.completed,
    ),
  ];
}
