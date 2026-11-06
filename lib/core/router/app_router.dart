import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_pin_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/catalog/category_modifier_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/staff/staff_management_screen.dart';
import '../../shared/widgets/main_shell_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorPosKey = GlobalKey<NavigatorState>(debugLabel: 'pos');
final _shellNavigatorOrdersKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
final _shellNavigatorCatalogKey = GlobalKey<NavigatorState>(debugLabel: 'catalog');
final _shellNavigatorCategoriesKey = GlobalKey<NavigatorState>(debugLabel: 'categories');
final _shellNavigatorStaffKey = GlobalKey<NavigatorState>(debugLabel: 'staff');
final _shellNavigatorReportsKey = GlobalKey<NavigatorState>(debugLabel: 'reports');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isLoginRoute = state.matchedLocation == '/login';

      if (user == null && !isLoginRoute) {
        return '/login';
      }
      if (user != null && isLoginRoute) {
        return '/pos';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPinScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPosKey,
            routes: [
              GoRoute(
                path: '/pos',
                builder: (context, state) => const PosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOrdersKey,
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCatalogKey,
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCategoriesKey,
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoryModifierScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStaffKey,
            routes: [
              GoRoute(
                path: '/staff',
                builder: (context, state) => const StaffManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorReportsKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
