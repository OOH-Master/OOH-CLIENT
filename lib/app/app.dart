import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/locale_cubit.dart';
import '../core/config/api_client.dart';
import '../core/services/websocket_service.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/data/repository/admin_config_repository.dart';
import '../features/admin/data/repository/admin_user_repository.dart';
import '../features/agency/data/repository/agency_repository.dart';
import '../features/auth/data/datasources/auth_token_storage.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/availability/data/repository/availability_repository.dart';
import '../features/campaign/data/repository/campaign_repository.dart';
import '../features/dashboard/data/repository/analytics_repository.dart';
import '../features/discover/data/repository/discover_repository.dart';
import '../features/discover/presentation/blocs/discover_bloc.dart';
import '../features/favorite/data/repository/favorite_repository.dart';
import '../features/favorite/presentation/blocs/favorite_bloc.dart';
import '../features/inquiry/data/repository/inquiry_repository.dart';
import '../features/inventory_management/data/repository/inventory_management_repository.dart';
import '../features/notification/data/repository/notification_repository.dart';
import '../features/notification/presentation/blocs/notification_bloc.dart';
import '../features/profile/data/repository/profile_repository.dart';
import 'di.dart';
import 'router.dart';

class OohApp extends StatefulWidget {
  const OohApp({super.key});

  @override
  State<OohApp> createState() => _OohAppState();
}

class _OohAppState extends State<OohApp> {
  late final AuthBloc _authBloc;
  late final NotificationBloc _notificationBloc;
  late final AppRouter _appRouter;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc(getIt<NotificationRepository>());

    _authBloc = AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      logoutUseCase: getIt(),
    )..add(AuthStarted());

    // Wire up logout callback so expired refresh tokens trigger proper logout
    getIt<ApiClient>().setLogoutCallback(() {
      _authBloc.add(LogoutRequested());
    });

    // Initialize WebSocket service
    WebSocketService().init(getIt<AuthTokenStorage>(), _notificationBloc);

    // Connect/disconnect WebSocket on auth state changes + restore cart redirect
    _authSubscription = _authBloc.stream.listen((state) async {
      if (state is AuthAuthenticated) {
        WebSocketService().connect();
        _notificationBloc.add(LoadUnreadCount());
        await _restoreRedirectAfterLogin();
      } else if (state is AuthUnauthenticated) {
        WebSocketService().disconnect();
      }
    });

    _appRouter = AppRouter(_authBloc);
  }

  Future<void> _restoreRedirectAfterLogin() async {
    // Check in-memory first (synchronous, set in the same session)
    String? redirect = AppRouter.pendingRedirect;
    AppRouter.clearPendingRedirect();

    // Fall back to SharedPreferences (for cross-session persistence)
    if (redirect == null || redirect.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      redirect = prefs.getString('redirect_after_login');
      if (redirect != null && redirect.isNotEmpty) {
        await prefs.remove('redirect_after_login');
      }
    }

    if (redirect != null && redirect.isNotEmpty && mounted) {
      // Small delay to let router settle after auth state change
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted && _appRouter.router.routerDelegate.currentConfiguration.fullPath != redirect) {
        _appRouter.router.go(redirect);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    WebSocketService().disconnect();
    _authBloc.close();
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<ApiClient>()),
        RepositoryProvider.value(value: getIt<DiscoverRepository>()),
        RepositoryProvider.value(value: getIt<InquiryRepository>()),
        RepositoryProvider.value(value: getIt<InventoryManagementRepository>()),
        RepositoryProvider.value(value: getIt<CampaignRepository>()),
        RepositoryProvider.value(value: getIt<AdminConfigRepository>()),
        RepositoryProvider.value(value: getIt<AdminUserRepository>()),
        RepositoryProvider.value(value: getIt<AgencyRepository>()),
        RepositoryProvider.value(value: getIt<AvailabilityRepository>()),
        RepositoryProvider.value(value: getIt<ProfileRepository>()),
        RepositoryProvider.value(value: getIt<AnalyticsRepository>()),
        RepositoryProvider.value(value: getIt<NotificationRepository>()),
        RepositoryProvider.value(value: getIt<FavoriteRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider(
            create: (context) => DiscoverBloc(
              repository: getIt<DiscoverRepository>(),
            ),
          ),
          BlocProvider.value(value: _notificationBloc),
          BlocProvider(
            create: (_) => FavoriteBloc(getIt<FavoriteRepository>()),
          ),
          BlocProvider(create: (_) => LocaleCubit(getIt())),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: 'OOH Planner',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              routerConfig: _appRouter.router,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('sr')],
            );
          },
        ),
      ),
    );
  }
}
