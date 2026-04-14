import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/locale_cubit.dart';
import '../core/config/api_client.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/data/repository/admin_config_repository.dart';
import '../features/admin/data/repository/admin_user_repository.dart';
import '../features/agency/data/repository/agency_repository.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/availability/data/repository/availability_repository.dart';
import '../features/campaign/data/repository/campaign_repository.dart';
import '../features/dashboard/data/repository/analytics_repository.dart';
import '../features/discover/data/repository/discover_repository.dart';
import '../features/discover/presentation/blocs/discover_bloc.dart';
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
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
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

    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider(
            create: (context) => DiscoverBloc(
              repository: getIt<DiscoverRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => NotificationBloc(getIt<NotificationRepository>()),
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
