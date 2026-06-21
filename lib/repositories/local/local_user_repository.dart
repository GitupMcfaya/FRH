import '../../core/errors/repository_exception.dart';
import '../../core/services/local_json_store.dart';
import '../../models/user.dart';
import '../../repositories/mock/mock_data.dart';
import '../contracts/user_repository.dart';

class LocalUserRepository implements UserRepository {
  LocalUserRepository(this._store);

  final LocalJsonStore _store;
  List<User>? _users;

  Future<List<User>> _load() async {
    if (_users != null) return _users!;
    final json = await _store.readList('users.json');
    _users = json == null
        ? MockData.users(DateTime.now())
        : json
              .map((item) => User.fromJson(item as Map<String, dynamic>))
              .toList();
    return _users!;
  }

  Future<void> _save() async {
    await _store.writeList(
      'users.json',
      _users!.map((user) => user.toJson()).toList(),
    );
  }

  @override
  Future<List<User>> getAll() async {
    final users = [...await _load()]
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(users);
  }

  @override
  Future<User> create(User user) async {
    final users = await _load();
    _ensureUnique(user, users);
    final created = user.id.isEmpty
        ? user.copyWith(id: 'user-${DateTime.now().microsecondsSinceEpoch}')
        : user;
    users.add(created);
    await _save();
    return created;
  }

  @override
  Future<User> update(User user) async {
    final users = await _load();
    final index = users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      throw RecordNotFoundException('User ${user.id} was not found.');
    }
    _ensureUnique(user, users, excludingId: user.id);
    users[index] = user;
    await _save();
    return user;
  }

  @override
  Future<User> setActive(String id, bool active) async {
    final users = await _load();
    final index = users.indexWhere((user) => user.id == id);
    if (index == -1) throw RecordNotFoundException('User $id was not found.');
    final updated = users[index].copyWith(isActive: active);
    users[index] = updated;
    await _save();
    return updated;
  }

  void _ensureUnique(User user, List<User> users, {String? excludingId}) {
    if (users.any(
      (item) =>
          item.id != excludingId &&
          item.email.toLowerCase() == user.email.toLowerCase(),
    )) {
      throw ConflictException('Email ${user.email} is already in use.');
    }
  }
}
