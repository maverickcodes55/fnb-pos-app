import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/reports_providers.dart';

class SalesKpiCards extends StatelessWidget {
  final ReportsSummary? summary;

  const SalesKpiCards({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final grossText = s != null ? CurrencyFormatter.format(s.totalGrossSales) : 'Rp 5.153.040';
    final completedCount = s != null ? '${s.completedOrdersCount}' : '64';
    final voidedCount = s != null ? '${s.voidedOrdersCount} Dibatalkan / Void' : '4 Dibatalkan / Void';
    final aovText = s != null ? CurrencyFormatter.format(s.averageOrderValue) : 'Rp 75.780';

    final totalPaid = (s?.qrisCount ?? 0) + (s?.cashCount ?? 0) + (s?.debitCount ?? 0);
    final int qrisFlex;
    final int cashFlex;
    final int debitFlex;
    final String qrisPct;
    final String cashPct;
    final String debitPct;

    if (totalPaid > 0 && s != null) {
      final q = (s.qrisCount * 100 / totalPaid).round();
      final c = (s.cashCount * 100 / totalPaid).round();
      final d = 100 - q - c;
      qrisFlex = s.qrisCount > 0 ? s.qrisCount : 1;
      cashFlex = s.cashCount > 0 ? s.cashCount : 1;
      debitFlex = s.debitCount > 0 ? s.debitCount : 1;
      qrisPct = '$q%';
      cashPct = '$c%';
      debitPct = '$d%';
    } else {
      qrisFlex = 55;
      cashFlex = 30;
      debitFlex = 15;
      qrisPct = '55%';
      cashPct = '30%';
      debitPct = '15%';
    }

    return Row(
      children: [
        // Card 1: Gross Sales
        Expanded(
          child: _buildKpiCard(
            title: 'TOTAL PENJUALAN KOTOR',
            icon: LucideIcons.trendingUp,
            iconColor: AppColors.primary,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            valueWidget: Text(
              grossText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            footerWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.arrowUpRight, size: 12, color: AppColors.secondary),
                      SizedBox(width: 2),
                      Text(
                        '+12.4%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'vs kemarin',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Card 2: Total Orders
        Expanded(
          child: _buildKpiCard(
            title: 'TOTAL PESANAN',
            icon: LucideIcons.receipt,
            iconColor: AppColors.secondary,
            iconBg: AppColors.secondaryContainer.withValues(alpha: 0.2),
            valueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  completedCount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            footerWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.xCircle, size: 12, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  voidedCount,
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Card 3: Average Order Value
        Expanded(
          child: _buildKpiCard(
            title: 'RATA-RATA NILAI PESANAN',
            icon: LucideIcons.barChart2,
            iconColor: AppColors.tertiary,
            iconBg: AppColors.tertiaryContainer.withValues(alpha: 0.15),
            valueWidget: Text(
              aovText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            footerWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.arrowUpRight, size: 12, color: AppColors.secondary),
                      SizedBox(width: 2),
                      Text(
                        '+4.8%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'vs shift lalu',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Card 4: Payment Distribution
        Expanded(
          child: _buildKpiCard(
            title: 'METODE PEMBAYARAN',
            icon: LucideIcons.pieChart,
            iconColor: AppColors.primaryContainer,
            iconBg: AppColors.surfaceContainerHigh,
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    children: [
                      Expanded(
                        flex: qrisFlex,
                        child: Container(height: 8, color: AppColors.primary),
                      ),
                      Expanded(
                        flex: cashFlex,
                        child: Container(height: 8, color: AppColors.secondary),
                      ),
                      Expanded(
                        flex: debitFlex,
                        child: Container(height: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
            footerWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                    const SizedBox(width: 3),
                    Text('QRIS $qrisPct', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: AppColors.secondary),
                    const SizedBox(width: 3),
                    Text('Tunai $cashPct', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: AppColors.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text('Kartu $debitPct', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget valueWidget,
    required Widget footerWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Center(child: Icon(icon, size: 14, color: iconColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          valueWidget,
          const SizedBox(height: 8),
          footerWidget,
        ],
      ),
    );
  }
}

