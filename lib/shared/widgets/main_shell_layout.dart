import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_providers.dart';

class MainShellLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.role.toLowerCase() ?? 'cashier';

    // RBAC Filter:
    // admin: 0 (POS), 1 (Orders), 2 (Catalog), 3 (Categories), 4 (Staff), 5 (Reports)
    // manager: 0 (POS), 1 (Orders), 2 (Catalog), 5 (Reports)
    // cashier: 0 (POS), 1 (Orders)
    final List<_NavConfig> availableNavs = [];

    availableNavs.add(const _NavConfig(
      branchIndex: 0,
      icon: LucideIcons.calculator,
      label: 'KASIR',
    ));
    availableNavs.add(const _NavConfig(
      branchIndex: 1,
      icon: LucideIcons.clipboardList,
      label: 'PESANAN',
    ));

    if (role == 'admin' || role == 'manager') {
      availableNavs.add(const _NavConfig(
        branchIndex: 2,
        icon: LucideIcons.layoutGrid,
        label: 'MENU',
      ));
    }

    if (role == 'admin') {
      availableNavs.add(const _NavConfig(
        branchIndex: 3,
        icon: LucideIcons.tags,
        label: 'KATEGORI',
      ));
      availableNavs.add(const _NavConfig(
        branchIndex: 4,
        icon: LucideIcons.users,
        label: 'STAF',
      ));
    }

    if (role == 'admin' || role == 'manager') {
      availableNavs.add(const _NavConfig(
        branchIndex: 5,
        icon: LucideIcons.barChart3,
        label: 'LAPORAN',
      ));
    }

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
                // App Brand Logo
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
                const SizedBox(height: 20),

                // Navigation Items based on RBAC
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: availableNavs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = availableNavs[index];
                      final isSelected = navigationShell.currentIndex == item.branchIndex;
                      return _RailItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: isSelected,
                        onTap: () => _onDestinationSelected(item.branchIndex),
                      );
                    },
                  ),
                ),

                // Bottom Active User & Lock Terminal Button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      // Lock Screen / Switch Staff CTA
                      IconButton(
                        icon: const Icon(LucideIcons.lock, size: 18),
                        tooltip: 'Kunci Layar / Ganti Staf',
                        color: AppColors.onSurfaceVariant,
                        onPressed: () {
                          ref.read(authControllerProvider).logout();
                          context.go('/login');
                        },
                      ),
                      const SizedBox(height: 4),

                      // User Profile Avatar with Online indicator
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceContainerHighest,
                            backgroundImage: currentUser?.avatarUrl != null
                                ? NetworkImage(currentUser!.avatarUrl!)
                                : null,
                            child: currentUser?.avatarUrl == null
                                ? const Icon(LucideIcons.user, size: 18, color: AppColors.onSurfaceVariant)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser != null ? currentUser.name.split(' ').first : 'Kasir',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
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

class _NavConfig {
  final int branchIndex;
  final IconData icon;
  final String label;

  const _NavConfig({
    required this.branchIndex,
    required this.icon,
    required this.label,
  });
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
        height: 60,
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
              size: 20,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
