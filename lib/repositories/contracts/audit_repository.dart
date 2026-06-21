import '../../models/audit_log.dart';

abstract interface class AuditRepository {
  Future<List<AuditLog>> getAll();

  Future<AuditLog> append(AuditLog log);
}
