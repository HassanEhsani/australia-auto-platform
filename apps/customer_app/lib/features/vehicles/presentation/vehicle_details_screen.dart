import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../compare/application/compare_store.dart';
import '../../compare/presentation/compare_screen.dart';
import '../../favorites/data/favorite_store.dart';
import '../domain/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key, this.vehicle, this.isBmw = false});

  final Vehicle? vehicle;

  // Temporary backwards compatibility with the current Home UI.
  final bool isBmw;

  Vehicle get _resolvedVehicle {
    if (vehicle != null) {
      return vehicle!;
    }

    final vehicleId = isBmw
        ? FavoriteStore.bmw320iId
        : FavoriteStore.toyotaRav4Id;

    final result = AppServices.vehicleRepository.getById(vehicleId);

    if (result == null) {
      throw StateError('Vehicle not found: $vehicleId');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentVehicle = _resolvedVehicle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            actions: [
              ValueListenableBuilder<List<String>>(
                valueListenable: CompareStore.vehicleIds,
                builder: (context, compareIds, _) {
                  final isCompared = compareIds.contains(currentVehicle.id);

                  return IconButton(
                    tooltip: isCompared
                        ? 'Remove from compare'
                        : 'Add to compare',
                    onPressed: () {
                      final result = CompareStore.toggle(currentVehicle.id);

                      if (result == CompareToggleResult.limitReached) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You can compare up to 3 vehicles.'),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.compare_arrows_rounded,
                      color: isCompared
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  );
                },
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: CompareStore.vehicleIds,
                builder: (context, compareIds, _) {
                  if (compareIds.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Open compare',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CompareScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.compare_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Positioned(
                        right: 3,
                        top: 3,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: AppColors.accent,
                          child: Text(
                            '${compareIds.length}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteStore.favoriteVehicleIds,
                builder: (context, favoriteIds, _) {
                  final isFavorite = favoriteIds.contains(currentVehicle.id);

                  return IconButton(
                    onPressed: () {
                      FavoriteStore.toggle(currentVehicle.id);
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: currentVehicle.images.isEmpty
                  ? const _VehicleImageFallback()
                  : Image.asset(
                      currentVehicle.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const _VehicleImageFallback();
                      },
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentVehicle.displayName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _ConditionBadge(condition: currentVehicle.conditionLabel),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${currentVehicle.year} • '
                    '${currentVehicle.bodyType} • '
                    '${currentVehicle.transmission}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    _formatPrice(currentVehicle.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 26),

                  _StatsGrid(vehicle: currentVehicle),

                  const SizedBox(height: 32),

                  const _SectionTitle(title: 'Vehicle Health'),

                  const SizedBox(height: 12),

                  _VehicleHealthCard(vehicle: currentVehicle),

                  const SizedBox(height: 32),

                  const _SectionTitle(title: 'Vehicle Overview'),

                  const SizedBox(height: 12),

                  Text(
                    '${currentVehicle.displayName} is currently available '
                    'through King Auto. Review the vehicle information and '
                    'inspection indicators below, then contact our sales team '
                    'or reserve the vehicle to discuss the next steps.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const _SectionTitle(title: 'Vehicle Information'),

                  const SizedBox(height: 14),

                  _InformationCard(vehicle: currentVehicle),

                  const SizedBox(height: 30),

                  const _SectionTitle(title: 'Location'),

                  const SizedBox(height: 12),

                  _LocationCard(location: currentVehicle.location),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: const _BottomActionBar(),
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        condition.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.speed_rounded,
            value: '${_formatNumber(vehicle.odometerKm)} km',
            label: 'Odometer',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.settings_outlined,
            value: vehicle.transmission,
            label: 'Transmission',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.local_gas_station_outlined,
            value: vehicle.fuelType,
            label: 'Fuel',
          ),
        ),
      ],
    );
  }
}

class _VehicleHealthCard extends StatelessWidget {
  const _VehicleHealthCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final oilWarningOn = vehicle.oilWarningStatus == VehicleOilWarningStatus.on;

    final oilNotChecked =
        vehicle.oilWarningStatus == VehicleOilWarningStatus.notChecked;

    final oilColor = oilWarningOn
        ? AppColors.error
        : oilNotChecked
        ? AppColors.textSecondary
        : AppColors.primary;

    final oilIcon = oilWarningOn
        ? Icons.warning_amber_rounded
        : oilNotChecked
        ? Icons.help_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Engine Health',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${vehicle.engineHealthPercent}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: vehicle.engineHealthPercent / 100,
              backgroundColor: AppColors.border,
              color: vehicle.engineHealthPercent >= 80
                  ? AppColors.primary
                  : AppColors.error,
            ),
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 18),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(oilIcon, color: oilColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oil Warning Light',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Inspection indicator',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                vehicle.oilWarningLabel,
                style: TextStyle(color: oilColor, fontWeight: FontWeight.w900),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Vehicle health values are based on recorded inspection data.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
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
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Make', value: vehicle.make),
          const Divider(),
          _InfoRow(label: 'Model', value: vehicle.model),
          const Divider(),
          _InfoRow(label: 'Year', value: vehicle.year.toString()),
          const Divider(),
          _InfoRow(label: 'Body type', value: vehicle.bodyType),
          const Divider(),
          _InfoRow(label: 'Condition', value: vehicle.conditionLabel),
          const Divider(),
          const _InfoRow(label: 'Stock', value: 'Available'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.location_on_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'King Auto',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleImageFallback extends StatelessWidget {
  const _VehicleImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.border,
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call_outlined),
                label: const Text('Contact Sales'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text(
                  'Reserve Vehicle',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int value) {
  return '\$${_formatNumber(value)}';
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}
