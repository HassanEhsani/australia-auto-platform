import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../favorites/data/favorite_store.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../saved_search/presentation/saved_searches_screen.dart';
import '../../purchases/presentation/purchase_history_screen.dart';
import '../../purchases/application/purchase_history_service.dart';
import '../../purchases/data/mock_purchase_data.dart';
import '../../purchases/data/purchase_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseRepository = InMemoryPurchaseRepository();

    for (final purchase in MockPurchaseData.purchases) {
      purchaseRepository.add(purchase);
    }

    final purchaseHistoryService = PurchaseHistoryService(purchaseRepository);

    final purchaseSummary = purchaseHistoryService.getSummary('customer-1');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _ProfileHeader(onEdit: () => _comingSoon(context, 'Edit Profile')),
          const SizedBox(height: 22),

          const _SectionTitle(title: 'My Activity'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteStore.favoriteVehicleIds,
                  builder: (context, favoriteIds, _) {
                    return _ActivityCard(
                      icon: Icons.favorite_rounded,
                      value: '${favoriteIds.length}',
                      label: 'Favorites',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActivityCard(
                  icon: Icons.calendar_month_rounded,
                  value: '0',
                  label: 'Reservations',
                  onTap: () => _comingSoon(context, 'Reservations'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActivityCard(
                  icon: Icons.directions_car_rounded,
                  value: '${purchaseSummary.totalPurchased}',
                  label: 'Purchased',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PurchaseHistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const _SectionTitle(title: 'Account'),
          const SizedBox(height: 12),

          _ProfileMenuCard(
            children: [
              _ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle: 'Name, email and mobile',
                onTap: () => _comingSoon(context, 'Personal Information'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'My Favorites',
                subtitle: 'Vehicles you have saved',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.bookmark_border_rounded,
                title: 'Saved Searches',
                subtitle: 'Saved vehicle searches and alerts',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SavedSearchesScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.calendar_month_outlined,
                title: 'My Reservations',
                subtitle: 'View your reservation requests',
                onTap: () => _comingSoon(context, 'Reservations'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Purchase History',
                subtitle: 'Vehicles purchased through King Auto',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PurchaseHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionTitle(title: 'Preferences'),
          const SizedBox(height: 12),

          _ProfileMenuCard(
            children: [
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Manage alerts and updates',
                onTap: () => _comingSoon(context, 'Notifications'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App and account preferences',
                onTap: () => _comingSoon(context, 'Settings'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Contact King Auto support',
                onTap: () => _comingSoon(context, 'Help & Support'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _comingSoon(context, 'Logout'),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Material(
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onEdit,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Hassan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'hassan@example.com',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            '+61 4XX XXX XXX',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
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
