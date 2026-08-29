import '../domain/purchase_record.dart';

abstract interface class PurchaseRepository {
  List<PurchaseRecord> getByCustomerId(String customerId);

  PurchaseRecord? getById(String id);

  void add(PurchaseRecord purchase);
}

final class InMemoryPurchaseRepository implements PurchaseRepository {
  final List<PurchaseRecord> _purchases = [];

  @override
  List<PurchaseRecord> getByCustomerId(String customerId) {
    final results = _purchases
        .where((purchase) => purchase.customerId == customerId)
        .toList();

    results.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

    return List.unmodifiable(results);
  }

  @override
  PurchaseRecord? getById(String id) {
    for (final purchase in _purchases) {
      if (purchase.id == id) {
        return purchase;
      }
    }

    return null;
  }

  @override
  void add(PurchaseRecord purchase) {
    final index = _purchases.indexWhere((item) => item.id == purchase.id);

    if (index != -1) {
      _purchases[index] = purchase;
      return;
    }

    _purchases.add(purchase);
  }
}
