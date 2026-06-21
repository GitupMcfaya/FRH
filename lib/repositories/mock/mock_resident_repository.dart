import '../../core/errors/repository_exception.dart';
import '../../models/resident.dart';
import '../contracts/resident_repository.dart';
import 'mock_data.dart';

class MockResidentRepository implements ResidentRepository {
  MockResidentRepository({this.latency = const Duration(milliseconds: 180)})
    : _residents = MockData.residents(DateTime.now());

  final Duration latency;
  final List<Resident> _residents;
  var _nextId = 100;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<Resident>> getAll({bool includeInactive = false}) async {
    await _wait();
    final result =
        _residents
            .where((resident) => includeInactive || resident.isActive)
            .toList()
          ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(result);
  }

  @override
  Future<Resident?> getById(String id) async {
    await _wait();
    return _residents.where((resident) => resident.id == id).firstOrNull;
  }

  @override
  Future<List<Resident>> search(
    String query, {
    bool includeInactive = false,
  }) async {
    await _wait();
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return getAll(includeInactive: includeInactive);

    final result = _residents.where((resident) {
      if (!includeInactive && !resident.isActive) return false;
      return resident.fullName.toLowerCase().contains(term) ||
          resident.studentId.toLowerCase().contains(term) ||
          resident.roomNumber.toLowerCase().contains(term) ||
          resident.block.toLowerCase().contains(term);
    }).toList()..sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(result);
  }

  @override
  Future<Resident> create(Resident resident) async {
    await _wait();
    _ensureUnique(resident);
    final created = resident.id.trim().isEmpty
        ? resident.copyWith(id: 'resident-${_nextId++}')
        : resident;
    _residents.add(created);
    return created;
  }

  @override
  Future<Resident> update(Resident resident) async {
    await _wait();
    final index = _residents.indexWhere((item) => item.id == resident.id);
    if (index == -1) {
      throw RecordNotFoundException('Resident ${resident.id} was not found.');
    }
    _ensureUnique(resident, excludingId: resident.id);
    _residents[index] = resident;
    return resident;
  }

  @override
  Future<Resident> deactivate(String id, {required DateTime updatedAt}) async {
    await _wait();
    final index = _residents.indexWhere((resident) => resident.id == id);
    if (index == -1) {
      throw RecordNotFoundException('Resident $id was not found.');
    }
    final deactivated = _residents[index].copyWith(
      isActive: false,
      updatedAt: updatedAt,
    );
    _residents[index] = deactivated;
    return deactivated;
  }

  void _ensureUnique(Resident resident, {String? excludingId}) {
    final duplicate = _residents.any(
      (item) =>
          item.id != excludingId &&
          item.studentId.toLowerCase() == resident.studentId.toLowerCase(),
    );
    if (duplicate) {
      throw ConflictException(
        'Student ID ${resident.studentId} is already registered.',
      );
    }
  }
}
