import '../../core/services/local_json_store.dart';
import '../../models/hostel_settings.dart';
import '../contracts/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._store);

  final LocalJsonStore _store;

  @override
  Future<HostelSettings> load() async {
    final json = await _store.readObject('settings.json');
    return json == null
        ? HostelSettings.defaults()
        : HostelSettings.fromJson(json);
  }

  @override
  Future<HostelSettings> save(HostelSettings settings) async {
    await _store.writeObject('settings.json', settings.toJson());
    return settings;
  }
}
