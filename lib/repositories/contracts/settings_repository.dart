import '../../models/hostel_settings.dart';

abstract interface class SettingsRepository {
  Future<HostelSettings> load();

  Future<HostelSettings> save(HostelSettings settings);
}
