import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen/models.dart';
import 'package:smart_canteen/store.dart';

class MemoryStore implements LocalStore {
  String? value;
  bool fail = false;
  Completer<void>? block;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (block != null) await block!.future;
    if (fail) throw StateError('Storage unavailable');
    value = data;
  }
}

void main() {
  late MemoryStore store;
  late CanteenController controller;
  final now = DateTime(2026, 11, 3, 12);
  setUp(() {
    store = MemoryStore();
    controller = CanteenController(store);
  });

  test('cart totals, limits, sold-out guard and removal', () {
    final dosa = menu.first;
    controller.changeQuantity(dosa, 2);
    controller.changeQuantity(menu.firstWhere((item) => item.id == 'chai'), 1);
    expect(controller.total, 140);
    expect(controller.count, 3);
    controller.changeQuantity(dosa, 100);
    expect(controller.quantity(dosa.id), 20);
    controller.changeQuantity(dosa, -100);
    expect(controller.quantity(dosa.id), 0);
    controller.changeQuantity(menu.firstWhere((item) => !item.available), 1);
    expect(controller.count, 1);
  });

  test(
    'checkout snapshots prices, clears cart and restores order and favourites',
    () async {
      controller.changeQuantity(menu.first, 2);
      controller.toggleFavorite('dosa');
      final order = await controller.placeOrder(
        customer: '  Faisal  ',
        pickupAt: now.add(const Duration(minutes: 15)),
        now: now,
        note: ' less spicy ',
      );
      expect(order.total, 120);
      expect(order.customer, 'Faisal');
      expect(order.note, 'less spicy');
      expect(controller.count, 0);
      controller.changeQuantity(menu.first, 1);
      expect(order.lines.single.quantity, 2);
      await Future<void>.delayed(Duration.zero);
      final restored = CanteenController(store);
      await restored.load();
      expect(restored.total, 60);
      expect(restored.orders.single.total, 120);
      expect(restored.isFavorite('dosa'), isTrue);
    },
  );

  test(
    'failed checkout retains the cart and creates no phantom order',
    () async {
      controller.changeQuantity(menu.first, 1);
      store.fail = true;
      await expectLater(
        controller.placeOrder(
          customer: 'Faisal',
          now: now,
          pickupAt: now.add(const Duration(minutes: 15)),
        ),
        throwsStateError,
      );
      expect(controller.total, 60);
      expect(controller.orders, isEmpty);
      expect(controller.placing, isFalse);
    },
  );

  test('rapid duplicate submissions create exactly one order', () async {
    controller.changeQuantity(menu.first, 1);
    await Future<void>.delayed(Duration.zero);
    store.block = Completer<void>();
    final first = controller.placeOrder(
      customer: 'Faisal',
      now: now,
      pickupAt: now.add(const Duration(minutes: 15)),
    );
    await expectLater(
      controller.placeOrder(
        customer: 'Faisal',
        now: now,
        pickupAt: now.add(const Duration(minutes: 15)),
      ),
      throwsStateError,
    );
    store.block!.complete();
    await first;
    expect(controller.orders, hasLength(1));
  });

  test(
    'status transitions cannot skip preparation or reopen collected orders',
    () async {
      controller.changeQuantity(menu.first, 1);
      final order = await controller.placeOrder(
        customer: 'Faisal',
        now: now,
        pickupAt: now.add(const Duration(minutes: 15)),
      );
      await controller.updateStatus(order.id, OrderStatus.ready);
      expect(controller.orders.single.status, OrderStatus.confirmed);
      await controller.updateStatus(order.id, OrderStatus.preparing);
      await controller.updateStatus(order.id, OrderStatus.cancelled);
      expect(controller.orders.single.status, OrderStatus.preparing);
      await controller.updateStatus(order.id, OrderStatus.ready);
      await controller.updateStatus(order.id, OrderStatus.collected);
      await controller.updateStatus(order.id, OrderStatus.confirmed);
      expect(controller.orders.single.status, OrderStatus.collected);
    },
  );

  test('failed status update retains the previous status', () async {
    controller.changeQuantity(menu.first, 1);
    final order = await controller.placeOrder(
      customer: 'Faisal',
      now: now,
      pickupAt: now.add(const Duration(minutes: 15)),
    );
    store.fail = true;
    await expectLater(
      controller.updateStatus(order.id, OrderStatus.preparing),
      throwsStateError,
    );
    expect(controller.orders.single.status, OrderStatus.confirmed);
    expect(controller.placing, isFalse);
  });

  test('invalid checkout cannot commit', () async {
    await expectLater(
      controller.placeOrder(customer: 'Faisal', now: now, pickupAt: now),
      throwsStateError,
    );
    controller.changeQuantity(menu.first, 1);
    await expectLater(
      controller.placeOrder(customer: ' ', now: now, pickupAt: now),
      throwsArgumentError,
    );
    await expectLater(
      controller.placeOrder(
        customer: 'Faisal',
        now: now,
        pickupAt: now.subtract(const Duration(minutes: 1)),
      ),
      throwsArgumentError,
    );
    expect(controller.orders, isEmpty);
  });

  test('malformed save starts safely with a visible explanation', () async {
    store.value = '{broken json';
    await controller.load();
    expect(controller.orders, isEmpty);
    expect(controller.count, 0);
    expect(controller.message, contains('could not be loaded'));
  });

  test('cancelled order restores available items to the cart', () async {
    controller.changeQuantity(menu.first, 2);
    final order = await controller.placeOrder(
      customer: 'Faisal',
      now: now,
      pickupAt: now.add(const Duration(minutes: 15)),
    );
    await controller.updateStatus(order.id, OrderStatus.cancelled);
    controller.reorder(controller.orders.single);
    expect(controller.total, 120);
    expect(controller.orders.single.status, OrderStatus.cancelled);
  });
}
