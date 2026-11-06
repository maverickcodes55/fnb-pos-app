import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';

class SalesKpiCards extends StatelessWidget {
  const SalesKpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card 1: Gross Sales
        Expanded(
          child: _buildKpiCard(
            title: 'TOTAL PENJUALAN KOTOR',
            icon: LucideIcons.trendingUp,
            iconColor: AppColors.primary,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            valueWidget: const Text(
              'Rp 5.153.040',
              style: TextStyle(
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
            valueWidget: const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '64',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            footerWidget: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.xCircle, size: 12, color: AppColors.error),
                SizedBox(width: 4),
                Text(
                  '4 Dibatalkan / Void',
                  style: TextStyle(fontSize: 11, color: AppColors.error),
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
            valueWidget: const Text(
              'Rp 75.780',
              style: TextStyle(
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
                        flex: 55,
                        child: Container(height: 8, color: AppColors.primary),
                      ),
                      Expanded(
                        flex: 30,
                        child: Container(height: 8, color: AppColors.secondary),
                      ),
                      Expanded(
                        flex: 15,
                        child: Container(height: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
            footerWidget: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                    SizedBox(width: 3),
                    Text('QRIS 55%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.secondary),
                    SizedBox(width: 3),
                    Text('Tunai 30%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.onSurfaceVariant),
                    SizedBox(width: 3),
                    Text('Kartu 15%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
