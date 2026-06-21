import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/models.dart';
import '../../../residents/presentation/controllers/residents_controller.dart';
import '../../../visitors/presentation/controllers/visitors_controller.dart';
import '../../../visits/presentation/controllers/visits_controller.dart';

enum _ReportType { daily, monthly, resident, frequent }

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  var _reportType = _ReportType.daily;
  var _dailyDate = DateTime.now();
  var _month = DateTime.now().month;
  var _year = DateTime.now().year;
  String? _residentId;
  late DateTimeRange _frequentRange;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _frequentRange = DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitsValue = ref.watch(visitsControllerProvider);
    final residentsValue = ref.watch(residentsControllerProvider);
    final visitorsValue = ref.watch(visitorsControllerProvider);
    final residents = residentsValue.value ?? const <Resident>[];
    final visitors = visitorsValue.value ?? const <Visitor>[];
    final residentMap = {for (final item in residents) item.id: item};
    final visitorMap = {for (final item in visitors) item.id: item};
    final visits = visitsValue.value ?? const <Visit>[];
    final filteredVisits = _filterVisits(visits);
    final reportRows =
        filteredVisits
            .map(
              (visit) => _ReportVisitRow(
                visit: visit,
                visitor: visitorMap[visit.visitorId],
                resident: residentMap[visit.residentId],
              ),
            )
            .toList()
          ..sort((a, b) => b.visit.checkInAt.compareTo(a.visit.checkInAt));

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
                      'Reports',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Review visitor activity, patterns, and resident-level summaries.',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_ReportType>(
              key: const Key('report-type-selector'),
              segments: const [
                ButtonSegment(
                  value: _ReportType.daily,
                  icon: Icon(Icons.today_rounded),
                  label: Text('Daily Report'),
                ),
                ButtonSegment(
                  value: _ReportType.monthly,
                  icon: Icon(Icons.calendar_month_rounded),
                  label: Text('Monthly Report'),
                ),
                ButtonSegment(
                  value: _ReportType.resident,
                  icon: Icon(Icons.apartment_rounded),
                  label: Text('Resident Report'),
                ),
                ButtonSegment(
                  value: _ReportType.frequent,
                  icon: Icon(Icons.workspace_premium_rounded),
                  label: Text('Frequent Visitors'),
                ),
              ],
              selected: {_reportType},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _reportType = selection.first),
            ),
          ),
          const SizedBox(height: 16),
          _ReportFilters(
            reportType: _reportType,
            dailyDate: _dailyDate,
            month: _month,
            year: _year,
            residentId: _residentId,
            residents: residents,
            frequentRange: _frequentRange,
            onDailyDate: _selectDailyDate,
            onMonthChanged: (value) => setState(() => _month = value),
            onYearChanged: (value) => setState(() => _year = value),
            onResidentChanged: (value) => setState(() => _residentId = value),
            onFrequentRange: _selectFrequentRange,
          ),
          const SizedBox(height: 16),
          if (_reportType == _ReportType.frequent)
            _FrequentSummary(visits: filteredVisits)
          else
            _VisitSummary(visits: filteredVisits),
          const SizedBox(height: 16),
          Expanded(
            child: visitsValue.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => _ReportError(
                message: _errorMessage(error),
                onRetry: () =>
                    ref.read(visitsControllerProvider.notifier).refresh(),
              ),
              data: (_) {
                if (_reportType == _ReportType.frequent) {
                  return _FrequentVisitorsTable(
                    visits: filteredVisits,
                    visitorMap: visitorMap,
                  );
                }
                if (_reportType == _ReportType.resident &&
                    _residentId == null) {
                  return const _SelectResidentPrompt();
                }
                return _ReportVisitsTable(rows: reportRows);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Visit> _filterVisits(List<Visit> visits) {
    return visits.where((visit) {
      return switch (_reportType) {
        _ReportType.daily => _isSameDay(visit.checkInAt, _dailyDate),
        _ReportType.monthly =>
          visit.checkInAt.month == _month && visit.checkInAt.year == _year,
        _ReportType.resident =>
          _residentId != null && visit.residentId == _residentId,
        _ReportType.frequent =>
          !DateUtils.dateOnly(
                visit.checkInAt,
              ).isBefore(DateUtils.dateOnly(_frequentRange.start)) &&
              !DateUtils.dateOnly(
                visit.checkInAt,
              ).isAfter(DateUtils.dateOnly(_frequentRange.end)),
      };
    }).toList();
  }

  Future<void> _selectDailyDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dailyDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      helpText: 'Select report date',
    );
    if (selected != null) setState(() => _dailyDate = selected);
  }

  Future<void> _selectFrequentRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _frequentRange,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      helpText: 'Frequent visitor period',
    );
    if (selected != null) setState(() => _frequentRange = selected);
  }

  static String _errorMessage(Object error) => switch (error) {
    RepositoryException(:final message) => message,
    _ => 'Unable to load report data. Please try again.',
  };
}

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.reportType,
    required this.dailyDate,
    required this.month,
    required this.year,
    required this.residentId,
    required this.residents,
    required this.frequentRange,
    required this.onDailyDate,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onResidentChanged,
    required this.onFrequentRange,
  });

  final _ReportType reportType;
  final DateTime dailyDate;
  final int month;
  final int year;
  final String? residentId;
  final List<Resident> residents;
  final DateTimeRange frequentRange;
  final VoidCallback onDailyDate;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String?> onResidentChanged;
  final VoidCallback onFrequentRange;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Report filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 24),
            if (reportType == _ReportType.daily)
              OutlinedButton.icon(
                key: const Key('daily-report-date'),
                onPressed: onDailyDate,
                icon: const Icon(Icons.today_rounded, size: 18),
                label: Text(_formatDate(dailyDate)),
              ),
            if (reportType == _ReportType.monthly) ...[
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: month,
                  decoration: const InputDecoration(labelText: 'Month'),
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(_monthNames[index]),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) onMonthChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<int>(
                  initialValue: year,
                  decoration: const InputDecoration(labelText: 'Year'),
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                      value: DateTime.now().year - index,
                      child: Text('${DateTime.now().year - index}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) onYearChanged(value);
                  },
                ),
              ),
            ],
            if (reportType == _ReportType.resident)
              SizedBox(
                width: 430,
                child: DropdownButtonFormField<String>(
                  key: const Key('resident-report-selector'),
                  isExpanded: true,
                  initialValue: residentId,
                  decoration: const InputDecoration(
                    labelText: 'Select resident',
                    prefixIcon: Icon(Icons.search_rounded, size: 19),
                  ),
                  items: residents
                      .map(
                        (resident) => DropdownMenuItem(
                          value: resident.id,
                          child: Text(
                            '${resident.fullName} · ${resident.studentId} · ${resident.block}-${resident.roomNumber}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onResidentChanged,
                ),
              ),
            if (reportType == _ReportType.frequent)
              OutlinedButton.icon(
                key: const Key('frequent-report-range'),
                onPressed: onFrequentRange,
                icon: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(
                  '${_formatDate(frequentRange.start)} – ${_formatDate(frequentRange.end)}',
                ),
              ),
            const Spacer(),
            Text(_reportDescription(reportType)),
          ],
        ),
      ),
    );
  }
}

