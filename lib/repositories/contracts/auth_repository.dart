import '../../models/user.dart';

abstract interface class AuthRepository {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<User> signIn({required String email, required String password});

  Future<void> signOut();

  void dispose();
}
