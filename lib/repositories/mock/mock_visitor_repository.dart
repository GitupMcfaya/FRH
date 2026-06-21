import '../../core/errors/repository_exception.dart';
import '../../models/visitor.dart';
import '../contracts/visitor_repository.dart';
import 'mock_data.dart';

class MockVisitorRepository implements VisitorRepository {
  MockVisitorRepository({this.latency = const Duration(milliseconds: 180)})
    : _visitors = MockData.visitors(DateTime.now());

  final Duration latency;
  final List<Visitor> _visitors;
  var _nextId = 100;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<Visitor>> getAll() async {
    await _wait();
    final result = [..._visitors]
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(result);
  }

  @override
  Future<Visitor?> getById(String id) async {
    await _wait();
    return _visitors.where((visitor) => visitor.id == id).firstOrNull;
  }

  @override
  Future<List<Visitor>> search(String query) async {
    await _wait();
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return getAll();

    final result = _visitors.where((visitor) {
      return visitor.fullName.toLowerCase().contains(term) ||
          visitor.phoneNumber.toLowerCase().contains(term) ||
          visitor.idNumber.toLowerCase().contains(term);
    }).toList()..sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(result);
  }

  @override
  Future<Visitor> create(Visitor visitor) async {
    await _wait();
    _ensureUnique(visitor);
    final created = visitor.id.trim().isEmpty
        ? visitor.copyWith(id: 'visitor-${_nextId++}')
        : visitor;
    _visitors.add(created);
    return created;
  }

  @override
  Future<Visitor> update(Visitor visitor) async {
    await _wait();
    final index = _visitors.indexWhere((item) => item.id == visitor.id);
    if (index == -1) {
      throw RecordNotFoundException('Visitor ${visitor.id} was not found.');
    }
    _ensureUnique(visitor, excludingId: visitor.id);
    _visitors[index] = visitor;
    return visitor;
  }

  @override
  Future<void> delete(String id) async {
    await _wait();
    final index = _visitors.indexWhere((visitor) => visitor.id == id);
    if (index == -1) {
      throw RecordNotFoundException('Visitor $id was not found.');
    }
    _visitors.removeAt(index);
  }

  void _ensureUnique(Visitor visitor, {String? excludingId}) {
    final duplicate = _visitors.any(
      (item) =>
          item.id != excludingId &&
          item.idType == visitor.idType &&
          item.idNumber.toLowerCase() == visitor.idNumber.toLowerCase(),
    );
    if (duplicate) {
      throw ConflictException(
        'A visitor with ID number ${visitor.idNumber} already exists.',
      );
    }
  }
}
