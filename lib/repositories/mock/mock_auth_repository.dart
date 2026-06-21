import 'dart:async';

import '../../core/errors/repository_exception.dart';
import '../../models/user.dart';
import '../contracts/auth_repository.dart';
import 'mock_data.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.latency = const Duration(milliseconds: 250)})
    : _users = MockData.users(DateTime.now());

  final Duration latency;
  final List<User> _users;
  final _authController = StreamController<User?>.broadcast();
  User? _currentUser;

  static const _passwords = {
    'admin@unihostel.edu.gh': 'Admin123!',
    'reception@unihostel.edu.gh': 'Reception123!',
  };

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    final normalizedEmail = email.trim().toLowerCase();
    final matchingUsers = _users.where(
      (candidate) => candidate.email.toLowerCase() == normalizedEmail,
    );

    if (matchingUsers.isEmpty || _passwords[normalizedEmail] != password) {
      throw const AuthenticationException('Invalid email or password.');
    }

    final user = matchingUsers.single;
    if (!user.isActive) {
      throw const AuthenticationException('This user account is inactive.');
    }

    _currentUser = user.copyWith(lastLoginAt: DateTime.now());
    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(latency);
    _currentUser = null;
    _authController.add(null);
  }

  @override
  void dispose() => _authController.close();
}
