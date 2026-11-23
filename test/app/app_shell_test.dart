import 'package:calendar_notes/app/calendar_notes_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('navigation changes the displayed Polish destination',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CalendarNotesApp()));
    await tester.pumpAndSettle();

    expect(find.text('Kalendarz'), findsWidgets);
    await tester.tap(find.text('Wpisy').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Lista i edycja wpisów zostaną zaimplementowane w CN-06.'),
      findsOneWidget,
    );
  });

  testWidgets('wide window uses a navigation rail', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: CalendarNotesApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
