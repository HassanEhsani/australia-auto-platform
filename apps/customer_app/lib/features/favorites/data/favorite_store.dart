import 'package:flutter/foundation.dart';

abstract final class FavoriteStore {
  static const String toyotaRav4Id = 'toyota-rav4-2021';
  static const String bmw320iId = 'bmw-320i-2019';

  static final ValueNotifier<Set<String>> favoriteVehicleIds =
      ValueNotifier<Set<String>>(<String>{});

  // Temporary compatibility with the existing Home / Details UI.
  static final ValueNotifier<bool> toyotaRav4 = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> bmw320i = ValueNotifier<bool>(false);

  static bool isFavorite(String vehicleId) {
    return favoriteVehicleIds.value.contains(vehicleId);
  }

  static void toggle(String vehicleId) {
    final updated = Set<String>.from(favoriteVehicleIds.value);

    if (updated.contains(vehicleId)) {
      updated.remove(vehicleId);
    } else {
      updated.add(vehicleId);
    }

    favoriteVehicleIds.value = updated;

    if (vehicleId == toyotaRav4Id) {
      toyotaRav4.value = updated.contains(toyotaRav4Id);
    }

    if (vehicleId == bmw320iId) {
      bmw320i.value = updated.contains(bmw320iId);
    }
  }

  static void toggleToyotaRav4() {
    toggle(toyotaRav4Id);
  }

  static void toggleBmw320i() {
    toggle(bmw320iId);
  }
}
