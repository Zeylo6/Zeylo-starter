import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementation of AuthRepository using Firebase
///
/// Implements all authentication operations by delegating to the Firebase data source
/// and adding error handling and data transformation
class AuthRepositoryImpl implements AuthRepository {
  /// The Firebase authentication data source
  final FirebaseAuthDataSource dataSource;

  /// Creates a new AuthRepositoryImpl instance
  const AuthRepositoryImpl({required this.dataSource});

  @override
  Stream<UserEntity?> get authStateChanges {
    return dataSource.authStateChanges.map((fbUser) => null);
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await dataSource.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      return await dataSource.signUpWithEmail(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      return await dataSource.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      return await dataSource.signInWithApple();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> verifyEmail(String code) async {
    try {
      return await dataSource.verifyEmail(code);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      await dataSource.resendVerificationEmail();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await dataSource.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    Map<String, String>? location,
  }) async {
    try {
      // Get current user UID
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      return await dataSource.updateProfile(
        uid: currentUser.uid,
        displayName: displayName,
        photoUrl: photoUrl,
        bio: bio,
        phoneNumber: phoneNumber,
        location: location,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserVerified() async {
    try {
      final currentUser = await getCurrentUser();
      return currentUser?.isVerified ?? false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      await dataSource.updateFcmToken(currentUser.uid, token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUserById(String uid) async {
    try {
      return await dataSource.getUserById(uid);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addToFavorites(String experienceId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      await dataSource.addToFavorites(currentUser.uid, experienceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String experienceId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      await dataSource.removeFromFavorites(currentUser.uid, experienceId);
    } catch (e) {
      rethrow;
    }
  }
}
