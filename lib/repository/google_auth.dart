import 'package:firebase_auth/firebase_auth.dart';

class GoogleAccount {
  final String name;
  final String email;
  const GoogleAccount(this.name, this.email);
}

/// "Continue with Google" through Firebase Authentication. Needs the Google
/// sign-in method switched on for the Firebase project.
class GoogleAuth {
  /// The chosen Google account, or null if the user closed the sign-in page.
  /// Any other problem (no network, Google not enabled, Firebase not started)
  /// is thrown so the screen can tell the user.
  Future<GoogleAccount?> signIn() async {
    try {
      final cred =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      final user = cred.user;
      final email = user?.email;
      if (email == null) return null;
      return GoogleAccount(user!.displayName ?? email, email);
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('cancel')) return null; // closed by the user
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {} // Firebase not running or nobody signed in: nothing to do
  }
}
