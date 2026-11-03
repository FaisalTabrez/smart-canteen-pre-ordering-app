import 'package:flutter/material.dart';
import 'main.dart';
import 'models.dart';
import 'store.dart';
import 'components.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.controller, required this.onCart});
  final CanteenController controller;
  final VoidCallback onCart;
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String category = 'All items';
  String query = '';
  bool vegOnly = false, favoritesOnly = false;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final filtered = menu
        .where(
          (item) =>
              (category == 'All items' || item.category == category) &&
              (!vegOnly || item.vegetarian) &&
              (!favoritesOnly || c.isFavorite(item.id)) &&
              '${item.name} ${item.description}'.toLowerCase().contains(
                query.toLowerCase().trim(),
              ),
        )
        .toList();
    return PageShell(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your next good meal.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Tooltip(
              message:
                  'Orders stay on this device. Kitchen updates are simulated.',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8D7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: Color(0xFF85642B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Fresh favourites. Campus prices. Ready when you are.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 650;
            return Container(
              clipBehavior: Clip.antiAlias,
              width: double.infinity,
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  if (wide)
                    Positioned(
                      right: -30,
                      bottom: -60,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: const BoxDecoration(
                          color: Color(0xFF365F48),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🍱', style: TextStyle(fontSize: 140)),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: SizedBox(
                      width: wide
                          ? constraints.maxWidth - 280
                          : double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFFE6CE8A),
                                size: 17,
                              ),
                              SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'LESS QUEUE. MORE YOU.',
                                  style: TextStyle(
                                    color: Color(0xFFE6CE8A),
                                    fontSize: 10,
                                    letterSpacing: 1.7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Good food.\nZero queues.',
                            style: TextStyle(
                              fontSize: wide ? 42 : 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.12,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Pick your favourites, choose a pickup time,\nand leave the waiting to us.',
                            style: TextStyle(
                              color: Color(0xFFD4E3D8),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 15,
                                color: Color(0xFFE6CE8A),
                              ),
                              SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  'Pre-order • Pick up • Enjoy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        TextField(
          controller: search,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'What are you craving?',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      search.clear();
                      setState(() => query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in const [
                ('All items', '🍽️'),
                ('Breakfast', '🌤️'),
                ('Meals', '🍛'),
                ('Snacks', '🥪'),
                ('Drinks', '☕'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: category == entry.$1,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFE1EBDD),
                    label: Text('${entry.$2}  ${entry.$1}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    onSelected: (_) => setState(() => category = entry.$1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('Veg only'),
              avatar: const Icon(Icons.eco_outlined, size: 17),
              selected: vegOnly,
              onSelected: (value) => setState(() => vegOnly = value),
            ),
            FilterChip(
              label: const Text('Favourites'),
              avatar: const Icon(Icons.favorite_border, size: 17),
              selected: favoritesOnly,
              onSelected: (value) => setState(() => favoritesOnly = value),
            ),
            Text(
              '${filtered.length} items',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing on the menu yet?',
            description: 'Try a different search or reset your filters.',
            action: 'Show all items',
            onAction: () {
              search.clear();
              setState(() {
                query = '';
                category = 'All items';
                vegOnly = false;
                favoritesOnly = false;
              });
            },
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 600
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 354,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemBuilder: (context, index) =>
                    MenuCard(item: filtered[index], controller: c),
              );
            },
          ),
        const SizedBox(height: 24),
        if (c.count > 0)
          FilledButton(
            onPressed: widget.onCart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${c.count} ${c.count == 1 ? 'item' : 'items'} in your bag',
                  ),
                ),
                const SizedBox(width: 12),
                Text('View cart  ·  ${money(c.total)}  →'),
              ],
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Demo menu • Prices include all charges • Pickup at the main canteen counter',
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.item, required this.controller});
  final MenuItem item;
  final CanteenController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE4E8DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 145,
            color: item.color,
            child: Stack(
              children: [
                Center(child: FoodArt(item: item, size: 140)),
                if (item.popular)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        '★  CAMPUS FAVOURITE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          color: forest,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    tooltip:
                        '${c.isFavorite(item.id) ? 'Unsave' : 'Save'} ${item.name}',
                    onPressed: c.placing
                        ? null
                        : () => c.toggleFavorite(item.id),
                    icon: Icon(
                      c.isFavorite(item.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: c.isFavorite(item.id) ? orange : ink,
                      size: 21,
                    ),
                  ),
                ),
                if (!item.available)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: .55),
                      alignment: Alignment.center,
                      child: Chip(
                        label: const Text('Sold out today'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        size: 13,
                        color: item.vegetarian
                            ? forest
                            : const Color(0xFFAA4436),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.vegetarian ? 'VEG' : 'NON-VEG',
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: .7,
                          color: muted,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 12, color: muted),
                      const SizedBox(width: 4),
                      Text(
                        '${item.minutes} min',
                        style: const TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        money(item.price),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (c.quantity(item.id) > 0)
                        QuantityControl(
                          quantity: c.quantity(item.id),
                          name: item.name,
                          onAdd: c.placing
                              ? null
                              : () => c.changeQuantity(item, 1),
                          onRemove: c.placing
                              ? null
                              : () => c.changeQuantity(item, -1),
                        )
                      else
                        OutlinedButton(
                          onPressed: !item.available || c.placing
                              ? null
                              : () => c.changeQuantity(item, 1),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(90, 38),
                          ),
                          child: Text(item.available ? '+  Add' : 'Sold out'),
                        ),
                    ],
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

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.controller,
    required this.onMenu,
    required this.onOrdered,
  });
  final CanteenController controller;
  final VoidCallback onMenu, onOrdered;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _note = TextEditingController();
  int pickupMinutes = 15;
  bool attempted = false;
  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> checkout() async {
    setState(() => attempted = true);
    if (!_form.currentState!.validate()) return;
    final c = widget.controller;
    try {
      await c.placeOrder(
        customer: _name.text,
        pickupAt: DateTime.now().add(Duration(minutes: pickupMinutes)),
        note: _note.text,
      );
      if (!mounted) return;
      _note.clear();
      widget.onOrdered();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo order confirmed! Track it in Your orders.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (mounted) showFailure(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return PageShell(
      children: [
        Text(
          'Your bag of happiness.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'A few taps now. A fresh meal later.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        if (c.count == 0)
          EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your next meal starts here',
            description:
                'Your cart is empty. Find something delicious\non the menu and make it yours.',
            action: 'Explore the menu',
            onAction: widget.onMenu,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final items = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your items (${c.count})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: c.placing ? null : c.clearCart,
                          child: const Text('Clear cart'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final item in c.cartItems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FoodArt(item: item, size: 62),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${money(item.price)} each',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 14,
                                    children: [
                                      QuantityControl(
                                        quantity: c.quantity(item.id),
                                        name: item.name,
                                        onAdd: c.placing
                                            ? null
                                            : () => c.changeQuantity(item, 1),
                                        onRemove: c.placing
                                            ? null
                                            : () => c.changeQuantity(item, -1),
                                      ),
                                      Text(
                                        money(item.price * c.quantity(item.id)),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: widget.onMenu,
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Add more good food'),
                    ),
                  ],
                ),
              );
              final checkoutPanel = Panel(
                child: Form(
                  key: _form,
                  autovalidateMode: attempted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make it a pre-order',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        enabled: !c.placing,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          labelText: 'Name for pickup',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 2
                            ? 'Please enter at least 2 characters.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: pickupMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Pickup time',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 15,
                            child: Text('In 15 minutes'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('In 30 minutes'),
                          ),
                          DropdownMenuItem(
                            value: 45,
                            child: Text('In 45 minutes'),
                          ),
                          DropdownMenuItem(value: 60, child: Text('In 1 hour')),
                        ],
                        onChanged: c.placing
                            ? null
                            : (value) => setState(() => pickupMinutes = value!),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _note,
                        enabled: !c.placing,
                        maxLength: 150,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Kitchen note (optional)',
                          hintText: 'E.g. less spicy, please',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      PriceRow('Items subtotal', money(c.total)),
                      const PriceRow('Pickup fee', 'FREE'),
                      const PriceRow('Extra charges', 'None'),
                      const Divider(),
                      PriceRow('Total to pay', money(c.total), bold: true),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 20,
                              color: forest,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pay at pickup\nNo payment is collected in this demo.',
                                style: TextStyle(fontSize: 12, height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: c.placing ? null : checkout,
                          child: c.placing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Place demo order  ·  ${money(c.total)}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Demo orders are saved on this device only. They are not sent to a real canteen.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              if (constraints.maxWidth >= 790) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: items),
                    const SizedBox(width: 24),
                    SizedBox(width: 360, child: checkoutPanel),
                  ],
                );
              }
              return Column(
                children: [items, const SizedBox(height: 22), checkoutPanel],
              );
            },
          ),
      ],
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    required this.controller,
    required this.onMenu,
    required this.onCart,
  });
  final CanteenController controller;
  final VoidCallback onMenu, onCart;

  Future<void> change(
    BuildContext context,
    CanteenOrder order,
    OrderStatus status,
  ) async {
    if (status == OrderStatus.cancelled) {
      final cancel = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel this order?'),
          content: const Text('This demo order will be marked as cancelled.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep order'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel order'),
            ),
          ],
        ),
      );
      if (cancel != true || !context.mounted) return;
    }
    try {
      await controller.updateStatus(order.id, status);
    } catch (_) {
      if (context.mounted) showFailure(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return PageShell(
      children: [
        Text(
          'Good things are cooking.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your orders, from first tap to first bite.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 24),
        if (c.orders.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders. Yet.',
            description:
                'Once you place a pre-order, you can\nfollow its journey right here.',
            action: 'Find your first favourite',
            onAction: onMenu,
          )
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEADB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 20,
                  color: Color(0xFF85642B),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Demo kitchen: use “Advance demo status” to move an order from confirmed → preparing → ready. No real kitchen is connected.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: Color(0xFF715E36),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          for (final order in c.orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ${order.id}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dateLabel(order.placedAt)} · ${timeLabel(context, order.placedAt)} · ${order.customer}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: order.status == OrderStatus.cancelled
                                ? const Color(0xFFF7E3DC)
                                : const Color(0xFFE8F0DF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: order.status == OrderStatus.cancelled
                                  ? const Color(0xFFAA4436)
                                  : forest,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (order.status != OrderStatus.cancelled)
                      OrderTimeline(status: order.status),
                    const SizedBox(height: 20),
                    for (final line in order.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Text(
                              line.emoji,
                              style: const TextStyle(fontSize: 23),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('${line.quantity} × ${line.name}'),
                            ),
                            Text(
                              money(line.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Divider(),
                    PriceRow(
                      order.status == OrderStatus.cancelled
                          ? 'Cancelled total'
                          : 'Pay at pickup',
                      money(order.total),
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          color: forest,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Main Campus Canteen · Pickup counter\nPickup: ${timeLabel(context, order.pickupAt)} · ${dateLabel(order.pickupAt)}\nShow this order number at the counter.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: muted,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (order.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'Kitchen note: ${order.note}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (order.status == OrderStatus.confirmed ||
                            order.status == OrderStatus.preparing)
                          FilledButton.tonalIcon(
                            onPressed: c.placing
                                ? null
                                : () => change(
                                    context,
                                    order,
                                    order.status == OrderStatus.confirmed
                                        ? OrderStatus.preparing
                                        : OrderStatus.ready,
                                  ),
                            icon: const Icon(
                              Icons.fast_forward_rounded,
                              size: 19,
                            ),
                            label: const Text('Advance demo status'),
                          ),
                        if (order.status == OrderStatus.ready)
                          FilledButton.icon(
                            onPressed: c.placing
                                ? null
                                : () => change(
                                    context,
                                    order,
                                    OrderStatus.collected,
                                  ),
                            icon: const Icon(Icons.check_rounded, size: 19),
                            label: const Text('Mark as collected'),
                          ),
                        if (order.status == OrderStatus.confirmed)
                          TextButton(
                            onPressed: c.placing
                                ? null
                                : () => change(
                                    context,
                                    order,
                                    OrderStatus.cancelled,
                                  ),
                            child: const Text('Cancel order'),
                          ),
                        if (!order.active)
                          OutlinedButton.icon(
                            onPressed: c.placing
                                ? null
                                : () {
                                    c.reorder(order);
                                    onCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Available items added at current menu prices.',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.replay, size: 18),
                            label: const Text('Order again'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});
  final OrderStatus status;
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Confirmed', Icons.receipt_long_outlined),
      ('Preparing', Icons.soup_kitchen_outlined),
      ('Ready', Icons.shopping_bag_outlined),
      ('Collected', Icons.check_rounded),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < steps.length; index++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : index <= status.index
                            ? forest
                            : const Color(0xFFE4E8E0),
                      ),
                    ),
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: index <= status.index
                          ? forest
                          : const Color(0xFFEEF0E9),
                      child: Icon(
                        steps[index].$2,
                        size: 18,
                        color: index <= status.index ? Colors.white : muted,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == steps.length - 1
                            ? Colors.transparent
                            : index < status.index
                            ? forest
                            : const Color(0xFFE4E8E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index].$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: index == status.index
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: index <= status.index ? forest : muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
