# Calculator Studio

Graduate Homework 1 for CSC 6370 Mobile Application Development.

## Implemented requirements

- Core two-operand calculator with digits 0–9, addition, subtraction, multiplication, division, clear, readable result display, and responsive Flutter layout.
- Required graduate decimal input, including prevention of repeated decimal points.
- Advanced feature 1: calculation history with a scrollable list, tap-to-reuse result, and clear-history action.
- Advanced feature 2: chained operations with a visible running total and intentional left-to-right evaluation.
- Advanced feature 3: recoverable errors for incomplete expressions, division by zero, and excessively large results.
- Additional usability: Backspace removes the last entered character; every control has a semantic label and result/error text is announced as a live region.

## Run and verify

```bash
flutter pub get
flutter test
flutter analyze
flutter run
flutter build apk
```

The release APK is produced at `build/app/outputs/flutter-apk/app-release.apk`.

## Evaluation strategy

Chained operations evaluate left-to-right. For example, `8 + 2 × 3` produces `30`: the app completes `8 + 2` when `×` is pressed, shows a running total of `10`, then multiplies by `3`. This approach makes each intermediate state visible and avoids implying conventional operator precedence in a two-operand interface.
