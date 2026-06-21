import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/active_role_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/model_enums.dart';

class DesktopShell extends ConsumerWidget {
  const DesktopShell({
    required this.currentLocation,
    required this.child,
    super.key,
  });

  final String currentLocation;
  final Widget child;

  static const _destinations = <_NavItem>[
    _NavItem('/dashboard', 'Dashboard', Icons.grid_view_rounded),
    _NavItem('/residents', 'Residents', Icons.apartment_rounded),
    _NavItem('/visitors', 'Visitors', Icons.people_alt_rounded),
    _NavItem('/check-in', 'Check In', Icons.login_rounded),
    _NavItem('/active-visitors', 'Active Visitors', Icons.badge_rounded),
    _NavItem('/history', 'Visit History', Icons.history_rounded),
    _NavItem('/reports', 'Reports', Icons.bar_chart_rounded, adminOnly: true),
    _NavItem(
      '/users',
      'User Management',
      Icons.manage_accounts_rounded,
      adminOnly: true,
    ),
    _NavItem(
      '/audit-logs',
      'Audit Logs',
      Icons.policy_rounded,
      adminOnly: true,
    ),
    _NavItem('/settings', 'Settings', Icons.settings_rounded, adminOnly: true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(activeRoleProvider);

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else if (currentLocation != '/dashboard') {
        context.go('/dashboard');
      }
    }

    void navigateTo(String path) {
      if (path != currentLocation) {
        context.push(path);
      }
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): goBack,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              _Sidebar(
                currentLocation: currentLocation,
                role: role,
                onSelected: navigateTo,
              ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      currentLocation: currentLocation,
                      role: role,
                      canGoBack:
                          context.canPop() || currentLocation != '/dashboard',
                      onBack: goBack,
                      onRoleChanged: (selectedRole) {
                        ref
                            .read(activeRoleProvider.notifier)
                            .select(selectedRole);
                        if (!canAccessPath(selectedRole, currentLocation)) {
                          context.go('/dashboard');
                        }
                      },
                    ),
                    Expanded(
                      child: canAccessPath(role, currentLocation)
                          ? child
                          : const _AccessDeniedPage(),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentLocation,
    required this.role,
    required this.onSelected,
  });

  final String currentLocation;
  final UserRole role;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = DesktopShell._destinations
        .where((item) => !item.adminOnly || role == UserRole.administrator)
        .toList();

    return Container(
      width: 248,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _BrandMark(),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UniHostel',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'VISITOR MANAGEMENT',
                        style: TextStyle(
                          color: Color(0xFFC4B5FD),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = destinations[index];
                final selected = currentLocation == item.path;
                return Material(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onSelected(item.path),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? AppColors.white
                                : const Color(0xFFD8CCF5),
                            size: 20,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.white
                                    : const Color(0xFFE9E1FA),
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFF6B46A8)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  role.initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.displayName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      role.label,
                      style: const TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFFC4B5FD),
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.domain_rounded,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentLocation,
    required this.role,
    required this.canGoBack,
    required this.onBack,
    required this.onRoleChanged,
  });

  final String currentLocation;
  final UserRole role;
  final bool canGoBack;
  final VoidCallback onBack;
  final ValueChanged<UserRole> onRoleChanged;

  String get _pageTitle {
    return switch (currentLocation) {
      '/residents' => 'Residents',
      '/visitors' => 'Visitors',
      '/check-in' => 'Check In',
      '/active-visitors' => 'Active Visitors',
      '/history' => 'Visit History',
      '/reports' => 'Reports',
      '/users' => 'User Management',
      '/audit-logs' => 'Audit Logs',
      '/settings' => 'Settings',
      _ => 'Dashboard',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            IconButton(
              tooltip: 'Back (Alt + Left Arrow)',
              onPressed: canGoBack ? onBack : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 6),
            Text(_pageTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 22),
            const SizedBox(height: 28, child: VerticalDivider(width: 1)),
            const SizedBox(width: 22),
            SizedBox(
              width: constraints.maxWidth < 1200 ? 220 : 300,
              height: 42,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search residents or visitors...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
                onSubmitted: (_) {},
              ),
            ),
            const Spacer(),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lavenderStrong),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  key: const Key('role-switcher'),
                  value: role,
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  items: UserRole.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onRoleChanged(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: const Badge(
                smallSize: 7,
                child: Icon(Icons.notifications_none_rounded),
              ),
            ),
            if (constraints.maxWidth >= 1200) ...[
              const SizedBox(width: 14),
              const Text(
                'Friday, 20 June 2026',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.label, this.icon, {this.adminOnly = false});

  final String path;
  final String label;
  final IconData icon;
  final bool adminOnly;
}

class _AccessDeniedPage extends StatelessWidget {
  const _AccessDeniedPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Access restricted',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Your current role does not have permission to view this section.',
          ),
        ],
      ),
    );
  }
}
