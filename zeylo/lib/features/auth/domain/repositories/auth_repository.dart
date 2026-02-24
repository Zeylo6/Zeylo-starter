import '../entities/user_entity.dart';

/// Abstract repository for authentication operations
///
/// Defines the contract for authentication-related operations
/// including sign in, sign up, password reset, and user profile management.
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Throws [Exception] if sign in fails
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  ///
  /// Creates a new user account with the provided credentials
  /// Throws [Exception] if sign up fails
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Sign in using Google OAuth
  ///
  /// Opens Google sign in flow and authenticates user
  /// Throws [Exception] if sign in fails
  Future<UserEntity> signInWithGoogle();

  /// Sign in using Apple OAuth
  ///
  /// Opens Apple sign in flow and authenticates user
  /// Throws [Exception] if sign in fails
  Future<UserEntity> signInWithApple();

  /// Sign out the current user
  ///
  /// Clears authentication tokens and user session
  Future<void> signOut();

  /// Verify email with verification code
  ///
  /// Verifies the user's email address using a sent verification code
  /// Returns true if verification succeeds
  Future<bool> verifyEmail(String code);

  /// Resend verification email
  ///
  /// Sends a new verification email to the user
  Future<void> resendVerificationEmail();

  /// Reset password for email
  ///
  /// Sends password reset email to the provided email address
  Future<void> resetPassword(String email);

  /// Get the current authenticated user
  ///
  /// Returns the currently logged-in user or null if not authenticated
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes
  ///
  /// Emits the current user whenever authentication state changes
  /// Emits null when user is signed out
  Stream<UserEntity?> get authStateChanges;

  /// Update user profile information
  ///
  /// Updates the user's profile with new information
  Future<UserEntity> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    Map<String, String>? location,
  });

  /// Check if user is verified
  ///
  /// Returns true if user's email is verified
  Future<bool> isUserVerified();

  /// Update user's FCM token
  ///
  /// Stores the FCM token for push notifications
  Future<void> updateFcmToken(String token);

  /// Get user by UID
  ///
  /// Retrieves user data from Firestore
  Future<UserEntity?> getUserById(String uid);

  /// Add experience to user favorites
  ///
  /// Adds an experience ID to the user's favorites list
  Future<void> addToFavorites(String experienceId);

  /// Remove experience from user favorites
  ///
  /// Removes an experience ID from the user's favorites list
  Future<void> removeFromFavorites(String experienceId);
}
