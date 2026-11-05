# Simplified version: validation

Checked on 5 November 2026 with Flutter 3.47.9 and Dart 3.13.7 on Windows.

| Check | Result |
| --- | --- |
| Dart basics program | Passed; prints a bill of Rs 80 |
| `flutter analyze` | Passed; no issues |
| `flutter test` | Passed; 11 tests |
| Release web build | Passed |
| GitHub REST menu request | HTTP 200, all six dishes returned |
| Browser | Remote menu loaded; phone cart/checkout checked |
| Android/iOS binaries | Not built or device-tested here |

The tests cover cart totals, quantity limits/removal, input validation, order snapshots, duplicate checkout protection, status progression, API responses/errors, explicit offline sample-menu recovery, fade/slide values, and the complete menu-to-collection flow at widths of 360, 768 and 1200 pixels.

## Code reduction

The previous version contained 2,131 nonblank lines across five files in `lib/`. The simplified version has 432 nonblank lines (458 including blank lines) across three files: a **79.7% reduction**. Counts exclude tests, generated platform scaffolding, the Dart basics example and documentation. The code uses the Dart formatter; it has not been minified.

The app has only two direct runtime packages: Provider and HTTP. Extra storage, custom fonts and optional features were removed. Use [SYLLABUS.md](SYLLABUS.md) to locate each lab concept.

Orders are session-only demo records, and kitchen statuses are advanced manually. The live HTTP check verifies access to sample menu data; it does not establish operation against a real canteen backend.
