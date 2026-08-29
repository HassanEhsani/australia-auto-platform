import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../saved_search/application/saved_search_service.dart';
import '../application/vehicle_search_service.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_search_filter.dart';

class VehicleSearchScreen extends StatefulWidget {
  const VehicleSearchScreen({super.key});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final VehicleSearchService _searchService = AppServices.vehicleSearchService;

  final SavedSearchService _savedSearchService = AppServices.savedSearchService;

  final _queryController = TextEditingController();
  final _yearFromController = TextEditingController();
  final _yearToController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  String? _make;
  String? _model;
  VehicleCondition? _condition;

  late List<Vehicle> _results;

  @override
  void initState() {
    super.initState();
    _results = _searchService.search(const VehicleSearchFilter());
  }

  @override
  void dispose() {
    _queryController.dispose();
    _yearFromController.dispose();
    _yearToController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  int? _toInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  VehicleSearchFilter _currentFilter() {
    return VehicleSearchFilter(
      query: _queryController.text,
      make: _make,
      model: _model,
      yearFrom: _toInt(_yearFromController.text),
      yearTo: _toInt(_yearToController.text),
      condition: _condition,
      priceMin: _toInt(_priceMinController.text),
      priceMax: _toInt(_priceMaxController.text),
    );
  }

  void _search() {
    setState(() {
      _results = _searchService.search(_currentFilter());
    });
  }

  Future<void> _saveSearch() async {
    final filter = _currentFilter();

    if (filter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one filter before saving.'),
        ),
      );
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String searchName = '';

        return AlertDialog(
          title: const Text('Save Search'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search name',
              hintText: 'e.g. BMW Damaged Cars',
            ),
            onChanged: (value) {
              searchName = value.trim();
            },
            onSubmitted: (_) {
              if (searchName.isNotEmpty) {
                Navigator.of(dialogContext).pop(searchName);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (searchName.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(searchName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    _savedSearchService.create(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      filter: filter,
      notificationsEnabled: true,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Search "$name" saved.')));
  }

  void _reset() {
    _queryController.clear();
    _yearFromController.clear();
    _yearToController.clear();
    _priceMinController.clear();
    _priceMaxController.clear();

    setState(() {
      _make = null;
      _model = null;
      _condition = null;
      _results = _searchService.search(const VehicleSearchFilter());
    });
  }

  @override
  Widget build(BuildContext context) {
    final models = switch (_make) {
      'Toyota' => ['RAV4', 'Land Cruiser'],
      'BMW' => ['320i'],
      'Audi' => ['SUV'],
      _ => <String>[],
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Vehicles',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [TextButton(onPressed: _reset, child: const Text('Reset'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          SearchBar(
            controller: _queryController,
            hintText: 'Search make, model or year...',
            leading: const Icon(Icons.search_rounded),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 22),

          const _SectionTitle(title: 'Make & Model'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DropdownField<String>(
                  label: 'Make',
                  value: _make,
                  items: const ['Toyota', 'BMW', 'Audi'],
                  onChanged: (value) {
                    setState(() {
                      _make = value;
                      _model = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownField<String>(
                  label: 'Model',
                  value: _model,
                  items: models,
                  onChanged: models.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _model = value;
                          });
                        },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Year'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: _yearFromController,
                  label: 'From',
                  hint: '2019',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: _yearToController,
                  label: 'To',
                  hint: '2026',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Condition'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ConditionChip(
                label: 'New',
                selected: _condition == VehicleCondition.newVehicle,
                onTap: () => setState(() {
                  _condition = _condition == VehicleCondition.newVehicle
                      ? null
                      : VehicleCondition.newVehicle;
                }),
              ),
              _ConditionChip(
                label: 'Used',
                selected: _condition == VehicleCondition.used,
                onTap: () => setState(() {
                  _condition = _condition == VehicleCondition.used
                      ? null
                      : VehicleCondition.used;
                }),
              ),
              _ConditionChip(
                label: 'Damaged',
                selected: _condition == VehicleCondition.damaged,
                onTap: () => setState(() {
                  _condition = _condition == VehicleCondition.damaged
                      ? null
                      : VehicleCondition.damaged;
                }),
              ),
              _ConditionChip(
                label: 'Salvage',
                selected: _condition == VehicleCondition.salvage,
                onTap: () => setState(() {
                  _condition = _condition == VehicleCondition.salvage
                      ? null
                      : VehicleCondition.salvage;
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Price'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: _priceMinController,
                  label: 'Minimum',
                  hint: '\$20,000',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: _priceMaxController,
                  label: 'Maximum',
                  hint: '\$90,000',
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          FilledButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Show Vehicles'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _saveSearch,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save Search'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              const Expanded(child: _SectionTitle(title: 'Results')),
              Text(
                '${_results.length} vehicles',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_results.isEmpty)
            const _EmptyResults()
          else
            ..._results.map(
              (vehicle) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ResultCard(vehicle: vehicle),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset(
            vehicle.images.first,
            width: 125,
            height: 110,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${vehicle.year} • ${vehicle.conditionLabel}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '\$${vehicle.price}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(item.toString())),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No vehicles found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try adjusting your search filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
