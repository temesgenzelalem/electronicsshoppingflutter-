import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:electromart_pro/core/firebase/auth_service.dart';
import 'package:electromart_pro/core/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider =
    StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        state = UserModel(
          id: user.uid,
          email: user.email,
          name: user.displayName,
          phone: user.phoneNumber,
          avatar: user.photoURL,
          emailVerified: user.emailVerified,
          joinDate: user.metadata.creationTime,
        );
      } else {
        state = null;
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final user = await _authService.signInWithEmailAndPassword(email, password);
    state = user;
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    final user =
        await _authService.createUserWithEmailAndPassword(email, password);
    state = user;
  }

  Future<void> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    state = user;
  }

  Future<void> signInWithApple() async {
    final user = await _authService.signInWithApple();
    state = user;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onVerificationCompleted,
    Function(FirebaseAuthException) onVerificationFailed,
  ) async {
    await _authService.verifyPhoneNumber(
      phoneNumber,
      onCodeSent,
      onVerificationCompleted,
      onVerificationFailed,
    );
  }

  Future<void> signInWithPhoneCredential(
      String verificationId, String smsCode) async {
    final user =
        await _authService.signInWithPhoneCredential(verificationId, smsCode);
    state = user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> updateEmail(String newEmail) async {
    await _authService.updateEmail(newEmail);
  }

  Future<void> updatePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    state = null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}
