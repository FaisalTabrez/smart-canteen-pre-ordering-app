import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_canteen/menu_api.dart';
import 'package:smart_canteen/models.dart';

void main() {
  const dosa = Food(1, 'Masala Dosa', 60);
  const tea = Food(2, 'Tea', 20);

  test('cart calculates totals, limits quantities and removes zero items', () {
    final canteen = Canteen();
    canteen.change(dosa, 2);
    canteen.change(tea, 1);
    expect(canteen.total, 140);
    canteen.change(dosa, 100);
    expect(canteen.quantity(dosa), 20);
    canteen.change(dosa, -100);
    expect(canteen.total, 20);
    canteen.change(tea, -1);
    expect(canteen.cart, isEmpty);
  });

  test('checkout takes a snapshot and cannot submit the same cart twice', () {
    final canteen = Canteen()..change(dosa, 2);
    canteen.placeOrder(' Student ', 30);
    final order = canteen.orders.single;
    expect(order.name, 'Student');
    expect(order.total, 120);
    expect(order.items, ['2 x Masala Dosa']);
    expect(order.pickup.difference(DateTime.now()).inMinutes, inInclusiveRange(29, 30));
    expect(canteen.cart, isEmpty);
    expect(() => canteen.placeOrder('Student', 30), throwsStateError);
    canteen.change(dosa, 1);
    expect(order.total, 120);
    expect(order.items, ['2 x Masala Dosa']);
  });

  test('invalid checkout preserves the cart', () {
    final canteen = Canteen()..change(tea, 1);
    expect(() => canteen.placeOrder(' ', 15), throwsStateError);
    expect(() => canteen.placeOrder('Student', 0), throwsStateError);
    expect(canteen.total, 20);
    expect(canteen.orders, isEmpty);
  });

  test('demo status stops at Collected', () {
    final canteen = Canteen()..change(dosa, 1);
    canteen.placeOrder('Student', 15);
    final order = canteen.orders.single;
    for (var i = 0; i < 5; i++) {
      canteen.advance(order);
    }
    expect(Order.stages[order.stage], 'Collected');
  });

  test('REST request parses menu JSON and sends the raw-content header', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), menuUrl);
      expect(request.headers['Accept'], 'application/vnd.github.raw+json');
      return http.Response('[{"id":1,"name":"Dosa","price":60}]', 200);
    });
    expect((await fetchMenu(client: client)).single.name, 'Dosa');
  });

  test('REST errors and malformed menus are rejected', () async {
    await expectLater(
      fetchMenu(client: MockClient((_) async => http.Response('', 503))),
      throwsException,
    );
    for (final json in [
      'broken',
      '[]',
      '[{"id":1,"name":"Tea","price":-1}]',
      '[{"id":1,"name":"Tea","price":20},{"id":1,"name":"Dosa","price":60}]',
    ]) {
      expect(() => parseMenu(json), throwsA(isA<FormatException>()));
    }
  });
}
