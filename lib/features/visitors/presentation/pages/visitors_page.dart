import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ghana_validators.dart';
import '../../../../models/models.dart';
import '../controllers/visitors_controller.dart';

class VisitorsPage extends ConsumerStatefulWidget {
  const VisitorsPage({super.key});

  @override
  ConsumerState<VisitorsPage> createState() => _VisitorsPageState();
}

class _VisitorsPageState extends ConsumerState<VisitorsPage> {
  final _searchController = TextEditingController();
  var _query = '';
  VisitorIdType? _idTypeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitors = ref.watch(visitorsControllerProvider);

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
                      'Visitors',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Register visitors and maintain verified identity records.',
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                key: const Key('add-visitor-button'),
                onPressed: () => _showVisitorForm(),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                label: const Text('Register Visitor'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          visitors.when(
            data: (items) => _VisitorSummary(visitors: items),
            loading: () => const SizedBox(height: 58),
            error: (_, _) => const SizedBox(height: 58),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 430,
                child: TextField(
                  key: const Key('visitor-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search name, phone number, or identity number',
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
                width: 225,
                child: DropdownButtonFormField<VisitorIdType?>(
                  isExpanded: true,
                  initialValue: _idTypeFilter,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined, size: 19),
                  ),
                  items: [
                    const DropdownMenuItem<VisitorIdType?>(
                      value: null,
                      child: Text('All ID types'),
                    ),
                    ...VisitorIdType.values.map(
                      (type) => DropdownMenuItem<VisitorIdType?>(
                        value: type,
                        child: Text(_idTypeLabel(type)),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _idTypeFilter = value),
                ),
              ),
              const Spacer(),
              IconButton.outlined(
                tooltip: 'Refresh visitors',
                onPressed: () =>
                    ref.read(visitorsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visitors.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => _VisitorsError(
                message: _errorMessage(error),
                onRetry: () =>
                    ref.read(visitorsControllerProvider.notifier).refresh(),
              ),
              data: (items) => _VisitorsTable(
                visitors: _filterVisitors(items),
                onEdit: _showVisitorForm,
                onDelete: _confirmDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Visitor> _filterVisitors(List<Visitor> visitors) {
    final term = _query.trim().toLowerCase();
    return visitors.where((visitor) {
      if (_idTypeFilter != null && visitor.idType != _idTypeFilter) {
        return false;
      }
      if (term.isEmpty) return true;
      return visitor.fullName.toLowerCase().contains(term) ||
          visitor.phoneNumber.toLowerCase().contains(term) ||
          visitor.idNumber.toLowerCase().contains(term);
    }).toList();
  }

  Future<void> _showVisitorForm([Visitor? visitor]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VisitorFormDialog(visitor: visitor),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            visitor == null
                ? 'Visitor registered successfully.'
                : 'Visitor updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Visitor visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete visitor?'),
        content: Text(
          '${visitor.fullName} will be permanently removed. Visitors with recorded visits cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(visitorsControllerProvider.notifier).delete(visitor.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Visitor deleted.')));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
      }
    }
  }

  static String _errorMessage(Object error) => switch (error) {
    RepositoryException(:final message) => message,
    _ => 'Something went wrong. Please try again.',
  };
}

class _VisitorSummary extends StatelessWidget {
  const _VisitorSummary({required this.visitors});

  final List<Visitor> visitors;

