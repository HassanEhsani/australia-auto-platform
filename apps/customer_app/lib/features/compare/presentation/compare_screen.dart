import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/presentation/vehicle_details_screen.dart';
import '../application/compare_store.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: CompareStore.vehicleIds,
      builder: (context, vehicleIds, _) {
        final vehicles = vehicleIds
            .map(AppServices.vehicleRepository.getById)
            .whereType<Vehicle>()
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Compare Vehicles (${vehicles.length})',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              if (vehicles.isNotEmpty)
                TextButton(
                  onPressed: CompareStore.clear,
                  child: const Text('Clear'),
                ),
            ],
          ),
          body: vehicles.isEmpty
              ? const _EmptyCompare()
              : Column(
                  children: [
                    if (vehicles.length < 2)
                      const _CompareHint(
                        message: 'Add one more vehicle to start comparing.',
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        scrollDirection: Axis.horizontal,
                        itemCount: vehicles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return _CompareVehicleCard(vehicle: vehicles[index]);
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CompareVehicleCard extends StatelessWidget {
  const _CompareVehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: vehicle.images.isEmpty
                          ? const _VehicleImageFallback()
                          : Image.asset(
                              vehicle.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const _VehicleImageFallback();
                              },
                            ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Remove from compare',
                          onPressed: () {
                            CompareStore.toggle(vehicle.id);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatPrice(vehicle.price),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _CompareRow(label: 'Year', value: '${vehicle.year}'),
                      _CompareRow(
                        label: 'Odometer',
                        value: '${_formatNumber(vehicle.odometerKm)} km',
                      ),
                      _CompareRow(
                        label: 'Condition',
                        value: vehicle.conditionLabel,
                      ),
                      _CompareRow(label: 'Body Type', value: vehicle.bodyType),
                      _CompareRow(
                        label: 'Transmission',
                        value: vehicle.transmission,
                      ),
                      _CompareRow(label: 'Fuel Type', value: vehicle.fuelType),
                      _CompareRow(
                        label: 'Engine Health',
                        value: '${vehicle.engineHealthPercent}%',
                        valueColor: vehicle.engineHealthPercent >= 80
                            ? AppColors.primary
                            : AppColors.error,
                      ),
                      _CompareRow(
                        label: 'Oil Status',
                        value: vehicle.oilWarningLabel,
                        valueColor:
                            vehicle.oilWarningStatus ==
                                VehicleOilWarningStatus.on
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  VehicleDetailsScreen(vehicle: vehicle),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareHint extends StatelessWidget {
  const _CompareHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyCompare extends StatelessWidget {
  const _EmptyCompare();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              size: 58,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No vehicles selected',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add up to 3 vehicles to compare them side by side.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImageFallback extends StatelessWidget {
  const _VehicleImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.directions_car_outlined,
          size: 52,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

String _formatPrice(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < text.length; index++) {
    final positionFromEnd = text.length - index;

    buffer.write(text[index]);

    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  return '\$$buffer';
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < text.length; index++) {
    final positionFromEnd = text.length - index;

    buffer.write(text[index]);

    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}
