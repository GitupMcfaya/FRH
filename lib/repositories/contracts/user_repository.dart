import '../../models/user.dart';

abstract interface class UserRepository {
  Future<List<User>> getAll();

  Future<User> create(User user);

  Future<User> update(User user);

  Future<User> setActive(String id, bool active);
}
