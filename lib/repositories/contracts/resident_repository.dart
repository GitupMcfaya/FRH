import '../../models/resident.dart';

abstract interface class ResidentRepository {
  Future<List<Resident>> getAll({bool includeInactive = false});

  Future<Resident?> getById(String id);

  Future<List<Resident>> search(String query, {bool includeInactive = false});

  Future<Resident> create(Resident resident);

  Future<Resident> update(Resident resident);

  Future<Resident> deactivate(String id, {required DateTime updatedAt});
}
