import 'package:flutter/material.dart';
import 'main.dart';
import 'models.dart';

class PageShell extends StatelessWidget {
  const PageShell({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width > 700 ? 32 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = 20});
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE6E9E1)),
    ),
    child: child,
  );
}

class FoodArt extends StatelessWidget {
  const FoodArt({super.key, required this.item, this.size = 110});
  final MenuItem item;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: item.name,
    image: true,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .72,
            height: size * .72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .45),
            ),
          ),
          ExcludeSemantics(
            child: Text(item.emoji, style: TextStyle(fontSize: size * .49)),
          ),
        ],
      ),
    ),
  );
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.name = 'item',
  });
  final int quantity;
  final VoidCallback? onAdd, onRemove;
  final String name;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0E7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Remove one $name',
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
          icon: const Icon(Icons.remove, size: 18, color: forest),
        ),
        Semantics(
          label: '$quantity in cart',
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w800, color: forest),
          ),
        ),
        IconButton(
          tooltip: 'Add one $name',
          visualDensity: VisualDensity.compact,
          onPressed: quantity >= 20 ? null : onAdd,
          icon: const Icon(Icons.add, size: 18, color: forest),
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title, description, action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: const Color(0xFFE8EEDF),
            child: Icon(icon, size: 40, color: forest),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.6),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    ),
  );
}

String timeLabel(BuildContext context, DateTime time) =>
    TimeOfDay.fromDateTime(time).format(context);
String dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

class PriceRow extends StatelessWidget {
  const PriceRow(this.label, this.value, {super.key, this.bold = false});
  final String label, value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? ink : muted,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 20 : 14,
          ),
        ),
      ],
    ),
  );
}

void showFailure(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save this change. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
