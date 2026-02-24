import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';

/// Firebase Auth datasource provider
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

/// Sign in use case provider
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

/// Sign up use case provider
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

/// Sign out use case provider
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

/// Verify email use case provider
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyEmailUseCase(repository);
});

/// Google sign in use case provider
final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleSignInUseCase(repository);
});

/// Auth state provider - watches Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current user provider - fetches current user from database
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  /// The auth repository
  final AuthRepository _repository;

  /// Creates a new AuthNotifier instance
  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithEmail(
        email: email,
        password: password,
      );
    });
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signUpWithEmail(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    });
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithGoogle();
    });
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.signInWithApple();
    });
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.signOut();
      return null;
    });
  }

  /// Verify email
  Future<bool> verifyEmail(String code) async {
    try {
      return await _repository.verifyEmail(code);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _repository.resendVerificationEmail();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    try {
      await _repository.updateFcmToken(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
