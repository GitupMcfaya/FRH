import '../../models/visitor.dart';

abstract interface class VisitorRepository {
  Future<List<Visitor>> getAll();

  Future<Visitor?> getById(String id);

  Future<List<Visitor>> search(String query);

  Future<Visitor> create(Visitor visitor);

  Future<Visitor> update(Visitor visitor);

  Future<void> delete(String id);
}
