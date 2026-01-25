import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'di.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';
import '../core/l10n/l10n.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/discover/presentation/blocs/discover_bloc.dart';
import '../features/map/presentation/blocs/map_bloc.dart';
import '../features/profile/presentation/blocs/profile_bloc.dart';

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

    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(
          create: (context) => DiscoverBloc(getOohUnitsUseCase: getIt()),
        ),
        BlocProvider(create: (context) => MapBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
      ],
      child: MaterialApp.router(
        title: 'OOH Planner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
        localizationsDelegates: const [
          AppLocalizations.delegate, // This will be available after generation
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('sr')],
      ),
    );
  }
}
