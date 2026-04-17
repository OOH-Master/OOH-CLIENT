import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/admin/presentation/pages/admin_config_page.dart';
import '../features/admin/presentation/pages/admin_users_page.dart';
import '../features/agency/presentation/pages/agency_brands_page.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/email_verification_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/availability/presentation/pages/availability_management_page.dart';
import '../features/campaign/presentation/pages/campaign_calendar_page.dart';
import '../features/campaign/presentation/pages/campaign_detail_page.dart';
import '../features/campaign/presentation/pages/campaign_edit_page.dart';
import '../features/campaign/presentation/pages/campaign_form_page.dart';
import '../features/campaign/presentation/pages/campaign_list_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/discover/presentation/pages/discover_detail_page.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/favorite/presentation/pages/favorites_page.dart';
import '../features/inquiry/presentation/pages/admin_assign_units_page.dart';
import '../features/inquiry/presentation/pages/admin_inquiry_management_page.dart';
import '../features/inquiry/presentation/pages/inquiry_create_page.dart';
import '../features/inquiry/presentation/pages/inquiry_detail_page.dart';
import '../features/inquiry/presentation/pages/inquiry_list_page.dart';
import '../features/inquiry/presentation/pages/media_owner_quotes_page.dart';
import '../features/inquiry/presentation/pages/offer_review_page.dart';
import '../features/inventory_management/presentation/pages/inventory_form_page.dart';
import '../features/inventory_management/presentation/pages/my_inventory_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/notification/presentation/pages/notifications_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/shell/presentation/pages/main_shell_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  // Synchronous in-memory store for redirect path (SharedPreferences is async)
  static String? _pendingRedirect;
  static String? get pendingRedirect => _pendingRedirect;
  static void clearPendingRedirect() => _pendingRedirect = null;

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
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return EmailVerificationPage(token: token);
        },
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
        path: '/app/inquiries/:id/offer',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OfferReviewPage(inquiryId: id);
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
        path: '/app/campaigns/calendar',
        builder: (context, state) => const CampaignCalendarPage(),
      ),
      GoRoute(
        path: '/app/campaigns/create',
        builder: (context, state) => const CampaignFormPage(),
      ),
      GoRoute(
        path: '/app/campaigns/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CampaignDetailPage(campaignId: id);
        },
      ),
      GoRoute(
        path: '/app/campaigns/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CampaignEditPage(campaignId: id);
        },
      ),
      GoRoute(
        path: '/app/admin/config',
        builder: (context, state) => const AdminConfigPage(),
      ),
      GoRoute(
        path: '/app/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: '/app/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/app/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/app/admin/inquiries',
        builder: (context, state) => const AdminInquiryManagementPage(),
      ),
      GoRoute(
        path: '/app/admin/inquiries/:id/assign-units',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return AdminAssignUnitsPage(inquiryId: id);
        },
      ),
      GoRoute(
        path: '/app/agency/brands',
        builder: (context, state) => const AgencyBrandsPage(),
      ),
      GoRoute(
        path: '/app/media-owner/quotes',
        builder: (context, state) => const MediaOwnerQuotesPage(),
      ),
      GoRoute(
        path: '/app/media-owner/availability',
        builder: (context, state) => const AvailabilityManagementPage(),
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.uri.toString().startsWith('/auth');
      final isLanding = state.uri.toString() == '/';
      final isPublicDiscover = state.uri.toString().startsWith('/discover');

      // If logged in and trying to access auth pages or landing, redirect to dashboard
      if (isLoggedIn && (isLoggingIn || isLanding)) {
        return '/app/dashboard';
      }

      // Allow public routes without auth
      if (isLanding || isLoggingIn || isPublicDiscover) {
        return null;
      }

      // For /app/* routes, require auth — save intended path for post-login redirect
      if (!isLoggedIn && state.uri.toString().startsWith('/app')) {
        final path = state.uri.toString();
        _pendingRedirect = path;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('redirect_after_login', path);
        });
        return '/auth/login';
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
