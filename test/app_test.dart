import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen/main.dart';
import 'package:smart_canteen/models.dart';

Future<List<Food>> sampleMenu() async => [const Food(1, 'Masala Dosa', 60)];

void main() {
  for (final width in [360.0, 768.0, 1200.0]) {
    testWidgets('menu, cart, validation and tracking at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(CanteenApp(loadMenu: sampleMenu));
      await tester.pumpAndSettle();
      final grid = tester.widget<GridView>(find.byType(GridView));
      final layout = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(
        layout.crossAxisCount,
        width >= 900
            ? 3
            : width >= 600
            ? 2
            : 1,
      );
      await tester.tap(find.byTooltip('Add Masala Dosa'));
      await tester.tap(find.byTooltip('Cart'));
      await tester.pumpAndSettle();
      expect(find.text('Total: ₹60'), findsOneWidget);
      await tester.tap(find.text('Place order'));
      await tester.pumpAndSettle();
      expect(find.text('Enter at least 2 characters'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Student');
      tester.testTextInput.hide();
      await tester.tap(find.text('In 15 minutes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('In 30 minutes').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Place order'));
      await tester.pumpAndSettle();
      expect(find.text('Order #1 • Student'), findsOneWidget);
      for (final status in ['Preparing', 'Ready', 'Collected']) {
        await tester.tap(find.text('Demo: next status'));
        await tester.pumpAndSettle();
        expect(find.text(status), findsOneWidget);
      }
      expect(find.text('Demo: next status'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cart'));
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('menu fades and slides into view', (tester) async {
    await tester.pumpWidget(CanteenApp(loadMenu: sampleMenu));
    await tester.pump();
    final fade = find.byKey(const Key('menu-fade'));
    final slide = find.byKey(const Key('menu-slide'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.widget<FadeTransition>(fade).opacity.value, closeTo(.5, .05));
    expect(tester.widget<SlideTransition>(slide).position.value.dy, closeTo(.04, .01));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
    expect(tester.widget<SlideTransition>(slide).position.value, Offset.zero);
  });

  testWidgets('API failure shows retry and an explicit offline menu', (tester) async {
    var requests = 0;
    await tester.pumpWidget(
      CanteenApp(
        loadMenu: () async {
          requests++;
          throw Exception('offline');
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not load'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(requests, 2);
    await tester.tap(find.text('Use sample menu'));
    await tester.pumpAndSettle();
    expect(find.text('Sample menu (offline) • Pay at pickup'), findsOneWidget);
    expect(find.text('Masala Dosa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
