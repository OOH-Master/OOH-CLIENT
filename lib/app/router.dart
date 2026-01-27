import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/discover/presentation/pages/discover_detail_page.dart';
import '../features/discover/presentation/pages/discover_page.dart';
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

      // If logged in and trying to access auth pages, redirect to app
      if (isLoggedIn && (isLoggingIn || isLanding)) {
        return '/app/discover';
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
