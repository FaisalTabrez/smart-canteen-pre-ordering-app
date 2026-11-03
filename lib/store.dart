import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

abstract class LocalStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesStore implements LocalStore {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'smart_canteen_v1';
  @override
  Future<String?> read() => _preferences.getString(_key);
  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

class CanteenController extends ChangeNotifier {
  CanteenController(this.store);
  final LocalStore store;
  Map<String, int> _cart = {};
  List<CanteenOrder> _orders = [];
  Set<String> _favorites = {};
  String? message;
  bool placing = false;
  Future<void> _pending = Future.value();

  Map<String, int> get cart => Map.unmodifiable(_cart);
  List<CanteenOrder> get orders => List.unmodifiable(_orders);
  bool isFavorite(String id) => _favorites.contains(id);
  int quantity(String id) => _cart[id] ?? 0;
  int get count => _cart.values.fold(0, (a, b) => a + b);
  int get total =>
      menu.fold(0, (sum, item) => sum + item.price * quantity(item.id));
  List<MenuItem> get cartItems =>
      menu.where((item) => quantity(item.id) > 0).toList();

  Future<void> load() async {
    try {
      final raw = await store.read();
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedCart = Map<String, dynamic>.from(data['cart'] as Map);
      final restoredCart = <String, int>{};
      for (final item in menu.where((item) => item.available)) {
        final value = savedCart[item.id];
        if (value is int && value > 0) {
          restoredCart[item.id] = value.clamp(1, 20);
        }
      }
      final restoredOrders = (data['orders'] as List)
          .map(
            (order) =>
                CanteenOrder.fromJson(Map<String, dynamic>.from(order as Map)),
          )
          .toList();
      final restoredFavorites = Set<String>.from(data['favorites'] as List);
      _cart = restoredCart;
      _orders = restoredOrders;
      _favorites = restoredFavorites;
    } catch (_) {
      message =
          'Saved data could not be loaded. You can still use the app; new changes will replace the local save.';
    }
    notifyListeners();
  }

  String _snapshot({Map<String, int>? cart, List<CanteenOrder>? orders}) =>
      jsonEncode({
        'version': 1,
        'cart': cart ?? _cart,
        'orders': (orders ?? _orders).map((order) => order.toJson()).toList(),
        'favorites': _favorites.toList(),
      });

  Future<void> _enqueue(String snapshot) {
    final task = _pending.then((_) => store.write(snapshot));
    _pending = task.catchError((Object _) {});
    return task;
  }

  Future<void> _save() async {
    try {
      await _enqueue(_snapshot());
    } catch (_) {
      message =
          'Could not save on this device. Your current cart is still available; please try again.';
      notifyListeners();
    }
  }

  void dismissMessage() {
    message = null;
    notifyListeners();
  }

  void changeQuantity(MenuItem item, int delta) {
    if (placing || !item.available) return;
    final next = (quantity(item.id) + delta).clamp(0, 20);
    if (next == 0) {
      _cart.remove(item.id);
    } else {
      _cart[item.id] = next;
    }
    notifyListeners();
    _save();
  }

  void toggleFavorite(String id) {
    if (placing) return;
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
    _save();
  }

  void clearCart() {
    if (placing) return;
    _cart.clear();
    notifyListeners();
    _save();
  }

  Future<CanteenOrder> placeOrder({
    required String customer,
    required DateTime pickupAt,
    String note = '',
    DateTime? now,
  }) async {
    if (placing) throw StateError('An order is already being placed.');
    if (_cart.isEmpty) throw StateError('Add something to your cart first.');
    if (customer.trim().length < 2) throw ArgumentError('Enter your name.');
    final placedAt = now ?? DateTime.now();
    if (pickupAt.isBefore(placedAt)) {
      throw ArgumentError('Choose a future pickup time.');
    }
    placing = true;
    notifyListeners();
    try {
      final order = CanteenOrder(
        id: 'SC-${placedAt.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}',
        customer: customer.trim(),
        placedAt: placedAt,
        pickupAt: pickupAt,
        note: note.trim(),
        lines: cartItems
            .map(
              (item) => OrderLine(
                itemId: item.id,
                name: item.name,
                price: item.price,
                quantity: quantity(item.id),
                emoji: item.emoji,
              ),
            )
            .toList(),
      );
      final nextOrders = [order, ..._orders];
      await _enqueue(_snapshot(cart: {}, orders: nextOrders));
      _orders = nextOrders;
      _cart = {};
      return order;
    } finally {
      placing = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    if (placing) return;
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    final current = _orders[index];
    final allowed = switch (current.status) {
      OrderStatus.confirmed => [OrderStatus.preparing, OrderStatus.cancelled],
      OrderStatus.preparing => [OrderStatus.ready],
      OrderStatus.ready => [OrderStatus.collected],
      _ => <OrderStatus>[],
    };
    if (!allowed.contains(status)) return;
    // Serialize status edits with checkout and commit only after saving succeeds.
    placing = true;
    notifyListeners();
    try {
      final next = [..._orders];
      next[index] = current.withStatus(status);
      await _enqueue(_snapshot(orders: next));
      _orders = next;
    } finally {
      placing = false;
      notifyListeners();
    }
  }

  void reorder(CanteenOrder order) {
    if (placing) return;
    for (final line in order.lines) {
      final matches = menu.where(
        (item) => item.id == line.itemId && item.available,
      );
      if (matches.isNotEmpty) {
        _cart[line.itemId] = (quantity(line.itemId) + line.quantity).clamp(
          1,
          20,
        );
      }
    }
    notifyListeners();
    _save();
  }
}
