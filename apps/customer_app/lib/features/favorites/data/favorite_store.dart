import 'package:flutter/foundation.dart';

abstract final class FavoriteStore {
  static final ValueNotifier<bool> toyotaRav4 = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> bmw320i = ValueNotifier<bool>(false);

  static void toggleToyotaRav4() {
    toyotaRav4.value = !toyotaRav4.value;
  }

  static void toggleBmw320i() {
    bmw320i.value = !bmw320i.value;
  }
}
