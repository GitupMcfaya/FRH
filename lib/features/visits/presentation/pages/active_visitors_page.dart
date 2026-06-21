import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/session/active_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/models.dart';
import '../../../residents/presentation/controllers/residents_controller.dart';
import '../../../visitors/presentation/controllers/visitors_controller.dart';
import '../controllers/visits_controller.dart';

class ActiveVisitorsPage extends ConsumerStatefulWidget {
  const ActiveVisitorsPage({super.key});

  @override
  ConsumerState<ActiveVisitorsPage> createState() => _ActiveVisitorsPageState();
}

class _ActiveVisitorsPageState extends ConsumerState<ActiveVisitorsPage> {
  final _searchController = TextEditingController();
  Timer? _ticker;
  var _query = '';
  String? _checkingOutVisitId;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitsValue = ref.watch(visitsControllerProvider);
    final residentsValue = ref.watch(residentsControllerProvider);
    final visitorsValue = ref.watch(visitorsControllerProvider);
    final badgesValue = ref.watch(availableBadgesProvider);
    final residents = {
      for (final resident in residentsValue.value ?? const <Resident>[])
        resident.id: resident,
    };
    final visitors = {
      for (final visitor in visitorsValue.value ?? const <Visitor>[])
        visitor.id: visitor,
    };
    final activeRows = (visitsValue.value ?? const <Visit>[])
        .where((visit) => visit.isActive)
        .map(
          (visit) => _ActiveVisitRow(
            visit: visit,
            visitor: visitors[visit.visitorId],
            resident: residents[visit.residentId],
          ),
        )
        .where(_matchesQuery)
        .toList();

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
                      'Active Visitors',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Monitor everyone currently inside and process checkouts.',
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/check-in'),
                icon: const Icon(Icons.login_rounded, size: 19),
                label: const Text('New Check-In'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SummaryRow(
            rows: activeRows,
            availableBadgeCount: badgesValue.value?.length,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 430,
                child: TextField(
                  key: const Key('active-visitor-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search visitor, resident, room, or badge',
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
              const Spacer(),
              Text(
                'Durations update automatically',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Refresh active visitors',
                onPressed: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visitsValue.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => _ActiveVisitorsError(
                message: _errorMessage(error),
                onRetry: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
              ),
              data: (_) => _ActiveVisitorsTable(
                rows: activeRows,
                now: DateTime.now(),
                checkingOutVisitId: _checkingOutVisitId,
                onView: _showDetails,
                onCheckOut: _confirmCheckOut,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesQuery(_ActiveVisitRow row) {
    final term = _query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return (row.visitor?.fullName.toLowerCase().contains(term) ?? false) ||
        (row.resident?.fullName.toLowerCase().contains(term) ?? false) ||
        (row.resident?.roomNumber.toLowerCase().contains(term) ?? false) ||
        row.visit.badgeNumber.toLowerCase().contains(term);
  }

  Future<void> _confirmCheckOut(_ActiveVisitRow row) async {
    final visitorName = row.visitor?.fullName ?? 'This visitor';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.primary,
          size: 42,
        ),
        title: const Text('Check out visitor?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$visitorName will be checked out now.'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Return badge ${row.visit.badgeNumber}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Check-Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _checkingOutVisitId = row.visit.id);
    try {
      final role = ref.read(activeRoleProvider);
      final completed = await ref
          .read(visitsControllerProvider.notifier)
          .checkOut(
            visitId: row.visit.id,
            receptionistId: role == UserRole.administrator
                ? 'user-admin-001'
                : 'user-reception-001',
            checkOutAt: DateTime.now(),
          );
      if (!mounted) return;
      setState(() => _checkingOutVisitId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$visitorName checked out after ${_formatDuration(completed.durationAt(completed.checkOutAt!))}. Badge ${completed.badgeNumber} is available.',
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _checkingOutVisitId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    }
  }

  void _showDetails(_ActiveVisitRow row) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Visit Details'),
        content: SizedBox(
          width: 470,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Visitor', row.visitor?.fullName ?? 'Unknown visitor'),
              _DetailRow('Phone', row.visitor?.phoneNumber ?? '—'),
              _DetailRow(
                'Resident',
                row.resident?.fullName ?? 'Unknown resident',
              ),
              _DetailRow('Room', row.resident?.roomLabel ?? '—'),
              _DetailRow('Purpose', row.visit.purpose),
              _DetailRow('Badge', row.visit.badgeNumber),
              _DetailRow('Checked in', _formatDateTime(row.visit.checkInAt)),
              _DetailRow(
                'Duration',
                _formatDuration(row.visit.durationAt(DateTime.now())),
              ),
              if (row.visit.notes != null)
                _DetailRow('Notes', row.visit.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmCheckOut(row);
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  static String _errorMessage(Object error) => switch (error) {
    RepositoryException(:final message) => message,
    _ => 'Something went wrong. Please try again.',
  };
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.rows, required this.availableBadgeCount});

  final List<_ActiveVisitRow> rows;
  final int? availableBadgeCount;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final averageMinutes = rows.isEmpty
        ? 0
        : rows
                  .map((row) => row.visit.durationAt(now).inMinutes)
                  .reduce((a, b) => a + b) ~/
              rows.length;
    return Row(
      children: [
        _SummaryChip(
          icon: Icons.people_alt_rounded,
          label: '${rows.length} currently inside',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.timer_outlined,
          label:
              'Average ${_formatDuration(Duration(minutes: averageMinutes))}',
          color: AppColors.warning,
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.badge_outlined,
          label: '${availableBadgeCount ?? '—'} badges available',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

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
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ActiveVisitorsTable extends StatelessWidget {
  const _ActiveVisitorsTable({
    required this.rows,
    required this.now,
    required this.checkingOutVisitId,
    required this.onView,
    required this.onCheckOut,
  });

  final List<_ActiveVisitRow> rows;
  final DateTime now;
  final String? checkingOutVisitId;
  final ValueChanged<_ActiveVisitRow> onView;
  final ValueChanged<_ActiveVisitRow> onCheckOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: rows.isEmpty
          ? const _EmptyActiveVisitors()
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
                          DataColumn(label: Text('RESIDENT')),
                          DataColumn(label: Text('ROOM')),
                          DataColumn(label: Text('BADGE')),
                          DataColumn(label: Text('CHECKED IN')),
                          DataColumn(label: Text('DURATION')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: [
                          for (final row in rows)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    row.visitor?.fullName ?? 'Unknown visitor',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row.resident?.fullName ??
                                        'Unknown resident',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row.resident == null
                                        ? '—'
                                        : '${row.resident!.block}-${row.resident!.roomNumber}',
                                  ),
                                ),
                                DataCell(
                                  _BadgeLabel(number: row.visit.badgeNumber),
                                ),
                                DataCell(
                                  Text(_formatTime(row.visit.checkInAt)),
                                ),
                                DataCell(
                                  Text(
                                    _formatDuration(row.visit.durationAt(now)),
                                    style: const TextStyle(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => onView(row),
                                        child: const Text('Details'),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        key: ValueKey(
                                          'checkout-${row.visit.id}',
                                        ),
                                        onPressed: checkingOutVisitId == null
                                            ? () => onCheckOut(row)
                                            : null,
                                        icon: checkingOutVisitId == row.visit.id
                                            ? const SizedBox.square(
                                                dimension: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.logout_rounded,
                                                size: 17,
                                              ),
                                        label: const Text('Check Out'),
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

class _BadgeLabel extends StatelessWidget {
  const _BadgeLabel({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        number,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActiveVisitors extends StatelessWidget {
  const _EmptyActiveVisitors();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.how_to_reg_rounded, color: AppColors.success, size: 46),
          SizedBox(height: 12),
          Text('No visitors are currently inside.'),
        ],
      ),
    );
  }
}

class _ActiveVisitorsError extends StatelessWidget {
  const _ActiveVisitorsError({required this.message, required this.onRetry});

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

class _ActiveVisitRow {
  const _ActiveVisitRow({
    required this.visit,
    required this.visitor,
    required this.resident,
  });

  final Visit visit;
  final Visitor? visitor;
  final Resident? resident;
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours hr';
  return '$hours hr $minutes min';
}

String _formatTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year} at ${_formatTime(date)}';
}
