import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/session/active_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ghana_validators.dart';
import '../../../../models/models.dart';
import '../controllers/residents_controller.dart';

enum _ResidentFilter { active, inactive, all }

class ResidentsPage extends ConsumerStatefulWidget {
  const ResidentsPage({super.key});

  @override
  ConsumerState<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends ConsumerState<ResidentsPage> {
  final _searchController = TextEditingController();
  var _query = '';
  var _filter = _ResidentFilter.active;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(activeRoleProvider);
    final canManage = role == UserRole.administrator;
    final residents = ref.watch(residentsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Residents',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      canManage
                          ? 'Manage residents and hostel room assignments.'
                          : 'Search residents and view room assignments.',
                    ),
                  ],
                ),
              ),
              if (canManage)
                FilledButton.icon(
                  key: const Key('add-resident-button'),
                  onPressed: () => _showResidentForm(),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                  label: const Text('Add Resident'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          residents.when(
            data: (items) => _SummaryRow(residents: items),
            loading: () => const SizedBox(height: 58),
            error: (_, _) => const SizedBox(height: 58),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 380,
                child: TextField(
                  key: const Key('resident-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search name, student ID, room, or block',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<_ResidentFilter>(
                  isExpanded: true,
                  initialValue: _filter,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.filter_list_rounded, size: 19),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: _ResidentFilter.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: _ResidentFilter.inactive,
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem(
                      value: _ResidentFilter.all,
                      child: Text('All residents'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _filter = value);
                  },
                ),
              ),
              const Spacer(),
              IconButton.outlined(
                tooltip: 'Refresh residents',
                onPressed: () =>
                    ref.read(residentsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: residents.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => _ResidentsError(
                message: _errorMessage(error),
                onRetry: () =>
                    ref.read(residentsControllerProvider.notifier).refresh(),
              ),
              data: (items) {
                final filtered = _filterResidents(items);
                return _ResidentsTable(
                  residents: filtered,
                  canManage: canManage,
                  onEdit: _showResidentForm,
                  onDeactivate: _confirmDeactivate,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Resident> _filterResidents(List<Resident> residents) {
    final term = _query.trim().toLowerCase();
    return residents.where((resident) {
      final matchesStatus = switch (_filter) {
        _ResidentFilter.active => resident.isActive,
        _ResidentFilter.inactive => !resident.isActive,
        _ResidentFilter.all => true,
      };
      if (!matchesStatus) return false;
      if (term.isEmpty) return true;
      return resident.fullName.toLowerCase().contains(term) ||
          resident.studentId.toLowerCase().contains(term) ||
          resident.roomNumber.toLowerCase().contains(term) ||
          resident.block.toLowerCase().contains(term);
    }).toList();
  }

  Future<void> _showResidentForm([Resident? resident]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResidentFormDialog(resident: resident),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resident == null
                ? 'Resident added successfully.'
                : 'Resident updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeactivate(Resident resident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate resident?'),
        content: Text(
          '${resident.fullName} will no longer appear in active resident searches. Their record will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(residentsControllerProvider.notifier)
          .deactivate(resident.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Resident deactivated.')));
      }
    } on Object catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
  }

  static String _errorMessage(Object error) => switch (error) {
    RepositoryException(:final message) => message,
    _ => 'Something went wrong. Please try again.',
  };
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.residents});

  final List<Resident> residents;

  @override
  Widget build(BuildContext context) {
    final active = residents.where((resident) => resident.isActive).length;
    final blocks = residents
        .where((resident) => resident.isActive)
        .map((resident) => resident.block)
        .toSet()
        .length;
    return Row(
      children: [
        _SummaryChip(
          icon: Icons.people_alt_rounded,
          label: '$active active residents',
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.apartment_rounded,
          label: '$blocks occupied blocks',
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.person_off_outlined,
          label: '${residents.length - active} inactive',
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ResidentsTable extends StatelessWidget {
  const _ResidentsTable({
    required this.residents,
    required this.canManage,
    required this.onEdit,
    required this.onDeactivate,
  });

  final List<Resident> residents;
  final bool canManage;
  final ValueChanged<Resident> onEdit;
  final ValueChanged<Resident> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: residents.isEmpty
          ? const _EmptyResidents()
          : LayoutBuilder(
              builder: (context, constraints) => Scrollbar(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.lavender,
                        ),
                        horizontalMargin: 22,
                        columnSpacing: 32,
                        columns: [
                          const DataColumn(label: Text('STUDENT ID')),
                          const DataColumn(label: Text('RESIDENT')),
                          const DataColumn(label: Text('PHONE')),
                          const DataColumn(label: Text('ROOM')),
                          const DataColumn(label: Text('PROGRAMME')),
                          const DataColumn(label: Text('STATUS')),
                          if (canManage)
                            const DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: [
                          for (final resident in residents)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    resident.studentId,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    resident.fullName,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(Text(resident.phoneNumber)),
                                DataCell(
                                  Text(
                                    '${resident.block}-${resident.roomNumber}',
                                  ),
                                ),
                                DataCell(Text(resident.programme ?? '—')),
                                DataCell(
                                  _StatusBadge(isActive: resident.isActive),
                                ),
                                if (canManage)
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Edit ${resident.fullName}',
                                          onPressed: () => onEdit(resident),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 19,
                                          ),
                                        ),
                                        if (resident.isActive)
                                          IconButton(
                                            tooltip:
                                                'Deactivate ${resident.fullName}',
                                            onPressed: () =>
                                                onDeactivate(resident),
                                            icon: const Icon(
                                              Icons.person_off_outlined,
                                              size: 19,
                                              color: AppColors.danger,
                                            ),
                                          ),
                                      ],
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
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyResidents extends StatelessWidget {
  const _EmptyResidents();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.primary, size: 42),
          SizedBox(height: 12),
          Text('No residents match your search.'),
        ],
      ),
    );
  }
}

class _ResidentsError extends StatelessWidget {
  const _ResidentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class ResidentFormDialog extends ConsumerStatefulWidget {
  const ResidentFormDialog({this.resident, super.key});

  final Resident? resident;

  @override
  ConsumerState<ResidentFormDialog> createState() => _ResidentFormDialogState();
}

class _ResidentFormDialogState extends ConsumerState<ResidentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentId;
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _block;
  late final TextEditingController _room;
  late final TextEditingController _programme;
  late final TextEditingController _emergencyContact;
  late Gender _gender;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final resident = widget.resident;
    _studentId = TextEditingController(text: resident?.studentId);
    _fullName = TextEditingController(text: resident?.fullName);
    _phone = TextEditingController(text: resident?.phoneNumber);
    _block = TextEditingController(text: resident?.block);
    _room = TextEditingController(text: resident?.roomNumber);
    _programme = TextEditingController(text: resident?.programme);
    _emergencyContact = TextEditingController(text: resident?.emergencyContact);
    _gender = resident?.gender ?? Gender.female;
  }

  @override
  void dispose() {
    for (final controller in [
      _studentId,
      _fullName,
      _phone,
      _block,
      _room,
      _programme,
      _emergencyContact,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.resident != null;
    return AlertDialog(
      title: Text(editing ? 'Edit Resident' : 'Add Resident'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FormRow(
                  children: [
                    TextFormField(
                      key: const Key('resident-student-id'),
                      controller: _studentId,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Student ID *',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!GhanaValidators.isStudentId(value)) {
                          return 'Enter a valid student ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fullName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name *',
                      ),
                      validator: _required,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormRow(
                  children: [
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number *',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!GhanaValidators.isPhoneNumber(value)) {
                          return 'Enter a valid Ghana phone number';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<Gender>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Gender *'),
                      items: Gender.values
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(_genderLabel(gender)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _gender = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormRow(
                  children: [
                    TextFormField(
                      controller: _block,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Hostel block *',
                      ),
                      validator: _required,
                    ),
                    TextFormField(
                      controller: _room,
                      decoration: const InputDecoration(
                        labelText: 'Room number *',
                      ),
                      validator: _required,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormRow(
                  children: [
                    TextFormField(
                      controller: _programme,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Programme'),
                    ),
                    TextFormField(
                      controller: _emergencyContact,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Emergency contact',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return GhanaValidators.isPhoneNumber(value)
                            ? null
                            : 'Enter a valid Ghana phone number';
                      },
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-resident-button'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(editing ? 'Save Changes' : 'Add Resident'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final now = DateTime.now();
    final existing = widget.resident;
    final resident = Resident(
      id: existing?.id ?? '',
      studentId: _studentId.text.trim().toUpperCase(),
      fullName: _fullName.text.trim(),
      phoneNumber: _phone.text.trim(),
      block: _block.text.trim().toUpperCase(),
      roomNumber: _room.text.trim().toUpperCase(),
      gender: _gender,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      programme: _optional(_programme.text),
      emergencyContact: _optional(_emergencyContact.text),
    );

    try {
      final controller = ref.read(residentsControllerProvider.notifier);
      if (existing == null) {
        await controller.create(resident);
      } else {
        await controller.updateResident(resident);
      }
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (error) {
          RepositoryException(:final message) => message,
          _ => 'Unable to save this resident. Please try again.',
        };
      });
    }
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _genderLabel(Gender gender) => switch (gender) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.other => 'Other',
    Gender.preferNotToSay => 'Prefer not to say',
  };
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
        const SizedBox(width: 16),
        Expanded(child: children.last),
      ],
    );
  }
}
