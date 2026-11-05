import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';

class MainShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left Fixed 80px Navigation Rail
          Container(
            width: 80,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                right: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // App Logo / Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.utensilsCrossed,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _RailItem(
                        icon: LucideIcons.calculator,
                        label: 'KASIR',
                        isSelected: navigationShell.currentIndex == 0,
                        onTap: () => _onDestinationSelected(0),
                      ),
                      const SizedBox(height: 8),
                      _RailItem(
                        icon: LucideIcons.clipboardList,
                        label: 'PESANAN',
                        isSelected: navigationShell.currentIndex == 1,
                        onTap: () => _onDestinationSelected(1),
                      ),
                      const SizedBox(height: 8),
                      _RailItem(
                        icon: LucideIcons.layoutGrid,
                        label: 'MENU',
                        isSelected: navigationShell.currentIndex == 2,
                        onTap: () => _onDestinationSelected(2),
                      ),
                      const SizedBox(height: 8),
                      _RailItem(
                        icon: LucideIcons.barChart3,
                        label: 'LAPORAN',
                        isSelected: navigationShell.currentIndex == 3,
                        onTap: () => _onDestinationSelected(3),
                      ),
                    ],
                  ),
                ),
                // Bottom Profile / Terminal Indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHighest,
                          border: Border.all(color: AppColors.divider, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.user,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Body Content
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