  @override
  Widget build(BuildContext context) {
    final ghanaCards = visitors
        .where((visitor) => visitor.idType == VisitorIdType.ghanaCard)
        .length;
    final recentlyUpdated = visitors.where((visitor) {
      return DateTime.now().difference(visitor.updatedAt).inDays <= 30;
    }).length;
    return Row(
      children: [
        _SummaryChip(
          icon: Icons.people_alt_rounded,
          label: '${visitors.length} registered visitors',
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.credit_card_rounded,
          label: '$ghanaCards Ghana Cards',
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.update_rounded,
          label: '$recentlyUpdated updated recently',
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

class _VisitorsTable extends StatelessWidget {
  const _VisitorsTable({
    required this.visitors,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Visitor> visitors;
  final ValueChanged<Visitor> onEdit;
  final ValueChanged<Visitor> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: visitors.isEmpty
          ? const _EmptyVisitors()
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
                        columnSpacing: 30,
                        columns: const [
                          DataColumn(label: Text('VISITOR')),
                          DataColumn(label: Text('PHONE')),
                          DataColumn(label: Text('ID TYPE')),
                          DataColumn(label: Text('ID NUMBER')),
                          DataColumn(label: Text('ADDRESS')),
                          DataColumn(label: Text('UPDATED')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: [
                          for (final visitor in visitors)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    visitor.fullName,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(Text(visitor.phoneNumber)),
                                DataCell(_IdTypeBadge(type: visitor.idType)),
                                DataCell(
                                  Text(
                                    visitor.idNumber,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 170,
                                    ),
                                    child: Text(
                                      visitor.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(_formatDate(visitor.updatedAt))),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit ${visitor.fullName}',
                                        onPressed: () => onEdit(visitor),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 19,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete ${visitor.fullName}',
                                        onPressed: () => onDelete(visitor),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
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

class _IdTypeBadge extends StatelessWidget {
  const _IdTypeBadge({required this.type});

  final VisitorIdType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _idTypeLabel(type),
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyVisitors extends StatelessWidget {
  const _EmptyVisitors();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.primary, size: 42),
          SizedBox(height: 12),
          Text('No visitors match your search.'),
        ],
      ),
    );
  }
}

class _VisitorsError extends StatelessWidget {
  const _VisitorsError({required this.message, required this.onRetry});

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

class VisitorFormDialog extends ConsumerStatefulWidget {
  const VisitorFormDialog({this.visitor, super.key});

  final Visitor? visitor;

  @override
  ConsumerState<VisitorFormDialog> createState() => _VisitorFormDialogState();
}

class _VisitorFormDialogState extends ConsumerState<VisitorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _idNumber;
  late final TextEditingController _address;
  late final TextEditingController _notes;
  late VisitorIdType _idType;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitor;
    _fullName = TextEditingController(text: visitor?.fullName);
    _phone = TextEditingController(text: visitor?.phoneNumber);
    _idNumber = TextEditingController(text: visitor?.idNumber);
    _address = TextEditingController(text: visitor?.address);
    _notes = TextEditingController(text: visitor?.notes);
    _idType = visitor?.idType ?? VisitorIdType.ghanaCard;
  }

  @override
  void dispose() {
    for (final controller in [_fullName, _phone, _idNumber, _address, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.visitor != null;
    return AlertDialog(
      title: Text(editing ? 'Edit Visitor' : 'Register Visitor'),
      content: SizedBox(
        width: 700,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FormRow(
                  children: [
                    TextFormField(
                      key: const Key('visitor-full-name'),
                      controller: _fullName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name *',
                      ),
                      validator: _required,
                    ),
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
                        return GhanaValidators.isPhoneNumber(value)
                            ? null
                            : 'Enter a valid Ghana phone number';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormRow(
                  children: [
                    DropdownButtonFormField<VisitorIdType>(
                      isExpanded: true,
                      initialValue: _idType,
                      decoration: const InputDecoration(labelText: 'ID type *'),
                      items: VisitorIdType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(_idTypeLabel(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _idType = value);
                      },
                    ),
                    TextFormField(
                      key: const Key('visitor-id-number'),
                      controller: _idNumber,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'ID number *',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (_idType == VisitorIdType.ghanaCard &&
                            !GhanaValidators.isGhanaCardNumber(value)) {
                          return 'Use format GHA-000000000-0';
                        }
                        if (value.trim().length < 5) {
                          return 'ID number is too short';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Address *'),
                  validator: _required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
          key: const Key('save-visitor-button'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(editing ? 'Save Changes' : 'Register Visitor'),
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
    final existing = widget.visitor;
    final visitor = Visitor(
      id: existing?.id ?? '',
      fullName: _fullName.text.trim(),
      phoneNumber: _phone.text.trim(),
      idType: _idType,
      idNumber: _idNumber.text.trim().toUpperCase(),
      address: _address.text.trim(),
      notes: _optional(_notes.text),
      photoPath: existing?.photoPath,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final controller = ref.read(visitorsControllerProvider.notifier);
      if (existing == null) {
        await controller.create(visitor);
      } else {
        await controller.updateVisitor(visitor);
      }
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (error) {
          RepositoryException(:final message) => message,
          _ => 'Unable to save this visitor. Please try again.',
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

String _idTypeLabel(VisitorIdType type) => switch (type) {
  VisitorIdType.ghanaCard => 'Ghana Card',
  VisitorIdType.passport => 'Passport',
  VisitorIdType.driversLicense => "Driver's License",
  VisitorIdType.voterId => 'Voter ID',
};

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