class _VisitSummary extends StatelessWidget {
  const _VisitSummary({required this.visits});

  final List<Visit> visits;

  @override
  Widget build(BuildContext context) {
    final completed = visits
        .where((visit) => visit.checkOutAt != null)
        .toList();
    final uniqueVisitors = visits
        .map((visit) => visit.visitorId)
        .toSet()
        .length;
    final averageMinutes = completed.isEmpty
        ? 0
        : completed
                  .map((visit) => visit.durationAt(visit.checkOutAt!).inMinutes)
                  .reduce((a, b) => a + b) ~/
              completed.length;
    return Row(
      children: [
        _MetricCard(
          label: 'Total Visits',
          value: '${visits.length}',
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Unique Visitors',
          value: '$uniqueVisitors',
          icon: Icons.person_search_rounded,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Completed',
          value: '${completed.length}',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Average Duration',
          value: _formatDuration(Duration(minutes: averageMinutes)),
          icon: Icons.timer_outlined,
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _FrequentSummary extends StatelessWidget {
  const _FrequentSummary({required this.visits});

  final List<Visit> visits;

  @override
  Widget build(BuildContext context) {
    final counts = _visitorCounts(visits);
    final repeatVisitors = counts.values.where((count) => count > 1).length;
    final topCount = counts.values.fold<int>(0, mathMax);
    return Row(
      children: [
        _MetricCard(
          label: 'Visitors in Period',
          value: '${counts.length}',
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Repeat Visitors',
          value: '$repeatVisitors',
          icon: Icons.repeat_rounded,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Highest Frequency',
          value: '$topCount visits',
          icon: Icons.workspace_premium_rounded,
          color: AppColors.warning,
        ),
        const SizedBox(width: 14),
        _MetricCard(
          label: 'Total Visits',
          value: '${visits.length}',
          icon: Icons.bar_chart_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportVisitsTable extends StatelessWidget {
  const _ReportVisitsTable({required this.rows});

  final List<_ReportVisitRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: rows.isEmpty
          ? const _EmptyReport(
              message: 'No visits found for this report period.',
            )
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
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('VISITOR')),
                          DataColumn(label: Text('RESIDENT')),
                          DataColumn(label: Text('ROOM')),
                          DataColumn(label: Text('PURPOSE')),
                          DataColumn(label: Text('BADGE')),
                          DataColumn(label: Text('DURATION')),
                          DataColumn(label: Text('STATUS')),
                        ],
                        rows: [
                          for (final row in rows)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(_formatDateTime(row.visit.checkInAt)),
                                ),
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
                                  Text(row.resident?.fullName ?? 'Unknown'),
                                ),
                                DataCell(
                                  Text(
                                    row.resident == null
                                        ? '—'
                                        : '${row.resident!.block}-${row.resident!.roomNumber}',
                                  ),
                                ),
                                DataCell(Text(row.visit.purpose)),
                                DataCell(Text(row.visit.badgeNumber)),
                                DataCell(
                                  Text(
                                    _formatDuration(
                                      row.visit.durationAt(
                                        row.visit.checkOutAt ?? DateTime.now(),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(_statusLabel(row.visit.status))),
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

class _FrequentVisitorsTable extends StatelessWidget {
  const _FrequentVisitorsTable({
    required this.visits,
    required this.visitorMap,
  });

  final List<Visit> visits;
  final Map<String, Visitor> visitorMap;

  @override
  Widget build(BuildContext context) {
    final counts = _visitorCounts(visits);
    final rankings = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: rankings.isEmpty
          ? const _EmptyReport(message: 'No visitor activity in this period.')
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.lavender,
                    ),
                    horizontalMargin: 22,
                    columns: const [
                      DataColumn(label: Text('RANK')),
                      DataColumn(label: Text('VISITOR')),
                      DataColumn(label: Text('PHONE')),
                      DataColumn(label: Text('REFERENCE NUMBER')),
                      DataColumn(label: Text('VISITS'), numeric: true),
                      DataColumn(label: Text('LAST VISIT')),
                    ],
                    rows: [
                      for (var index = 0; index < rankings.length; index++)
                        DataRow(
                          cells: [
                            DataCell(_RankBadge(rank: index + 1)),
                            DataCell(
                              Text(
                                visitorMap[rankings[index].key]?.fullName ??
                                    'Unknown visitor',
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                visitorMap[rankings[index].key]?.phoneNumber ??
                                    '—',
                              ),
                            ),
                            DataCell(
                              Text(
                                visitorMap[rankings[index].key]?.idNumber ??
                                    '—',
                              ),
                            ),
                            DataCell(
                              Text(
                                '${rankings[index].value}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatDate(
                                  visits
                                      .where(
                                        (visit) =>
                                            visit.visitorId ==
                                            rankings[index].key,
                                      )
                                      .map((visit) => visit.checkInAt)
                                      .reduce(
                                        (first, second) => first.isAfter(second)
                                            ? first
                                            : second,
                                      ),
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
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: rank <= 3 ? AppColors.primary : AppColors.lavender,
      child: Text(
        '$rank',
        style: TextStyle(
          color: rank <= 3 ? AppColors.white : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectResidentPrompt extends StatelessWidget {
  const _SelectResidentPrompt();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_rounded, color: AppColors.primary, size: 46),
            SizedBox(height: 12),
            Text('Select a resident to generate their visitor report.'),
          ],
        ),
      ),
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.analytics_outlined,
            color: AppColors.primary,
            size: 46,
          ),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.message, required this.onRetry});

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

class _ReportVisitRow {
  const _ReportVisitRow({
    required this.visit,
    required this.visitor,
    required this.resident,
  });

  final Visit visit;
  final Visitor? visitor;
  final Resident? resident;
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

Map<String, int> _visitorCounts(List<Visit> visits) {
  final counts = <String, int>{};
  for (final visit in visits) {
    counts.update(visit.visitorId, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

int mathMax(int first, int second) => first > second ? first : second;

String _reportDescription(_ReportType type) => switch (type) {
  _ReportType.daily => 'Activity for a specific day',
  _ReportType.monthly => 'Monthly visitor activity',
  _ReportType.resident => 'Visits received by one resident',
  _ReportType.frequent => 'Visitors ranked by frequency',
};

String _statusLabel(VisitStatus status) => switch (status) {
  VisitStatus.checkedIn => 'Active',
  VisitStatus.checkedOut => 'Completed',
  VisitStatus.cancelled => 'Cancelled',
};

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

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
