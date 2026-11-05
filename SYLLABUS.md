# MGIT MR-22 Flutter lab mapping

This maps the supplied experiments to the simplified Smart Canteen project.

| Experiment | Where to find it |
| --- | --- |
| 1(a): SDK installation | README setup commands; verify your own installation with `flutter doctor` |
| 1(b): Dart basics | `bin/basics.dart`: variables, list, loop, function and string interpolation |
| 2(a): Widgets | `FoodCard`: Text, Image, Container and Card; screens use buttons, lists and input widgets |
| 2(b): Layout | `FoodCard`: Column and Stack; `QuantityButtons` and cart rows: Row |
| 3: Responsive UI | `MenuPage.build`: MediaQuery breakpoints, 1 column below 600px, 2 at 600px, 3 at 900px; cart form limited to 600px |
| 4: Navigator and named routes | `CanteenApp`: `/`, `/cart`, `/orders`; `Navigator.pushNamed`, `pushReplacementNamed` and normal back navigation |
| 5: Stateful/stateless; setState/Provider | Stateful `MenuPage` and `CartPage`; stateless `FoodCard`, `QuantityButtons`, `OrdersPage`; setState for loading/pickup selection, Provider for cart/orders |
| 6: Custom widgets and themes | `FoodCard`, `QuantityButtons`, ThemeData with a teal colour scheme and title text styles |
| 7: Forms, validation and errors | Cart Form with TextFormField and DropdownButtonFormField; name validator; menu error screen with Retry/sample-menu actions |
| 8: Animation | AnimationController with FadeTransition and SlideTransition for menu entry; AnimatedSwitcher for order status; controller disposed in `dispose` |
| 9: REST API | `menu_api.dart`: HTTP GET to GitHub REST API, status check, timeout, JSON parsing; fetched dishes displayed as cards |
| 10: Tests and debugging | `test/canteen_test.dart`, `test/app_test.dart`; `flutter analyze`, `flutter test`, Flutter Inspector and debug console |

## Explain it in a viva

- `Food` holds one dish. `CartItem` adds its quantity. `Order` stores the submitted details.
- `Canteen` extends ChangeNotifier. Its methods change the cart/orders and call `notifyListeners()`.
- `context.watch<Canteen>()` rebuilds a widget when that shared state changes.
- `setState` handles state that belongs only to one screen, such as the selected pickup time.
- Named routes open each screen. Replacing the cart route after checkout lets Back return to the menu.
- The REST request returns JSON. `parseMenu` converts it into Food objects; failures show recovery buttons.
- An order copies item descriptions and the total before clearing the cart.
- The animation controller progresses from 0 to 1; fade controls opacity and slide controls position.

## Debugging practice

Run `flutter run`, open Flutter DevTools from the terminal link, and use Inspector to select a FoodCard. Put a breakpoint in `Canteen.change` and inspect the quantity while tapping **+**. Disconnect the network to inspect the menu error/retry flow. Run the tests to check behaviour at phone, tablet and desktop widths.

This mapping describes the implementation, not instructor approval. Review each function and adapt the sample menu and presentation to your class requirements.
