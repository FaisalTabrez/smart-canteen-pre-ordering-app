import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'menu_api.dart';
import 'models.dart';

void main() => runApp(const CanteenApp());

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key, this.loadMenu = fetchMenu});
  final Future<List<Food>> Function() loadMenu;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => Canteen(),
    child: MaterialApp(
      title: 'Smart Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routes: {
        '/': (_) => MenuPage(loadMenu: loadMenu),
        '/cart': (_) => const CartPage(),
        '/orders': (_) => const OrdersPage(),
      },
    ),
  );
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.loadMenu});
  final Future<List<Food>> Function() loadMenu;
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  List<Food> foods = [];
  bool loading = true, sample = false;
  String? error;
  late final animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool useSample = false}) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = useSample
          ? parseMenu(await rootBundle.loadString('assets/menu.json'))
          : await widget.loadMenu();
      if (!mounted) return;
      setState(() {
        foods = result;
        loading = false;
        sample = useSample;
      });
      animation.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load the menu. Check your connection.';
      });
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 900
        ? 3
        : MediaQuery.sizeOf(context).width >= 600
        ? 2
        : 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Canteen'),
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            tooltip: 'Orders',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/orders'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  TextButton(onPressed: load, child: const Text('Retry')),
                  TextButton(
                    onPressed: () => load(useSample: true),
                    child: const Text('Use sample menu'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    sample
                        ? 'Sample menu (offline) • Pay at pickup'
                        : 'Digital menu • Pay at pickup',
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    key: const Key('menu-fade'),
                    opacity: animation,
                    child: SlideTransition(
                      key: const Key('menu-slide'),
                      position: Tween(
                        begin: const Offset(0, .08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: GridView.count(
                        padding: const EdgeInsets.all(12),
                        crossAxisCount: columns,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 205,
                        children: foods.map((food) => FoodCard(food: food)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.food});
  final Food food;
  @override
  Widget build(BuildContext context) => Card(
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Center(child: Image.asset('assets/meal.png', semanticLabel: 'Meal', height: 80)),
                Text('₹${food.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(food.name, style: Theme.of(context).textTheme.titleMedium),
          QuantityButtons(food: food),
        ],
      ),
    ),
  );
}

class QuantityButtons extends StatelessWidget {
  const QuantityButtons({super.key, required this.food});
  final Food food;
  @override
  Widget build(BuildContext context) {
    final canteen = context.watch<Canteen>();
    final quantity = canteen.quantity(food);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Remove ${food.name}',
          icon: const Icon(Icons.remove),
          onPressed: quantity == 0 ? null : () => canteen.change(food, -1),
        ),
        Text('$quantity'),
        IconButton(
          tooltip: 'Add ${food.name}',
          icon: const Icon(Icons.add),
          onPressed: quantity == 20 ? null : () => canteen.change(food, 1),
        ),
      ],
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final form = GlobalKey<FormState>();
  String name = '';
  int minutes = 15;

  @override
  Widget build(BuildContext context) {
    final canteen = context.watch<Canteen>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: canteen.cart.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final item in canteen.cart)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(child: Text('${item.food.name}\n₹${item.food.price} each')),
                              QuantityButtons(food: item.food),
                            ],
                          ),
                        ),
                      ),
                    Text('Total: ₹${canteen.total}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Pickup name'),
                            maxLength: 40,
                            onSaved: (value) => name = value!.trim(),
                            validator: (value) => (value?.trim().length ?? 0) < 2
                                ? 'Enter at least 2 characters'
                                : null,
                          ),
                          DropdownButtonFormField<int>(
                            initialValue: minutes,
                            decoration: const InputDecoration(labelText: 'Pickup time'),
                            items: [15, 30, 45, 60]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text('In $value minutes'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => minutes = value!),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              if (!form.currentState!.validate()) return;
                              form.currentState!.save();
                              canteen.placeOrder(name, minutes);
                              Navigator.pushReplacementNamed(context, '/orders');
                            },
                            child: const Text('Place order'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Demo only. Pay at pickup. Orders reset when the app restarts.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final canteen = context.watch<Canteen>();
    return Scaffold(
      appBar: AppBar(title: const Text('Order status')),
      body: canteen.orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Demo: use the button to simulate kitchen updates.'),
                for (final order in canteen.orders)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.number} • ${order.name}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(order.items.join('\n')),
                          Text('Total: ₹${order.total} • Pay at pickup'),
                          Text('Pickup: ${TimeOfDay.fromDateTime(order.pickup).format(context)}'),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              Order.stages[order.stage],
                              key: ValueKey(order.stage),
                              style: const TextStyle(fontSize: 20, color: Colors.teal),
                            ),
                          ),
                          if (order.stage < Order.stages.length - 1)
                            TextButton(
                              onPressed: () => canteen.advance(order),
                              child: const Text('Demo: next status'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
