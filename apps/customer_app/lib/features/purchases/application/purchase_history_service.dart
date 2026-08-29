import '../data/purchase_repository.dart';
import '../domain/purchase_record.dart';

class PurchaseHistorySummary {
  const PurchaseHistorySummary({
    required this.totalPurchased,
    required this.totalSpent,
    required this.lastPurchaseAt,
  });

  final int totalPurchased;
  final int totalSpent;
  final DateTime? lastPurchaseAt;
}

final class PurchaseHistoryService {
  const PurchaseHistoryService(this._repository);

  final PurchaseRepository _repository;

  List<PurchaseRecord> getHistory(String customerId) {
    return _repository
        .getByCustomerId(customerId)
        .where((purchase) => purchase.isCompleted)
        .toList();
  }

  PurchaseHistorySummary getSummary(String customerId) {
    final purchases = getHistory(customerId);

    final totalSpent = purchases.fold<int>(
      0,
      (total, purchase) => total + purchase.finalPrice,
    );

    return PurchaseHistorySummary(
      totalPurchased: purchases.length,
      totalSpent: totalSpent,
      lastPurchaseAt: purchases.isEmpty ? null : purchases.first.purchasedAt,
    );
  }
}
