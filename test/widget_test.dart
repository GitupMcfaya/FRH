import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_visitor_manager/app.dart';

void main() {
  testWidgets('desktop shell shows dashboard and navigates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: HostelVisitorApp()));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Esi'), findsOneWidget);
    expect(find.text('Active Visitors'), findsWidgets);

    await tester.tap(find.text('Check In'));
    await tester.pumpAndSettle();
    expect(find.text('Select Resident'), findsOneWidget);
    expect(find.text('Select Visitor'), findsOneWidget);
    expect(find.byKey(const Key('complete-check-in')), findsOneWidget);

    await tester.tap(find.byKey(const Key('inline-register-visitor')));
    await tester.pumpAndSettle();
    expect(find.text('Register Visitor'), findsWidgets);
    expect(find.byKey(const Key('visitor-full-name')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select Visitor'), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Esi'), findsOneWidget);

    await tester.tap(find.text('Active Visitors').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Monitor everyone currently inside and process checkouts.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('checkout-visit-001')), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visit History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Search, filter, and review completed hostel visits.'),
      findsOneWidget,
    );
    expect(find.text('Page 1 of 3'), findsOneWidget);
    expect(find.byTooltip('Next page'), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Residents'));
    await tester.pumpAndSettle();
    expect(
      find.text('Search residents and view room assignments.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add-resident-button')), findsNothing);

    await tester.tap(find.text('Visitors'));
    await tester.pumpAndSettle();
    expect(
      find.text('Register visitors and maintain verified identity records.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add-visitor-button')), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Search residents and view room assignments.'),
      findsOneWidget,
    );

    expect(find.text('User Management'), findsNothing);
    expect(find.text('Settings'), findsNothing);

    await tester.tap(find.byKey(const Key('role-switcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administrator').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add-resident-button')), findsOneWidget);
    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Audit Logs'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Review visitor activity, patterns, and resident-level summaries.',
      ),
      findsOneWidget,
    );
    expect(find.text('Daily Report'), findsOneWidget);
    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Resident Report'), findsOneWidget);
    expect(find.text('Frequent Visitors'), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('User Management'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Manage staff profiles, roles, and account access.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add-user-button')), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Configure hostel operations and visitor badge inventory.'),
      findsOneWidget,
    );
    expect(find.text('Hostel Preferences'), findsOneWidget);
    expect(find.text('Visitor Badges'), findsOneWidget);

    await tester.tap(find.byTooltip('Back (Alt + Left Arrow)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Audit Logs'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text(
        'Review sensitive administrative and visitor-processing actions.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('role-switcher')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Receptionist').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Good morning, Esi'), findsOneWidget);
    expect(find.text('User Management'), findsNothing);
  });
}
