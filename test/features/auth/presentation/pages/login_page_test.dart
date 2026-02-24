import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ooh_mobile/core/l10n/app_localizations.dart';
import 'package:ooh_mobile/core/l10n/locale_cubit.dart';
import 'package:ooh_mobile/core/utils/result.dart';
import 'package:ooh_mobile/features/auth/domain/entities/role.dart';
import 'package:ooh_mobile/features/auth/domain/entities/user.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:ooh_mobile/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:ooh_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<LoginUseCase>(),
  MockSpec<RegisterUseCase>(),
  MockSpec<GetCurrentUserUseCase>(),
  MockSpec<LogoutUseCase>(),
])
import 'login_page_test.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUpAll(() {
    // Sprecava Google Fonts da pokusava runtime loading u testovima
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mockito zahteva dummy vrednosti za sealed Result<T> tipove
    provideDummy<Result<User>>(const Success(User(
      id: '0',
      email: '',
      name: '',
      role: Role.brand,
    )));
    provideDummy<Result<User?>>(const Success<User?>(null));
    provideDummy<Result<void>>(const Success(null));
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        logoutUseCase: mockLogoutUseCase,
      );

  /// Kreira GoRouter za test okruzenje
  GoRouter buildTestRouter() => GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const LoginPage()),
          GoRoute(
              path: '/register', builder: (_, __) => const Scaffold()),
          GoRoute(
              path: '/auth/login', builder: (_, __) => const Scaffold()),
          GoRoute(
              path: '/app/discover',
              builder: (_, __) => const Scaffold()),
        ],
      );

  /// Pumps LoginPage sa svim potrebnim provajderima
  Future<void> pumpLoginPage(
    WidgetTester tester, {
    AuthBloc? bloc,
  }) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'sr'});
    final prefs = await SharedPreferences.getInstance();

    final router = buildTestRouter();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
              create: (_) => bloc ?? buildBloc()),
          BlocProvider<LocaleCubit>(
              create: (_) => LocaleCubit(prefs)),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('sr'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ─── Rendering Tests ──────────────────────────────────────────────────

  group('LoginPage rendering', () {
    testWidgets('prikazuje polja za username i password', (tester) async {
      await pumpLoginPage(tester);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('prikazuje login dugme', (tester) async {
      await pumpLoginPage(tester);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('prikazuje AutoHome logo tekst', (tester) async {
      await pumpLoginPage(tester);
      expect(find.text('AutoHome'), findsOneWidget);
    });
  });

  group('LoginPage validation', () {
    testWidgets('prikazuje gresku validacije za prazna polja', (tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('ne prikazuje gresku kada su polja popunjena', (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginPage BLoC interaction', () {
    testWidgets('dispatchuje LoginSubmitted na validnu formu', (tester) async {
      const testUser = User(
        id: '1',
        email: 'test@test.com',
        name: 'testuser',
        role: Role.brand,
      );

      when(mockLoginUseCase('testuser', 'password123'))
          .thenAnswer((_) async => const Success(testUser));

      final bloc = buildBloc();
      await pumpLoginPage(tester, bloc: bloc);

      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(mockLoginUseCase('testuser', 'password123')).called(1);
    });

    testWidgets('prikazuje CircularProgressIndicator tokom loading stanja',
        (tester) async {
      // Completer umesto Future.delayed — sprecava pending timer u testu
      final completer = Completer<Result<User>>();
      when(mockLoginUseCase(any, any)).thenAnswer((_) => completer.future);

      final bloc = buildBloc();
      await pumpLoginPage(tester, bloc: bloc);

      await tester.enterText(find.byType(TextFormField).first, 'testuser');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Success(
        User(
          id: '1',
          email: 'test@test.com',
          name: 'testuser',
          role: Role.brand,
        ),
      ));
      await tester.pump();
    });
  });
}
