import '../../core/services/local_json_store.dart';
import '../../models/audit_log.dart';
import '../contracts/audit_repository.dart';

class LocalAuditRepository implements AuditRepository {
  LocalAuditRepository(this._store);

  final LocalJsonStore _store;
  List<AuditLog>? _logs;

  Future<List<AuditLog>> _load() async {
    if (_logs != null) return _logs!;
    final json = await _store.readList('audit_logs.json');
    _logs = json == null
        ? <AuditLog>[]
        : json
              .map((item) => AuditLog.fromJson(item as Map<String, dynamic>))
              .toList();
    return _logs!;
  }

  @override
  Future<List<AuditLog>> getAll() async {
    final logs = [...await _load()]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(logs);
  }

  @override
  Future<AuditLog> append(AuditLog log) async {
    final logs = await _load();
    logs.add(log);
    await _store.writeList(
      'audit_logs.json',
      logs.map((item) => item.toJson()).toList(),
    );
    return log;
  }
}
