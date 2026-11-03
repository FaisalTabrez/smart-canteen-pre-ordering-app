import 'package:flutter/material.dart';
import 'store.dart';
import 'screens.dart';

const forest = Color(0xFF214D3D);
const ink = Color(0xFF253C32);
const cream = Color(0xFFF8F7F2);
const muted = Color(0xFF748078);
const orange = Color(0xFFD86636);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = CanteenController(PreferencesStore());
  await controller.load();
  runApp(CanteenApp(controller: controller));
}

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key, required this.controller});
  final CanteenController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart Canteen',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        secondary: orange,
        surface: cream,
      ),
      fontFamily: 'Lato',
      fontFamilyFallback: const ['Noto Color Emoji'],
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E5DD)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
    home: CanteenHome(controller: controller),
  );
}

class CanteenHome extends StatefulWidget {
  const CanteenHome({super.key, required this.controller});
  final CanteenController controller;
  @override
  State<CanteenHome> createState() => _CanteenHomeState();
}

class _CanteenHomeState extends State<CanteenHome> {
  int _selected = 0;
  void select(int index) => setState(() => _selected = index);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final wide = MediaQuery.sizeOf(context).width >= 950;
      final active = c.orders.where((order) => order.active).length;
      final destinations = [
        const NavigationDestination(
          icon: Icon(Icons.restaurant_menu_rounded),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: c.count > 0,
            label: Text('${c.count}'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: active > 0,
            label: Text('$active'),
            child: const Icon(Icons.receipt_long_outlined),
          ),
          label: 'Orders',
        ),
      ];
      return Scaffold(
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _selected,
                onDestinationSelected: select,
                destinations: destinations,
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFE1EBDD),
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (wide)
                Container(
                  width: 220,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Color(0xFFE8EBE4))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 20, 40),
                        child: Brand(),
                      ),
                      for (var index = 0; index < 3; index++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              selected: _selected == index,
                              selectedColor: forest,
                              selectedTileColor: const Color(0xFFEAF0E7),
                              leading: destinations[index].icon,
                              title: Text(
                                destinations[index].label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => select(index),
                            ),
                          ),
                        ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.eco_outlined, color: forest),
                              SizedBox(height: 12),
                              Text(
                                'A little less waiting.\nA little more living.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Made for campus life.',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 36 : 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          if (!wide)
                            const Expanded(child: Brand())
                          else
                            const Expanded(
                              child: Text(
                                'CAMPUS DINING, SIMPLIFIED',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: forest,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            wide ? 'Main Campus Canteen' : 'Main Campus',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE6E9E1)),
                    if (c.message != null)
                      MaterialBanner(
                        content: Text(c.message!),
                        leading: const Icon(Icons.info_outline),
                        actions: [
                          TextButton(
                            onPressed: c.dismissMessage,
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: _selected,
                        children: [
                          MenuScreen(controller: c, onCart: () => select(1)),
                          CartScreen(
                            controller: c,
                            onMenu: () => select(0),
                            onOrdered: () => select(2),
                          ),
                          OrdersScreen(
                            controller: c,
                            onMenu: () => select(0),
                            onCart: () => select(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: forest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.ramen_dining_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'smart canteen',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: forest,
              ),
            ),
            Text(
              'ORDER AHEAD. EAT HAPPY.',
              style: TextStyle(
                fontSize: 7.5,
                letterSpacing: 1.25,
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
