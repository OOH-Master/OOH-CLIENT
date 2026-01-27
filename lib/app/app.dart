import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import '../features/discover/data/repository/discover_repository.dart';
import '../features/discover/presentation/blocs/discover_bloc.dart';
import '../features/profile/presentation/blocs/profile_bloc.dart';
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
          create: (context) => DiscoverBloc(
            repository: getIt<DiscoverRepository>(),
          ),
        ),
        BlocProvider(create: (context) => ProfileBloc()),
      ],
      child: MaterialApp.router(
        title: 'OOH Planner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _appRouter.router,
        locale: const Locale('sr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('sr')],
      ),
    );
  }
}
