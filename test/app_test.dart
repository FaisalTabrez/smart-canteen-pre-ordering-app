import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen/main.dart';
import 'package:smart_canteen/models.dart';
import 'package:smart_canteen/store.dart';
import 'controller_test.dart' show MemoryStore;

void main() {
  testWidgets(
    'phone: search, add, validate, checkout and track through collection',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = CanteenController(MemoryStore());
      await tester.pumpWidget(CanteenApp(controller: controller));
      await tester.enterText(find.byType(TextField).first, 'Masala Dosa');
      await tester.pumpAndSettle();
      final add = find.widgetWithText(OutlinedButton, '+  Add');
      await tester.scrollUntilVisible(
        add,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(controller.total, 60);
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      final place = find.textContaining('Place demo order');
      await tester.scrollUntilVisible(
        place,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(place);
      await tester.pumpAndSettle();
      expect(controller.orders, isEmpty);
      final name = find.byType(TextFormField).first;
      await tester.ensureVisible(name);
      await tester.enterText(name, 'Faisal');
      tester.testTextInput.hide();
      await tester.scrollUntilVisible(
        place,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(place);
      await tester.pumpAndSettle();
      expect(controller.orders, hasLength(1));
      expect(controller.count, 0);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      final advance = find.text('Advance demo status');
      await tester.scrollUntilVisible(
        advance,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(advance);
      await tester.pumpAndSettle();
      expect(controller.orders.single.status, OrderStatus.preparing);
      await tester.tap(advance);
      await tester.pumpAndSettle();
      expect(controller.orders.single.status, OrderStatus.ready);
      await tester.tap(find.text('Mark as collected'));
      await tester.pumpAndSettle();
      expect(controller.orders.single.status, OrderStatus.collected);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [360.0, 768.0, 1440.0]) {
    testWidgets('menu and empty screens fit a $width pixel viewport', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        CanteenApp(controller: CanteenController(MemoryStore())),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (width < 950) {
        await tester.tap(find.byType(NavigationDestination).at(1));
        await tester.pumpAndSettle();
        expect(find.text('Your next meal starts here'), findsOneWidget);
        await tester.tap(find.byType(NavigationDestination).at(2));
        await tester.pumpAndSettle();
        expect(find.text('No orders. Yet.'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
