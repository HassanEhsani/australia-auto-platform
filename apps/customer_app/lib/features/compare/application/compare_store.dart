import 'package:flutter/foundation.dart';

enum CompareToggleResult { added, removed, limitReached }

abstract final class CompareStore {
  static const int maxVehicles = 3;

  static final ValueNotifier<List<String>> vehicleIds =
      ValueNotifier<List<String>>(<String>[]);

  static bool contains(String vehicleId) {
    return vehicleIds.value.contains(vehicleId);
  }

  static bool get isFull {
    return vehicleIds.value.length >= maxVehicles;
  }

  static CompareToggleResult toggle(String vehicleId) {
    final updated = List<String>.from(vehicleIds.value);

    if (updated.contains(vehicleId)) {
      updated.remove(vehicleId);
      vehicleIds.value = updated;
      return CompareToggleResult.removed;
    }

    if (updated.length >= maxVehicles) {
      return CompareToggleResult.limitReached;
    }

    updated.add(vehicleId);
    vehicleIds.value = updated;

    return CompareToggleResult.added;
  }

  static void clear() {
    vehicleIds.value = <String>[];
  }
}
