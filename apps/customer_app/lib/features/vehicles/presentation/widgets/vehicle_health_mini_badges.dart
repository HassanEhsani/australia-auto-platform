import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/vehicle.dart';

class VehicleHealthMiniBadges extends StatelessWidget {
  VehicleHealthMiniBadges({super.key, required Vehicle vehicle})
    : engineHealthPercent = vehicle.engineHealthPercent,
      oilWarningStatus = vehicle.oilWarningStatus;

  const VehicleHealthMiniBadges.snapshot({
    super.key,
    required this.engineHealthPercent,
    required this.oilWarningStatus,
  });

  final int engineHealthPercent;
  final VehicleOilWarningStatus oilWarningStatus;

  @override
  Widget build(BuildContext context) {
    final oilColor = switch (oilWarningStatus) {
      VehicleOilWarningStatus.off => AppColors.primary,
      VehicleOilWarningStatus.on => AppColors.error,
      VehicleOilWarningStatus.notChecked => AppColors.textSecondary,
    };

    final oilLabel = switch (oilWarningStatus) {
      VehicleOilWarningStatus.off => 'Oil OK',
      VehicleOilWarningStatus.on => 'Oil Warning',
      VehicleOilWarningStatus.notChecked => 'Oil N/A',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _MiniHealthBadge(
          icon: Icons.settings_suggest_rounded,
          label: 'Engine $engineHealthPercent%',
          foregroundColor: engineHealthPercent >= 80
              ? AppColors.primary
              : AppColors.error,
        ),
        _MiniHealthBadge(
          icon: Icons.oil_barrel_rounded,
          label: oilLabel,
          foregroundColor: oilColor,
        ),
      ],
    );
  }
}

class _MiniHealthBadge extends StatelessWidget {
  const _MiniHealthBadge({
    required this.icon,
    required this.label,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
