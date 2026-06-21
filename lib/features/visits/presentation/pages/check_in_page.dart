import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/session/active_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/models.dart';
import '../../../../repositories/contracts/visit_repository.dart';
import '../../../residents/presentation/controllers/residents_controller.dart';
import '../../../visitors/presentation/controllers/visitors_controller.dart';
import '../../../visitors/presentation/pages/visitors_page.dart';
import '../controllers/visits_controller.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  final _residentSearch = TextEditingController();
  final _visitorSearch = TextEditingController();
  final _purpose = TextEditingController();
  final _notes = TextEditingController();
  String? _selectedResidentId;
  String? _selectedVisitorId;
  String? _selectedBadgeId;
  var _residentQuery = '';
  var _visitorQuery = '';
  var _submitting = false;
  String? _error;

  @override
  void dispose() {
    _residentSearch.dispose();
    _visitorSearch.dispose();
    _purpose.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final residentsValue = ref.watch(residentsControllerProvider);
    final visitorsValue = ref.watch(visitorsControllerProvider);
    final visitsValue = ref.watch(visitsControllerProvider);
    final badgesValue = ref.watch(availableBadgesProvider);
    final activeVisitorIds = (visitsValue.value ?? const <Visit>[])
        .where((visit) => visit.isActive)
        .map((visit) => visit.visitorId)
        .toSet();

    final residents = (residentsValue.value ?? const <Resident>[])
        .where((resident) => resident.isActive)
        .where(_matchesResident)
        .toList();
    final visitors = (visitorsValue.value ?? const <Visitor>[])
        .where(_matchesVisitor)
        .toList();

    return SingleChildScrollView(
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
                      'Visitor Check-In',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Select a resident and visitor, then assign an available badge.',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                key: const Key('inline-register-visitor'),
                onPressed: _registerVisitorInline,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Register New Visitor'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProgressHeader(
            residentComplete: _selectedResidentId != null,
            visitorComplete: _selectedVisitorId != null,
            detailsComplete:
                _purpose.text.trim().isNotEmpty && _selectedBadgeId != null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SelectionPanel(
                  number: '1',
                  title: 'Select Resident',
                  searchController: _residentSearch,
                  searchHint: 'Name, student ID, room, or block',
                  onSearch: (value) => setState(() => _residentQuery = value),
                  loading: residentsValue.isLoading,
                  emptyMessage: 'No active residents found.',
                  children: [
                    for (final resident in residents)
                      _SelectionTile(
                        selected: resident.id == _selectedResidentId,
                        icon: Icons.apartment_rounded,
                        title: resident.fullName,
                        subtitle:
                            '${resident.studentId}  ·  Block ${resident.block}, Room ${resident.roomNumber}',
                        onTap: () =>
                            setState(() => _selectedResidentId = resident.id),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _SelectionPanel(
                  number: '2',
                  title: 'Select Visitor',
                  searchController: _visitorSearch,
                  searchHint: 'Name, phone, Ghana Card, or student reference',
                  onSearch: (value) => setState(() => _visitorQuery = value),
                  loading: visitorsValue.isLoading,
                  emptyMessage: 'No visitors found.',
                  children: [
                    for (final visitor in visitors)
                      _SelectionTile(
                        selected: visitor.id == _selectedVisitorId,
                        disabled: activeVisitorIds.contains(visitor.id),
                        icon: Icons.person_rounded,
                        title: visitor.fullName,
                        subtitle: activeVisitorIds.contains(visitor.id)
                            ? 'Currently checked in'
                            : '${visitor.phoneNumber}  ·  ${_idTypeLabel(visitor.idType)}',
                        onTap: () =>
                            setState(() => _selectedVisitorId = visitor.id),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _StepNumber(value: '3'),
                      const SizedBox(width: 10),
                      Text(
                        'Visit Details & Badge',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      badgesValue.when(
                        data: (badges) =>
                            _AvailabilityLabel(count: badges.length),
                        loading: () => const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, _) => const Text('Badges unavailable'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          key: const Key('visit-purpose'),
                          controller: _purpose,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Purpose of visit *',
                            hintText:
                                'e.g. Family visit, group study, delivery',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: badgesValue.when(
                          data: (badges) => DropdownButtonFormField<String>(
                            key: const Key('badge-selector'),
                            isExpanded: true,
                            initialValue: _selectedBadgeId,
                            decoration: const InputDecoration(
                              labelText: 'Visitor badge *',
                              prefixIcon: Icon(Icons.badge_outlined, size: 19),
                            ),
                            items: badges
                                .map(
                                  (badge) => DropdownMenuItem(
                                    value: badge.id,
                                    child: Text(badge.badgeNumber),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedBadgeId = value),
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, _) => OutlinedButton.icon(
                            onPressed: () =>
                                ref.invalidate(availableBadgesProvider),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry badges'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _notes,
                          minLines: 1,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (_error != null)
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      const SizedBox(width: 14),
                      FilledButton.icon(
                        key: const Key('complete-check-in'),
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded, size: 19),
                        label: const Text('Complete Check-In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesResident(Resident resident) {
    final term = _residentQuery.trim().toLowerCase();
    if (term.isEmpty) return true;
    return resident.fullName.toLowerCase().contains(term) ||
        resident.studentId.toLowerCase().contains(term) ||
        resident.roomNumber.toLowerCase().contains(term) ||
        resident.block.toLowerCase().contains(term);
  }

  bool _matchesVisitor(Visitor visitor) {
    final term = _visitorQuery.trim().toLowerCase();
    if (term.isEmpty) return true;
    return visitor.fullName.toLowerCase().contains(term) ||
        visitor.phoneNumber.toLowerCase().contains(term) ||
        visitor.idNumber.toLowerCase().contains(term);
  }

  Future<void> _registerVisitorInline() async {
    final visitor = await showDialog<Visitor>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VisitorFormDialog(),
    );
    if (visitor == null || !mounted) return;

    _visitorSearch.clear();
    setState(() {
      _visitorQuery = '';
      _selectedVisitorId = visitor.id;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final residentId = _selectedResidentId;
    final visitorId = _selectedVisitorId;
    final badgeId = _selectedBadgeId;
    if (residentId == null) {
      return _setError('Select the resident being visited.');
    }
    if (visitorId == null) {
      return _setError('Select a visitor.');
    }
    if (_purpose.text.trim().isEmpty) {
      return _setError('Enter the purpose of this visit.');
    }
    if (badgeId == null) {
      return _setError('Assign an available visitor badge.');
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final role = ref.read(activeRoleProvider);
      final visit = await ref
          .read(visitsControllerProvider.notifier)
          .checkIn(
            CheckInCommand(
              visitorId: visitorId,
              residentId: residentId,
              purpose: _purpose.text.trim(),
              badgeId: badgeId,
              receptionistId: role == UserRole.administrator
                  ? 'user-admin-001'
                  : 'user-reception-001',
              checkInAt: DateTime.now(),
              notes: _optional(_notes.text),
            ),
          );
      if (!mounted) return;
      final residents = ref.read(residentsControllerProvider).value ?? [];
      final visitors = ref.read(visitorsControllerProvider).value ?? [];
      final resident = residents.firstWhere((item) => item.id == residentId);
      final visitor = visitors.firstWhere((item) => item.id == visitorId);
      await _showSuccess(visit, resident, visitor);
      if (!mounted) return;
      _purpose.clear();
      _notes.clear();
      setState(() {
        _selectedResidentId = null;
        _selectedVisitorId = null;
        _selectedBadgeId = null;
        _submitting = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = switch (error) {
          RepositoryException(:final message) => message,
          _ => 'Unable to complete check-in. Please try again.',
        };
      });
    }
  }

  void _setError(String message) => setState(() => _error = message);

  Future<void> _showSuccess(Visit visit, Resident resident, Visitor visitor) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 48,
        ),
        title: const Text('Visitor checked in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              visitor.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Visiting ${resident.fullName} · ${resident.roomLabel}'),
            const SizedBox(height: 4),
            Text(
              'Badge ${visit.badgeNumber} · ${_formatTime(visit.checkInAt)}',
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.residentComplete,
    required this.visitorComplete,
    required this.detailsComplete,
  });

  final bool residentComplete;
  final bool visitorComplete;
  final bool detailsComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProgressItem(
          number: '1',
          label: 'Resident',
          complete: residentComplete,
        ),
        const Expanded(child: Divider(indent: 12, endIndent: 12)),
        _ProgressItem(number: '2', label: 'Visitor', complete: visitorComplete),
        const Expanded(child: Divider(indent: 12, endIndent: 12)),
        _ProgressItem(
          number: '3',
          label: 'Details & Badge',
          complete: detailsComplete,
        ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.number,
    required this.label,
    required this.complete,
  });

  final String number;
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: complete ? AppColors.success : AppColors.primary,
          child: complete
              ? const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 16,
                )
              : Text(
                  number,
                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel({
    required this.number,
    required this.title,
    required this.searchController,
    required this.searchHint,
    required this.onSearch,
    required this.loading,
    required this.emptyMessage,
    required this.children,
  });

  final String number;
  final String title;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearch;
  final bool loading;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 260,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _StepNumber(value: number),
                  const SizedBox(width: 10),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : children.isEmpty
                    ? Center(child: Text(emptyMessage))
                    : ListView.separated(
                        itemCount: children.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, index) => children[index],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
  });

  final bool selected;
  final bool disabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.lavender : AppColors.canvas,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                disabled ? Icons.lock_clock_rounded : icon,
                color: disabled ? AppColors.muted : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: disabled ? AppColors.muted : AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primary,
      child: Text(
        value,
        style: const TextStyle(color: AppColors.white, fontSize: 12),
      ),
    );
  }
}

class _AvailabilityLabel extends StatelessWidget {
  const _AvailabilityLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count badges available',
        style: const TextStyle(
          color: AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _idTypeLabel(VisitorIdType type) => switch (type) {
  VisitorIdType.ghanaCard => 'Ghana Card Number',
  VisitorIdType.studentReferenceNumber => 'Student Reference Number',
};

String _formatTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}
