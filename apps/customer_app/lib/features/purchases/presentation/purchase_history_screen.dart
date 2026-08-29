import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/mock_purchase_data.dart';
import '../data/purchase_repository.dart';
import '../application/purchase_history_service.dart';
import '../domain/purchase_record.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = InMemoryPurchaseRepository();

    for (final purchase in MockPurchaseData.purchases) {
      repository.add(purchase);
    }

    final service = PurchaseHistoryService(repository);
    final history = service.getHistory('customer-1');
    final summary = service.getSummary('customer-1');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Purchase History',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SummaryCard(
            totalPurchased: summary.totalPurchased,
            totalSpent: summary.totalSpent,
            lastPurchaseAt: summary.lastPurchaseAt,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Purchases',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const _EmptyHistory()
          else
            ...history.map(
              (purchase) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PurchaseCard(purchase: purchase),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalPurchased,
    required this.totalSpent,
    required this.lastPurchaseAt,
  });

  final int totalPurchased;
  final int totalSpent;
  final DateTime? lastPurchaseAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Purchased',
                  value: '$totalPurchased',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Total Spent',
                  value: '\$$totalSpent',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              lastPurchaseAt == null
                  ? 'No purchases yet'
                  : 'Last purchase: ${_formatDateTime(lastPurchaseAt!)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final date =
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';

    final time =
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';

    return '$date • $time';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase});

  final PurchaseRecord purchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            purchase.image,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${purchase.year} • ${_conditionLabel(purchase.condition)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Final price',
                  value: '\$${purchase.finalPrice}',
                ),
                _InfoRow(
                  label: 'Purchased',
                  value: _formatDateTime(purchase.purchasedAt),
                ),
                _InfoRow(label: 'Branch', value: purchase.branchName),
                _InfoRow(label: 'Salesperson', value: purchase.salespersonName),
                _InfoRow(
                  label: 'Sale reference',
                  value: purchase.saleReference,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _conditionLabel(dynamic condition) {
    final value = condition.toString();

    if (value.contains('damaged')) return 'Damaged';
    if (value.contains('salvage')) return 'Salvage';
    if (value.contains('newVehicle')) return 'New';

    return 'Used';
  }

  static String _formatDateTime(DateTime value) {
    final date =
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';

    final time =
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';

    return '$date • $time';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'No purchases yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
