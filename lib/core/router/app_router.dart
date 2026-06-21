import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/residents/presentation/pages/residents_page.dart';
import '../../features/visitors/presentation/pages/visitors_page.dart';
import '../../features/visits/presentation/pages/check_in_page.dart';
import '../../features/visits/presentation/pages/active_visitors_page.dart';
import '../../features/visits/presentation/pages/visitor_history_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/audit/presentation/pages/audit_logs_page.dart';
import '../../shared/presentation/widgets/desktop_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          DesktopShell(currentLocation: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
        GoRoute(path: '/residents', builder: (_, _) => const ResidentsPage()),
        GoRoute(path: '/visitors', builder: (_, _) => const VisitorsPage()),
        GoRoute(path: '/check-in', builder: (_, _) => const CheckInPage()),
        GoRoute(
          path: '/active-visitors',
          builder: (_, _) => const ActiveVisitorsPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const VisitorHistoryPage(),
        ),
        GoRoute(path: '/reports', builder: (_, _) => const ReportsPage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/users', builder: (_, _) => const UsersPage()),
        GoRoute(path: '/audit-logs', builder: (_, _) => const AuditLogsPage()),
      ],
    ),
  ],
);
