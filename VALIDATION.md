# Validation record

Validated on 3 November 2026 using Flutter 3.47.9 and Dart 3.13.7 on Windows.

| Check | Result |
| --- | --- |
| Flutter static analysis | Passed, no issues |
| Automated controller and widget tests | Passed, 13 tests |
| Release web compilation | Passed |
| Responsive layouts | Automated checks at 360, 768 and 1440 pixels; full flow at 390 pixels |
| Browser smoke check | Menu, cart, pickup checkout, order tracking and local persistence checked in Chromium |
| Android/iOS native builds | Not run; native toolchains were unavailable in this workspace |

The test suite covers quantity limits and totals, sold-out controls, input validation, immutable order snapshots, local restoration, duplicate-submit rejection, storage failures, valid status transitions, cancellation, reordering, and the phone ordering flow through collection.

Orders are local demo records and status updates use explicit simulation controls. These checks do not establish operation against a real kitchen, payment provider or backend.
