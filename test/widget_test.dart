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

    await tester.tap(find.text('User Management'));
    await tester.pumpAndSettle();
    expect(
      find.text('Manage staff accounts and role assignments.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('role-switcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receptionist').last);
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Esi'), findsOneWidget);
    expect(find.text('User Management'), findsNothing);
  });
}
