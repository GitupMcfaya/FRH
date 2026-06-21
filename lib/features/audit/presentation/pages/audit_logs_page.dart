import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/audit_controller.dart';

class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(auditControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Logs', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 5),
          const Text(
            'Review sensitive administrative and visitor-processing actions.',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 440,
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search user, action, entity, or description',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logs.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Card(child: Center(child: Text('$error'))),
              data: (items) {
                final term = _query.trim().toLowerCase();
                final filtered = items.where((log) {
                  return term.isEmpty ||
                      log.userName.toLowerCase().contains(term) ||
                      log.action.name.toLowerCase().contains(term) ||
                      log.entityType.name.toLowerCase().contains(term) ||
                      log.description.toLowerCase().contains(term);
                }).toList();
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: filtered.isEmpty
                      ? const Center(child: Text('No audit records found.'))
                      : SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                AppColors.lavender,
                              ),
                              columns: const [
                                DataColumn(label: Text('DATE & TIME')),
                                DataColumn(label: Text('USER')),
                                DataColumn(label: Text('ACTION')),
                                DataColumn(label: Text('ENTITY')),
                                DataColumn(label: Text('DESCRIPTION')),
                              ],
                              rows: [
                                for (final log in filtered)
                                  DataRow(
                                    cells: [
                                      DataCell(
                                        Text(_formatDateTime(log.timestamp)),
                                      ),
                                      DataCell(Text(log.userName)),
                                      DataCell(Text(_label(log.action.name))),
                                      DataCell(
                                        Text(_label(log.entityType.name)),
                                      ),
                                      DataCell(Text(log.description)),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _label(String value) => value
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .trim()
    .split(' ')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

String _formatDateTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $hour:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
}
