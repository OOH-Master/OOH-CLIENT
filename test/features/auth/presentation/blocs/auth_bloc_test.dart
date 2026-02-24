import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ooh_mobile/core/utils/failures.dart' hide AuthFailure;
import 'package:ooh_mobile/core/utils/result.dart';
import 'package:ooh_mobile/features/auth/domain/entities/role.dart';
import 'package:ooh_mobile/features/auth/domain/entities/user.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ooh_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:ooh_mobile/features/auth/presentation/blocs/auth_bloc.dart';

@GenerateNiceMocks([
  MockSpec<LoginUseCase>(),
  MockSpec<RegisterUseCase>(),
  MockSpec<GetCurrentUserUseCase>(),
  MockSpec<LogoutUseCase>(),
])
import 'auth_bloc_test.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  const testUser = User(
    id: '1',
    email: 'test@test.com',
    name: 'testuser',
    role: Role.brand,
  );

  setUpAll(() {
    // Mockito zahteva dummy vrednosti za sealed Result<T> tipove
    provideDummy<Result<User>>(const Success(testUser));
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

  // ─── LoginSubmitted ───────────────────────────────────────────────

  group('LoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emituje [AuthLoading, AuthAuthenticated] na uspesan login',
      build: () {
        when(mockLoginUseCase('testuser', 'password123'))
            .thenAnswer((_) async => const Success(testUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoginSubmitted('testuser', 'password123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.name,
          'user.name',
          'testuser',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emituje [AuthLoading, AuthFailure] na neuspesan login',
      build: () {
        when(mockLoginUseCase('wrong', 'wrong'))
            .thenAnswer((_) async => const Error(ServerFailure('Invalid credentials')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoginSubmitted('wrong', 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.message,
          'message',
          'Invalid credentials',
        ),
      ],
    );
  });

  // ─── RegisterSubmitted ────────────────────────────────────────────

  group('RegisterSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emituje [AuthLoading, AuthAuthenticated] na uspesnu registraciju',
      build: () {
        when(mockRegisterUseCase('TestUser', 'test@test.com', 'pass123', Role.brand))
            .thenAnswer((_) async => const Success(testUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RegisterSubmitted(
        name: 'TestUser',
        email: 'test@test.com',
        password: 'pass123',
        role: Role.brand,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );
  });

  // ─── LogoutRequested ──────────────────────────────────────────────

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emituje [AuthLoading, AuthUnauthenticated] na logout',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => const Success(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  // ─── AuthStarted ─────────────────────────────────────────────────

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emituje [AuthAuthenticated] ako postoji sacuvan token/korisnik',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Success(testUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthAuthenticated>().having(
          (s) => s.user.role,
          'user.role',
          Role.brand,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emituje [AuthUnauthenticated] ako nema sacuvanog korisnika',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Success<User?>(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthStarted()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
    );
  });
}
