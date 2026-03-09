import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_config_page.dart';
import '../features/agency/presentation/pages/agency_brands_page.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/campaign/presentation/pages/campaign_form_page.dart';
import '../features/campaign/presentation/pages/campaign_list_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/discover/presentation/pages/discover_detail_page.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/inquiry/presentation/pages/inquiry_create_page.dart';
import '../features/inquiry/presentation/pages/inquiry_detail_page.dart';
import '../features/inquiry/presentation/pages/inquiry_list_page.dart';
import '../features/inventory_management/presentation/pages/inventory_form_page.dart';
import '../features/inventory_management/presentation/pages/my_inventory_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/shell/presentation/pages/main_shell_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // Public routes - NO shell/bottom bar
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverPage(),
      ),
      GoRoute(
        path: '/discover/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DiscoverDetailPage(unitId: id);
        },
      ),
      // Authenticated routes with shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // Branch 1: Discover
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/discover',
                builder: (context, state) => const DiscoverPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return DiscoverDetailPage(unitId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Sub-routes pushed over the shell (no bottom bar change)
      GoRoute(
        path: '/app/inquiries',
        builder: (context, state) => const InquiryListPage(),
      ),
      GoRoute(
        path: '/app/inquiries/create',
        builder: (context, state) {
          final unitIdsParam = state.uri.queryParameters['unitIds'] ?? '';
          final unitIds = unitIdsParam.isNotEmpty
              ? unitIdsParam.split(',').where((id) => id.isNotEmpty).toList()
              : <String>[];
          return InquiryCreatePage(unitIds: unitIds);
        },
      ),
      GoRoute(
        path: '/app/inquiries/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return InquiryDetailPage(inquiryId: id);
        },
      ),
      GoRoute(
        path: '/app/my-inventory',
        builder: (context, state) => const MyInventoryPage(),
      ),
      GoRoute(
        path: '/app/inventory/create',
        builder: (context, state) => const InventoryFormPage(),
      ),
      GoRoute(
        path: '/app/inventory/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return InventoryFormPage(inventoryId: id);
        },
      ),
      GoRoute(
        path: '/app/campaigns',
        builder: (context, state) => const CampaignListPage(),
      ),
      GoRoute(
        path: '/app/campaigns/create',
        builder: (context, state) => const CampaignFormPage(),
      ),
      GoRoute(
        path: '/app/admin/config',
        builder: (context, state) => const AdminConfigPage(),
      ),
      GoRoute(
        path: '/app/agency/brands',
        builder: (context, state) => const AgencyBrandsPage(),
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.uri.toString().startsWith('/auth');
      final isLanding = state.uri.toString() == '/';
      final isPublicDiscover = state.uri.toString().startsWith('/discover');

      // Allow public routes without auth
      if (isLanding || isLoggingIn || isPublicDiscover) {
        return null;
      }

      // For /app/* routes, require auth
      if (!isLoggedIn && state.uri.toString().startsWith('/app')) {
        return '/auth/login';
      }

      // If logged in and trying to access auth pages or landing, redirect to dashboard
      if (isLoggedIn && (isLoggingIn || isLanding)) {
        return '/app/dashboard';
      }

      return null;
    },
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
