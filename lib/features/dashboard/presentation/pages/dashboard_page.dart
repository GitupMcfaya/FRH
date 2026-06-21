import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/active_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/visit.dart';
import '../../../../models/model_enums.dart';
import '../../../residents/presentation/controllers/residents_controller.dart';
import '../../../visits/presentation/controllers/visits_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(activeRoleProvider);
    final isAdmin = role == UserRole.administrator;
    final residentCount = ref
        .watch(residentsControllerProvider)
        .value
        ?.where((resident) => resident.isActive)
        .length;
    final now = DateTime.now();
    final visits = ref.watch(visitsControllerProvider).value;
    final activeVisitorCount = visits?.where((visit) => visit.isActive).length;
    final todayVisitCount = visits
        ?.where((visit) => _isSameDay(visit.checkInAt, now))
        .length;
    final todayCheckoutCount = visits
        ?.where(
          (visit) =>
              visit.checkOutAt != null && _isSameDay(visit.checkOutAt!, now),
        )
        .length;
    final monthVisitCount = visits
        ?.where(
          (visit) =>
              visit.checkInAt.year == now.year &&
              visit.checkInAt.month == now.month,
        )
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdmin ? 'Administrator overview' : 'Good morning, Esi',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAdmin
                          ? 'Monitor operations, staff access, and visitor activity.'
                          : "Here's what is happening at the hostel today.",
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    context.push(isAdmin ? '/residents' : '/check-in'),
                icon: Icon(
                  isAdmin ? Icons.apartment_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(isAdmin ? 'Manage Residents' : 'New Check-In'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _StatsGrid(
            role: role,
            residentCount: residentCount,
            activeVisitorCount: activeVisitorCount,
            todayVisitCount: todayVisitCount,
            todayCheckoutCount: todayCheckoutCount,
            monthVisitCount: monthVisitCount,
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: _RecentActivity()),
              const SizedBox(width: 22),
              Expanded(
                flex: 2,
                child: _QuickActions(
                  role: role,
                  activeVisitorCount: activeVisitorCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.role,
    required this.residentCount,
    required this.activeVisitorCount,
    required this.todayVisitCount,
    required this.todayCheckoutCount,
    required this.monthVisitCount,
  });

  final UserRole role;
  final int? residentCount;
  final int? activeVisitorCount;
  final int? todayVisitCount;
  final int? todayCheckoutCount;
  final int? monthVisitCount;

  @override
  Widget build(BuildContext context) {
    final receptionistStats = [
      _StatData(
        'Active Visitors',
        activeVisitorCount?.toString() ?? '—',
        'inside',
        Icons.badge_rounded,
        AppColors.primary,
      ),
      _StatData(
        "Today's Visits",
        todayVisitCount?.toString() ?? '—',
        'today',
        Icons.people_alt_rounded,
        Color(0xFF2563EB),
      ),
      _StatData(
        "Today's Check-Outs",
        todayCheckoutCount?.toString() ?? '—',
        'today',
        Icons.logout_rounded,
        AppColors.success,
      ),
      _StatData(
        'Total Residents',
        residentCount?.toString() ?? '—',
        'active',
        Icons.apartment_rounded,
        AppColors.warning,
      ),
    ];
    final administratorStats = [
      _StatData(
        'Active Visitors',
        activeVisitorCount?.toString() ?? '—',
        'inside',
        Icons.badge_rounded,
        AppColors.primary,
      ),
      _StatData(
        'Total Residents',
        residentCount?.toString() ?? '—',
        'active',
        Icons.apartment_rounded,
        Color(0xFF2563EB),
      ),
      const _StatData(
        'Staff Users',
        '8',
        '7 active',
        Icons.manage_accounts_rounded,
        AppColors.success,
      ),
      _StatData(
        'Visits This Month',
        monthVisitCount?.toString() ?? '—',
        'this month',
        Icons.bar_chart_rounded,
        AppColors.warning,
      ),
    ];
    final stats = role == UserRole.administrator
        ? administratorStats
        : receptionistStats;

    return Row(
      children: [
        for (var index = 0; index < stats.length; index++) ...[
          Expanded(child: _StatCard(data: stats[index])),
          if (index != stats.length - 1) const SizedBox(width: 18),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color, size: 23),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.value,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        data.trend,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const activities = [
    (
      'Kwame Mensah',
      'Checked in to visit Ama Owusu · Room A-204',
      '10:42 AM',
      true,
    ),
    (
      'Nana Yaa Asante',
      'Checked out · Badge V-008 returned',
      '10:18 AM',
      false,
    ),
    (
      'Kofi Boateng',
      'Checked in to visit Samuel Tetteh · Room B-112',
      '9:56 AM',
      true,
    ),
    ('Akosua Frempong', 'Checked out · 1 hr 24 min visit', '9:31 AM', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/history'),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < activities.length; index++) ...[
              _ActivityRow(activity: activities[index]),
              if (index != activities.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final (String, String, String, bool) activity;

  @override
  Widget build(BuildContext context) {
    final (name, detail, time, checkedIn) = activity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: checkedIn
                ? AppColors.lavender
                : const Color(0xFFEAF8F2),
            child: Icon(
              checkedIn ? Icons.login_rounded : Icons.logout_rounded,
              color: checkedIn ? AppColors.primary : AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.role, required this.activeVisitorCount});

  final UserRole role;
  final int? activeVisitorCount;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.administrator;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            _ActionTile(
              icon: isAdmin
                  ? Icons.manage_accounts_rounded
                  : Icons.person_add_alt_1_rounded,
              title: isAdmin ? 'Manage Users' : 'Register Visitor',
              subtitle: isAdmin
                  ? 'Staff accounts and role access'
                  : 'Create a visitor profile',
              onTap: () => context.push(isAdmin ? '/users' : '/visitors'),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: isAdmin ? Icons.bar_chart_rounded : Icons.login_rounded,
              title: isAdmin ? 'View Reports' : 'Check In Visitor',
              subtitle: isAdmin
                  ? 'Review hostel visitor trends'
                  : 'Start a new hostel visit',
              onTap: () => context.push(isAdmin ? '/reports' : '/check-in'),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: isAdmin ? Icons.policy_rounded : Icons.badge_rounded,
              title: isAdmin ? 'Audit Logs' : 'View Active Visitors',
              subtitle: isAdmin
                  ? 'Review sensitive system actions'
                  : '${activeVisitorCount ?? '—'} visitors currently inside',
              onTap: () =>
                  context.push(isAdmin ? '/audit-logs' : '/active-visitors'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lavender,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lavenderStrong),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.trend, this.icon, this.color);

  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
}

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
