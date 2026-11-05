# Smart Canteen Pre-Ordering App

A small Flutter lab project: view a menu, add food to a cart, place a pickup order and check its status.

## Run

Install Flutter and add its `bin` folder to PATH, then run:

```sh
flutter doctor
flutter pub get
flutter run -d chrome
```

Use `flutter run` with a connected Android device/emulator instead for Android. The project was checked with Flutter 3.47.9 and Dart 3.13.7. Native Android/iOS builds have not been checked here; Android needs its SDK, and iOS needs macOS and Xcode.

## Files

| File | Contents |
| --- | --- |
| `lib/main.dart` | Three screens, named routes, form, custom widgets and animations |
| `lib/models.dart` | Food/order classes and the Provider cart state |
| `lib/menu_api.dart` | HTTP request and JSON parsing |
| `assets/menu.json` | Six sample dishes and prices |
| `bin/basics.dart` | Simple Dart program for experiment 1 |
| `test/` | Logic, API, widget, animation and layout tests |

Only two app packages are used: `provider` and `http`. The implementation uses normal formatted Dart, small classes and standard Flutter widgets. See [SYLLABUS.md](SYLLABUS.md) for the experiment mapping.

## Try the app

1. Add a dish using **+**, then open the cart icon.
2. Enter your name and choose a pickup time. An empty/short name shows a validation error.
3. Tap **Place order**. The cart is cleared and an order is displayed.
4. Tap **Demo: next status** to move through Placed, Preparing, Ready and Collected.

The menu is fetched from this public repository using the GitHub REST contents API. It contains sample canteen data, not a live canteen feed. If the request fails or is rate-limited, choose **Retry** or **Use sample menu** to load the bundled JSON file. No token is needed.

Orders are in memory for the current session. Restarting/reloading clears them. Status changes are manual simulations, no kitchen is connected, and no payment is collected. To keep the lab code small, the earlier favourites, search, storage, cancellation/reordering and custom fonts have been removed. The earlier version remains in Git history.

## Check the project

```sh
dart run bin/basics.dart
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

See [VALIDATION.md](VALIDATION.md) for the latest results. For a debug APK on a machine with the Android tools, run `flutter build apk --debug`.

## References

- [Flutter setup](https://docs.flutter.dev/install)
- [Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Provider](https://pub.dev/packages/provider)
- [GitHub REST repository contents API](https://docs.github.com/en/rest/repos/contents#get-repository-content)
