import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';

/// Firebase authentication data source
///
/// Handles all Firebase Authentication and Firestore operations
/// for user authentication and profile management
class FirebaseAuthDataSource {
  /// Firebase Authentication instance
  final fb_auth.FirebaseAuth _firebaseAuth;

  /// Firestore database instance
  final FirebaseFirestore _firestore;

  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn;

  /// Creates a new FirebaseAuthDataSource instance
  FirebaseAuthDataSource({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of authentication state changes
  Stream<fb_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed: user is null');
      }

      final userModel = await _getUserFromFirestore(user.uid);
      if (userModel == null) {
        throw Exception('User data not found in Firestore');
      }

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign up failed: user is null');
      }

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: name,
        phoneNumber: phone,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(
        userModel.toFirestore(),
      );

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google sign in failed: user is null');
      }

      // Check if user exists in Firestore
      var userModel = await _getUserFromFirestore(user.uid);

      if (userModel == null) {
        // Create new user
        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          isVerified: user.emailVerified,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(
          userModel.toFirestore(),
        );
      }

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign in with Apple
  Future<UserModel> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = fb_auth.OAuthProvider('apple.com');
      final firebaseCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        firebaseCredential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Apple sign in failed: user is null');
      }

      // Check if user exists in Firestore
      var userModel = await _getUserFromFirestore(user.uid);

      if (userModel == null) {
        // Create new user
        final fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();

        userModel = UserModel(
          uid: user.uid,
          email: credential.email ?? user.email ?? '',
          displayName: fullName.isNotEmpty ? fullName : user.displayName ?? '',
          photoUrl: user.photoURL,
          isVerified: user.emailVerified,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(
          userModel.toFirestore(),
        );
      }

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Apple sign in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Verify email with verification code
  Future<bool> verifyEmail(String code) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // In a real app, you would verify the code against what was sent
      // For now, we'll update the Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'isVerified': true,
      });

      return true;
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Resend verification email failed: ${e.toString()}');
    }
  }

  /// Reset password for email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      return _getUserFromFirestore(user.uid);
    } catch (e) {
      throw Exception('Get current user failed: ${e.toString()}');
    }
  }

  /// Update user profile information
  Future<UserModel> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    Map<String, String>? location,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (location != null) updateData['location'] = location;

      await _firestore.collection('users').doc(uid).update(updateData);

      final userModel = await _getUserFromFirestore(uid);
      if (userModel == null) {
        throw Exception('User not found after update');
      }

      return userModel;
    } catch (e) {
      throw Exception('Update profile failed: ${e.toString()}');
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw Exception('Update FCM token failed: ${e.toString()}');
    }
  }

  /// Get user from Firestore by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc.data() ?? {}, uid);
    } catch (e) {
      throw Exception('Get user by ID failed: ${e.toString()}');
    }
  }

  /// Add experience to favorites
  Future<void> addToFavorites(String uid, String experienceId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'favorites': FieldValue.arrayUnion([experienceId]),
      });
    } catch (e) {
      throw Exception('Add to favorites failed: ${e.toString()}');
    }
  }

  /// Remove experience from favorites
  Future<void> removeFromFavorites(String uid, String experienceId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'favorites': FieldValue.arrayRemove([experienceId]),
      });
    } catch (e) {
      throw Exception('Remove from favorites failed: ${e.toString()}');
    }
  }

  /// Helper method to get user from Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc.data() ?? {}, uid);
    } catch (e) {
      return null;
    }
  }

  /// Handle Firebase Auth exceptions
  Exception _handleFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('This email is already in use');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'user-disabled':
        return Exception('This user account has been disabled');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
