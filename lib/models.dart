import 'package:flutter/foundation.dart';

class Food {
  const Food(this.id, this.name, this.price);
  final int id, price;
  final String name;
}

class CartItem {
  CartItem(this.food, this.quantity);
  final Food food;
  int quantity;
}

class Order {
  Order(this.number, this.name, this.pickup, this.items, this.total);
  final int number, total;
  final String name;
  final DateTime pickup;
  final List<String> items;
  int stage = 0;
  static const stages = ['Placed', 'Preparing', 'Ready', 'Collected'];
}

// Provider shares this state between the three screens.
class Canteen extends ChangeNotifier {
  final cart = <CartItem>[];
  final orders = <Order>[];
  int get total => cart.fold(0, (sum, item) => sum + item.food.price * item.quantity);

  int quantity(Food food) {
    for (final item in cart) {
      if (item.food.id == food.id) return item.quantity;
    }
    return 0;
  }

  void change(Food food, int amount) {
    final index = cart.indexWhere((item) => item.food.id == food.id);
    final next = (quantity(food) + amount).clamp(0, 20);
    if (index < 0 && next > 0) {
      cart.add(CartItem(food, next));
    } else if (index >= 0) {
      if (next == 0) {
        cart.removeAt(index);
      } else {
        cart[index].quantity = next;
      }
    }
    notifyListeners();
  }

  void placeOrder(String name, int minutes) {
    if (cart.isEmpty || name.trim().length < 2 || minutes < 15) {
      throw StateError('Check the cart, pickup name and time.');
    }
    orders.insert(
      0,
      Order(
        orders.length + 1,
        name.trim(),
        DateTime.now().add(Duration(minutes: minutes)),
        cart.map((item) => '${item.quantity} x ${item.food.name}').toList(),
        total,
      ),
    );
    cart.clear();
    notifyListeners();
  }

  void advance(Order order) {
    if (orders.contains(order) && order.stage < Order.stages.length - 1) {
      order.stage++;
      notifyListeners();
    }
  }
}
