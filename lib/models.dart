import 'package:flutter/material.dart';

String money(int rupees) => '\u20b9$rupees';

class MenuItem {
  const MenuItem(
    this.id,
    this.name,
    this.description,
    this.category,
    this.price,
    this.emoji,
    this.color, {
    this.vegetarian = true,
    this.popular = false,
    this.available = true,
    this.minutes = 10,
  });
  final String id, name, description, category, emoji;
  final int price, minutes;
  final Color color;
  final bool vegetarian, popular, available;
}

const menu = <MenuItem>[
  MenuItem(
    'dosa',
    'Masala Dosa',
    'Crisp dosa, potato masala & coconut chutney',
    'Breakfast',
    60,
    '🥞',
    Color(0xFFF5DEC2),
    popular: true,
    minutes: 8,
  ),
  MenuItem(
    'idli',
    'Idli Sambar',
    'Three fluffy idlis, sambar & fresh chutney',
    'Breakfast',
    40,
    '🍚',
    Color(0xFFE2E9D0),
    minutes: 5,
  ),
  MenuItem(
    'poha',
    'Kanda Poha',
    'Light, lemony poha with peanuts & herbs',
    'Breakfast',
    35,
    '🥣',
    Color(0xFFF4E5AD),
    minutes: 5,
  ),
  MenuItem(
    'biryani',
    'Veg Biryani',
    'Fragrant basmati, seasonal vegetables & raita',
    'Meals',
    100,
    '🍛',
    Color(0xFFF0D4BD),
    popular: true,
    minutes: 12,
  ),
  MenuItem(
    'thali',
    'Homestyle Thali',
    'Roti, rice, dal, sabzi & a little something sweet',
    'Meals',
    120,
    '🍱',
    Color(0xFFDCE7D4),
    popular: true,
    minutes: 12,
  ),
  MenuItem(
    'chicken',
    'Chicken Rice Bowl',
    'Spiced chicken, steamed rice & crunchy slaw',
    'Meals',
    140,
    '🍗',
    Color(0xFFF0D4C6),
    vegetarian: false,
    minutes: 15,
  ),
  MenuItem(
    'sandwich',
    'Grilled Sandwich',
    'Toasty bread, vegetables & melted cheese',
    'Snacks',
    55,
    '🥪',
    Color(0xFFE9DDBB),
    popular: true,
    minutes: 8,
  ),
  MenuItem(
    'samosa',
    'Samosa Duo',
    'Two golden samosas with tangy tamarind dip',
    'Snacks',
    30,
    '🥟',
    Color(0xFFF4DEBC),
    minutes: 5,
  ),
  MenuItem(
    'fries',
    'Masala Fries',
    'Crispy fries tossed in our house spice mix',
    'Snacks',
    65,
    '🍟',
    Color(0xFFF3D6C4),
    available: false,
    minutes: 8,
  ),
  MenuItem(
    'chai',
    'Masala Chai',
    'Freshly brewed tea with warming spices',
    'Drinks',
    20,
    '☕',
    Color(0xFFE8D5C2),
    popular: true,
    minutes: 3,
  ),
  MenuItem(
    'lime',
    'Fresh Lime Soda',
    'A fresh squeeze of lime, fizz & a pinch of salt',
    'Drinks',
    35,
    '🍋',
    Color(0xFFE7EABD),
    minutes: 3,
  ),
  MenuItem(
    'coffee',
    'Cold Coffee',
    'Chilled coffee, creamy milk & a frothy finish',
    'Drinks',
    60,
    '🥤',
    Color(0xFFE0D2C7),
    minutes: 5,
  ),
];

enum OrderStatus { confirmed, preparing, ready, collected, cancelled }

extension StatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.confirmed => 'Confirmed',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.ready => 'Ready for pickup',
    OrderStatus.collected => 'Collected',
    OrderStatus.cancelled => 'Cancelled',
  };
}

class OrderLine {
  const OrderLine({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.emoji,
  });
  final String itemId, name, emoji;
  final int price, quantity;
  int get total => price * quantity;
  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'emoji': emoji,
  };
  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    itemId: json['itemId'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    quantity: json['quantity'] as int,
    emoji: json['emoji'] as String,
  );
}

class CanteenOrder {
  CanteenOrder({
    required this.id,
    required this.customer,
    required this.placedAt,
    required this.pickupAt,
    required List<OrderLine> lines,
    this.note = '',
    this.status = OrderStatus.confirmed,
  }) : lines = List.unmodifiable(lines);
  final String id, customer, note;
  final DateTime placedAt, pickupAt;
  final List<OrderLine> lines;
  final OrderStatus status;
  int get total => lines.fold(0, (sum, line) => sum + line.total);
  bool get active =>
      status != OrderStatus.collected && status != OrderStatus.cancelled;
  CanteenOrder withStatus(OrderStatus value) => CanteenOrder(
    id: id,
    customer: customer,
    placedAt: placedAt,
    pickupAt: pickupAt,
    lines: lines,
    note: note,
    status: value,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer,
    'placedAt': placedAt.toIso8601String(),
    'pickupAt': pickupAt.toIso8601String(),
    'lines': lines.map((line) => line.toJson()).toList(),
    'note': note,
    'status': status.name,
  };
  factory CanteenOrder.fromJson(Map<String, dynamic> json) => CanteenOrder(
    id: json['id'] as String,
    customer: json['customer'] as String,
    placedAt: DateTime.parse(json['placedAt'] as String),
    pickupAt: DateTime.parse(json['pickupAt'] as String),
    lines: (json['lines'] as List)
        .map(
          (line) => OrderLine.fromJson(Map<String, dynamic>.from(line as Map)),
        )
        .toList(),
    note: json['note'] as String? ?? '',
    status: OrderStatus.values.byName(json['status'] as String),
  );
}
