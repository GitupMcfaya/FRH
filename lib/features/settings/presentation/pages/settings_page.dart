import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ghana_validators.dart';
import '../../../../models/models.dart';
import '../../../visits/presentation/controllers/visits_controller.dart';
import '../controllers/settings_controller.dart';

enum _SettingsSection { hostel, badges }

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _section = _SettingsSection.hostel;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 5),
          const Text(
            'Configure hostel operations and visitor badge inventory.',
          ),
          const SizedBox(height: 20),
          SegmentedButton<_SettingsSection>(
            segments: const [
              ButtonSegment(
                value: _SettingsSection.hostel,
                icon: Icon(Icons.apartment_rounded),
                label: Text('Hostel Preferences'),
              ),
              ButtonSegment(
                value: _SettingsSection.badges,
                icon: Icon(Icons.badge_rounded),
                label: Text('Visitor Badges'),
              ),
            ],
            selected: {_section},
            onSelectionChanged: (value) =>
                setState(() => _section = value.first),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _section == _SettingsSection.hostel
                ? settings.when(
                    data: (value) => _HostelSettingsForm(
                      key: ValueKey(value.toJson().toString()),
                      settings: value,
                      onSave: (updated) => ref
                          .read(settingsControllerProvider.notifier)
                          .save(updated),
                    ),
                    loading: () => const Card(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => _SettingsError(message: '$error'),
                  )
                : const _BadgeSettings(),
          ),
        ],
      ),
    );
  }
}

class _HostelSettingsForm extends StatefulWidget {
  const _HostelSettingsForm({
    required this.settings,
    required this.onSave,
    super.key,
  });

  final HostelSettings settings;
  final Future<HostelSettings> Function(HostelSettings) onSave;

  @override
  State<_HostelSettingsForm> createState() => _HostelSettingsFormState();
}

class _HostelSettingsFormState extends State<_HostelSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hostel;
  late final TextEditingController _university;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late int _startHour;
  late int _endHour;
  late int _maximumMinutes;
  late bool _requireBadge;
  late bool _allowWeekends;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final value = widget.settings;
    _hostel = TextEditingController(text: value.hostelName);
    _university = TextEditingController(text: value.universityName);
    _phone = TextEditingController(text: value.contactPhone);
    _email = TextEditingController(text: value.contactEmail);
    _startHour = value.visitStartHour;
    _endHour = value.visitEndHour;
    _maximumMinutes = value.maximumVisitMinutes;
    _requireBadge = value.requireVisitorBadge;
    _allowWeekends = value.allowWeekendVisits;
  }

  @override
  void dispose() {
    _hostel.dispose();
    _university.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hostel Identity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _FormRow(
                children: [
                  TextFormField(
                    controller: _hostel,
                    decoration: const InputDecoration(labelText: 'Hostel name'),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _university,
                    decoration: const InputDecoration(
                      labelText: 'University name',
                    ),
                    validator: _required,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FormRow(
                children: [
                  TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact phone',
                    ),
                    validator: _required,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: 'Contact email',
                    ),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter a valid email',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Visiting Rules',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _FormRow(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _startHour,
                    decoration: const InputDecoration(
                      labelText: 'Visiting starts',
                    ),
                    items: List.generate(
                      24,
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text(_formatHour(hour)),
                      ),
                    ),
                    onChanged: (value) => setState(() => _startHour = value!),
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: _endHour,
                    decoration: const InputDecoration(
                      labelText: 'Visiting ends',
                    ),
                    items: List.generate(
                      24,
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text(_formatHour(hour)),
                      ),
                    ),
                    onChanged: (value) => setState(() => _endHour = value!),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 350,
                child: DropdownButtonFormField<int>(
                  initialValue: _maximumMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Maximum visit duration',
                  ),
                  items: const [60, 120, 180, 240, 360]
                      .map(
                        (minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text('${minutes ~/ 60} hours'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _maximumMinutes = value!),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _requireBadge,
                onChanged: (value) => setState(() => _requireBadge = value),
                title: const Text('Require a visitor badge for every check-in'),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: _allowWeekends,
                onChanged: (value) => setState(() => _allowWeekends = value),
                title: const Text('Allow visitor check-ins on weekends'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: const Key('save-hostel-settings'),
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(_saving ? 'Saving...' : 'Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endHour <= _startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visiting end time must be after start time.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    await widget.onSave(
      HostelSettings(
        hostelName: _hostel.text.trim(),
        universityName: _university.text.trim(),
        contactPhone: _phone.text.trim(),
        contactEmail: _email.text.trim(),
        visitStartHour: _startHour,
        visitEndHour: _endHour,
        maximumVisitMinutes: _maximumMinutes,
        requireVisitorBadge: _requireBadge,
        allowWeekendVisits: _allowWeekends,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved locally.')));
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _BadgeSettings extends ConsumerWidget {
  const _BadgeSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgesProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text(
                  'Visitor Badge Inventory',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  key: const Key('add-badge-button'),
                  onPressed: () => _addBadge(context, ref),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Badge'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: badges.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) => SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.lavender,
                    ),
                    columns: const [
                      DataColumn(label: Text('BADGE NUMBER')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ASSIGNED VISIT')),
                      DataColumn(label: Text('CREATED')),
                      DataColumn(label: Text('AVAILABLE FOR USE')),
                    ],
                    rows: [
                      for (final badge in items)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                badge.badgeNumber,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            DataCell(Text(_badgeStatus(badge.status))),
                            DataCell(Text(badge.assignedVisitId ?? '—')),
                            DataCell(Text(_formatDate(badge.createdAt))),
                            DataCell(
                              Switch(
                                value:
                                    badge.status !=
                                    VisitorBadgeStatus.unavailable,
                                onChanged:
                                    badge.status == VisitorBadgeStatus.assigned
                                    ? null
                                    : (available) => _setBadgeAvailability(
                                        context,
                                        ref,
                                        badge,
                                        available,
                                      ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addBadge(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Visitor Badge'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Badge number',
            hintText: 'V-011',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Add Badge'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    if (!GhanaValidators.isBadgeNumber(value)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Use badge format V-001.')),
        );
      }
      return;
    }
    try {
      await ref.read(visitsControllerProvider.notifier).createBadge(value);
    } on RepositoryException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _setBadgeAvailability(
    BuildContext context,
    WidgetRef ref,
    VisitorBadge badge,
    bool available,
  ) async {
    try {
      await ref
          .read(visitsControllerProvider.notifier)
          .setBadgeUnavailable(badge.id, !available);
    } on RepositoryException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children.first),
        const SizedBox(width: 14),
        Expanded(child: children.last),
      ],
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(child: Center(child: Text(message)));
  }
}

String _formatHour(int hour) {
  final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$display:00 ${hour >= 12 ? 'PM' : 'AM'}';
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _badgeStatus(VisitorBadgeStatus status) => switch (status) {
  VisitorBadgeStatus.available => 'Available',
  VisitorBadgeStatus.assigned => 'Assigned',
  VisitorBadgeStatus.unavailable => 'Unavailable',
};
