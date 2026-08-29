import '../../vehicles/domain/vehicle.dart';

enum PurchaseStatus { completed, cancelled, refunded }

class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.year,
    required this.condition,
    required this.image,
    required this.finalPrice,
    required this.purchasedAt,
    required this.branchName,
    required this.salespersonName,
    required this.saleReference,
    required this.status,
    this.engineHealthPercentAtPurchase = 100,
    this.oilWarningStatusAtPurchase = VehicleOilWarningStatus.notChecked,
  }) : assert(
         engineHealthPercentAtPurchase >= 0 &&
             engineHealthPercentAtPurchase <= 100,
       );

  final String id;
  final String customerId;
  final String vehicleId;

  final String make;
  final String model;
  final int year;
  final VehicleCondition condition;
  final String image;

  final int finalPrice;
  final DateTime purchasedAt;

  final String branchName;
  final String salespersonName;
  final String saleReference;

  final PurchaseStatus status;

  final int engineHealthPercentAtPurchase;
  final VehicleOilWarningStatus oilWarningStatusAtPurchase;

  String get displayName => '$make $model';

  bool get isCompleted => status == PurchaseStatus.completed;
}
