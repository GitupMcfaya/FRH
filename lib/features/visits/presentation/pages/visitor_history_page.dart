import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/models.dart';
import '../../../residents/presentation/controllers/residents_controller.dart';
import '../../../visitors/presentation/controllers/visitors_controller.dart';
import '../controllers/visits_controller.dart';

enum _HistoryStatusFilter { all, completed, cancelled }

class VisitorHistoryPage extends ConsumerStatefulWidget {
  const VisitorHistoryPage({super.key});

  @override
  ConsumerState<VisitorHistoryPage> createState() => _VisitorHistoryPageState();
}

class _VisitorHistoryPageState extends ConsumerState<VisitorHistoryPage> {
  final _searchController = TextEditingController();
  var _query = '';
  var _statusFilter = _HistoryStatusFilter.all;
  DateTimeRange? _dateRange;
  var _sortColumnIndex = 4;
  var _sortAscending = false;
  var _page = 0;
  var _rowsPerPage = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitsValue = ref.watch(visitsControllerProvider);
    final residentsValue = ref.watch(residentsControllerProvider);
    final visitorsValue = ref.watch(visitorsControllerProvider);
    final residents = {
      for (final resident in residentsValue.value ?? const <Resident>[])
        resident.id: resident,
    };
    final visitors = {
      for (final visitor in visitorsValue.value ?? const <Visitor>[])
        visitor.id: visitor,
    };
    final allHistory = (visitsValue.value ?? const <Visit>[])
        .where((visit) => !visit.isActive)
        .map(
          (visit) => _HistoryRow(
            visit: visit,
            visitor: visitors[visit.visitorId],
            resident: residents[visit.residentId],
          ),
        )
        .toList();
    final filtered = allHistory.where(_matchesFilters).toList()
      ..sort(_compareRows);
    final pageCount = math.max(1, (filtered.length / _rowsPerPage).ceil());
    final currentPage = math.min(_page, pageCount - 1);
    final start = currentPage * _rowsPerPage;
    final pageRows = filtered.skip(start).take(_rowsPerPage).toList();

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
                      'Visitor History',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Search, filter, and review completed hostel visits.',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HistorySummary(rows: allHistory),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('history-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value;
                    _page = 0;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Visitor, resident, student ID, room, or badge',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _page = 0;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 210,
                height: 48,
                child: OutlinedButton.icon(
                  key: const Key('history-date-filter'),
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range_rounded, size: 19),
                  label: Text(
                    _dateRange == null
                        ? 'Any date'
                        : '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<_HistoryStatusFilter>(
                  isExpanded: true,
                  initialValue: _statusFilter,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.filter_list_rounded, size: 19),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: _HistoryStatusFilter.all,
                      child: Text('All statuses'),
                    ),
                    DropdownMenuItem(
                      value: _HistoryStatusFilter.completed,
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: _HistoryStatusFilter.cancelled,
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _statusFilter = value;
                        _page = 0;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (_hasFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visitsValue.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => _HistoryError(
                message: _errorMessage(error),
                onRetry: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
              ),
              data: (_) => _HistoryTable(
                rows: pageRows,
                totalRows: filtered.length,
                page: currentPage,
                pageCount: pageCount,
                rowsPerPage: _rowsPerPage,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                onSort: _sort,
                onRowsPerPageChanged: (value) => setState(() {
                  _rowsPerPage = value;
                  _page = 0;
                }),
                onPrevious: currentPage == 0
                    ? null
                    : () => setState(() => _page = currentPage - 1),
                onNext: currentPage >= pageCount - 1
                    ? null
                    : () => setState(() => _page = currentPage + 1),
                onView: _showDetails,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _dateRange != null ||
      _statusFilter != _HistoryStatusFilter.all;

  bool _matchesFilters(_HistoryRow row) {
    final term = _query.trim().toLowerCase();
    if (term.isNotEmpty) {
      final matches =
          (row.visitor?.fullName.toLowerCase().contains(term) ?? false) ||
          (row.resident?.fullName.toLowerCase().contains(term) ?? false) ||
          (row.resident?.studentId.toLowerCase().contains(term) ?? false) ||
          (row.resident?.roomNumber.toLowerCase().contains(term) ?? false) ||
          row.visit.badgeNumber.toLowerCase().contains(term);
      if (!matches) return false;
    }
    if (_dateRange != null) {
      final date = DateUtils.dateOnly(row.visit.checkInAt);
      if (date.isBefore(DateUtils.dateOnly(_dateRange!.start)) ||
          date.isAfter(DateUtils.dateOnly(_dateRange!.end))) {
        return false;
      }
    }
    return switch (_statusFilter) {
      _HistoryStatusFilter.all => true,
      _HistoryStatusFilter.completed =>
        row.visit.status == VisitStatus.checkedOut,
      _HistoryStatusFilter.cancelled =>
        row.visit.status == VisitStatus.cancelled,
    };
  }

  int _compareRows(_HistoryRow first, _HistoryRow second) {
    final comparison = switch (_sortColumnIndex) {
      0 => (first.visitor?.fullName ?? '').compareTo(
        second.visitor?.fullName ?? '',
      ),
      1 => (first.resident?.fullName ?? '').compareTo(
        second.resident?.fullName ?? '',
      ),
      4 => first.visit.checkInAt.compareTo(second.visit.checkInAt),
      5 => (first.visit.checkOutAt ?? first.visit.checkInAt).compareTo(
        second.visit.checkOutAt ?? second.visit.checkInAt,
      ),
      6 =>
        first.visit
            .durationAt(first.visit.checkOutAt ?? DateTime.now())
            .compareTo(
              second.visit.durationAt(
                second.visit.checkOutAt ?? DateTime.now(),
              ),
            ),
      _ => first.visit.checkInAt.compareTo(second.visit.checkInAt),
    };
    return _sortAscending ? comparison : -comparison;
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _page = 0;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Filter visit history',
    );
    if (selected != null) {
      setState(() {
        _dateRange = selected;
        _page = 0;
      });
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _dateRange = null;
      _statusFilter = _HistoryStatusFilter.all;
      _page = 0;
    });
  }

  void _showDetails(_HistoryRow row) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visit History Details'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Visitor', row.visitor?.fullName ?? 'Unknown visitor'),
              _DetailRow('Phone', row.visitor?.phoneNumber ?? '—'),
              _DetailRow(
                'Resident',
                row.resident?.fullName ?? 'Unknown resident',
              ),
              _DetailRow('Student ID', row.resident?.studentId ?? '—'),
              _DetailRow('Room', row.resident?.roomLabel ?? '—'),
              _DetailRow('Purpose', row.visit.purpose),
              _DetailRow('Badge', row.visit.badgeNumber),
              _DetailRow('Checked in', _formatDateTime(row.visit.checkInAt)),
              _DetailRow(
                'Checked out',
                row.visit.checkOutAt == null
                    ? '—'
                    : _formatDateTime(row.visit.checkOutAt!),
              ),
              _DetailRow(
                'Duration',
                _formatDuration(
                  row.visit.durationAt(row.visit.checkOutAt ?? DateTime.now()),
                ),
              ),
              _DetailRow('Status', _statusLabel(row.visit.status)),
              if (row.visit.notes != null)
                _DetailRow('Notes', row.visit.notes!),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String _errorMessage(Object error) => switch (error) {
    RepositoryException(:final message) => message,
    _ => 'Unable to load visit history. Please try again.',
  };
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.rows});

  final List<_HistoryRow> rows;

  @override
  Widget build(BuildContext context) {
    final uniqueVisitors = rows
        .map((row) => row.visit.visitorId)
        .toSet()
        .length;
    final completed = rows
        .where((row) => row.visit.status == VisitStatus.checkedOut)
        .toList();
    final averageMinutes = completed.isEmpty
        ? 0
        : completed
                  .map(
                    (row) =>
                        row.visit.durationAt(row.visit.checkOutAt!).inMinutes,
                  )
                  .reduce((a, b) => a + b) ~/
              completed.length;
    return Row(
      children: [
        _SummaryChip(Icons.history_rounded, '${rows.length} historical visits'),
        const SizedBox(width: 10),
        _SummaryChip(
          Icons.people_alt_outlined,
          '$uniqueVisitors unique visitors',
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          Icons.timer_outlined,
          'Average ${_formatDuration(Duration(minutes: averageMinutes))}',
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(this.icon, this.label);

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

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({
    required this.rows,
    required this.totalRows,
    required this.page,
    required this.pageCount,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onRowsPerPageChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onView,
  });

  final List<_HistoryRow> rows;
  final int totalRows;
  final int page;
  final int pageCount;
  final int rowsPerPage;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<_HistoryRow> onView;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: rows.isEmpty
                ? const _EmptyHistory()
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
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: sortAscending,
                              horizontalMargin: 20,
                              columnSpacing: 25,
                              columns: [
                                DataColumn(
                                  label: const Text('VISITOR'),
                                  onSort: onSort,
                                ),
                                DataColumn(
                                  label: const Text('RESIDENT'),
                                  onSort: onSort,
                                ),
                                const DataColumn(label: Text('STUDENT / ROOM')),
                                const DataColumn(label: Text('BADGE')),
                                DataColumn(
                                  label: const Text('CHECKED IN'),
                                  onSort: onSort,
                                ),
                                DataColumn(
                                  label: const Text('CHECKED OUT'),
                                  onSort: onSort,
                                ),
                                DataColumn(
                                  label: const Text('DURATION'),
                                  onSort: onSort,
                                ),
                                const DataColumn(label: Text('STATUS')),
                                const DataColumn(label: Text('ACTION')),
                              ],
                              rows: [
                                for (final row in rows)
                                  DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          row.visitor?.fullName ?? 'Unknown',
                                          style: const TextStyle(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          row.resident?.fullName ?? 'Unknown',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          row.resident == null
                                              ? '—'
                                              : '${row.resident!.studentId} · ${row.resident!.block}-${row.resident!.roomNumber}',
                                        ),
                                      ),
                                      DataCell(Text(row.visit.badgeNumber)),
                                      DataCell(
                                        Text(
                                          _formatDateTime(row.visit.checkInAt),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          row.visit.checkOutAt == null
                                              ? '—'
                                              : _formatDateTime(
                                                  row.visit.checkOutAt!,
                                                ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _formatDuration(
                                            row.visit.durationAt(
                                              row.visit.checkOutAt ??
                                                  DateTime.now(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        _StatusBadge(status: row.visit.status),
                                      ),
                                      DataCell(
                                        IconButton(
                                          tooltip: 'View visit details',
                                          onPressed: () => onView(row),
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 19,
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
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Text('$totalRows results'),
                const Spacer(),
                const Text('Rows per page:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  key: const Key('history-page-size'),
                  value: rowsPerPage,
                  items: const [5, 10, 20]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onRowsPerPageChanged(value);
                  },
                ),
                const SizedBox(width: 24),
                Text('Page ${page + 1} of $pageCount'),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == VisitStatus.checkedOut;
    final color = completed ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search_rounded, color: AppColors.primary, size: 46),
          SizedBox(height: 12),
          Text('No visits match the selected filters.'),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

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

class _HistoryRow {
  const _HistoryRow({
    required this.visit,
    required this.visitor,
    required this.resident,
  });

  final Visit visit;
  final Visitor? visitor;
  final Resident? resident;
}

String _statusLabel(VisitStatus status) => switch (status) {
  VisitStatus.checkedIn => 'Active',
  VisitStatus.checkedOut => 'Completed',
  VisitStatus.cancelled => 'Cancelled',
};

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours hr';
  return '$hours hr $minutes min';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)} $hour:$minute $period';
}
