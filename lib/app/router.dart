import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/landing/presentation/pages/landing_page.dart';
import '../features/shell/presentation/pages/main_shell_page.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/map',
                builder: (context, state) => const MapPage(),
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

      if (!isLoggedIn) {
        // If not logged in, allow landing and auth pages
        if (isLanding || isLoggingIn) {
          return null;
        }
        // Otherwise redirect to login
        return '/auth/login';
      }

      // If logged in
      if (isLoggingIn || isLanding) {
        // Redirect to discover if trying to access auth or landing
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
