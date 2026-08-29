import '../domain/saved_search.dart';

abstract interface class SavedSearchRepository {
  List<SavedSearch> getAll();

  SavedSearch? getById(String id);

  void save(SavedSearch search);

  void delete(String id);
}

final class InMemorySavedSearchRepository implements SavedSearchRepository {
  final List<SavedSearch> _items = [];

  @override
  List<SavedSearch> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  SavedSearch? getById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  void save(SavedSearch search) {
    final index = _items.indexWhere((item) => item.id == search.id);

    if (index == -1) {
      _items.add(search);
      return;
    }

    _items[index] = search;
  }

  @override
  void delete(String id) {
    _items.removeWhere((item) => item.id == id);
  }
}
