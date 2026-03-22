# SEPC (Spec) — Repo audit & implementation plan

Date: 2026-03-22
Repo: leo-milbor/fuck-your-charges
Branch: spec-agents-and-ui-tests

## Goals
- Identify issues / risks in the current Flutter codebase.
- Track work items and decisions as changes are made.
- Increase automated test coverage, with emphasis on UI/widget coverage.

## Audit summary
### Current testing state
- Only the default Flutter template widget test exists: `test/widget_test.dart`.
- No `integration_test/` directory.
- No CI workflows detected under `.github/workflows/`.

### Architecture snapshot
- UI and state are primarily in `lib/main.dart` (a `MaterialApp` returning a `HomePage` with a `Drawer`-driven tab switch).
- Domain logic lives in `lib/charge_calculator.dart`.
- UI widgets are in:
  - `lib/prices_page.dart`, `lib/price_entry.dart`, `lib/total_breakdown.dart`
  - `lib/charge_config_page.dart`, `lib/charge_entry.dart`

## Issues / improvement opportunities

### P0 — Correctness / UX
1. **Default widget test is obsolete**
   - `test/widget_test.dart` still tests the template counter, but the app UI does not have a counter or a '+' button.
   - Outcome: tests are misleading and likely failing.

2. **AppBar uses Theme.of(context) above MaterialApp context**
   - In `lib/main.dart`, the `AppBar` pulls theme values from `Theme.of(context)` where `context` is from the `HomePage` build (above `MaterialApp`).
   - This may not use the intended theme and can cause subtle styling issues.
   - Fix: use `Builder` inside `MaterialApp`/`Scaffold` or move `MaterialApp` above `HomePage`.

3. **State stored directly on the Widget instance**
   - In `HomePage` (a `StatefulWidget`), `calculator` and `prices` are fields on the widget, not the `State`.
   - This can lead to confusing lifecycle behavior and makes testing more difficult.
   - Fix: move into `_HomePageState` or introduce a simple state container (e.g. ChangeNotifier) later.

4. **Autofocus on every row input field**
   - `PriceEntry` and `ChargeEntry` both set `autofocus: true` on row text fields.
   - With lists of entries, this can cause focus churn and unexpected keyboard popping.
   - Fix: only autofocus the first row or newly added row.

### P1 — Maintainability / Quality
5. **Missing unit tests for ChargeCalculator**
   - `calculateFinalPrice` and `calculateTaxBreakdown` have logic worth covering, especially compound charges.

6. **Potential null/empty edge cases in TotalBreakdown**
   - `prices.reduce(...)` will throw if `prices` is empty.
   - Currently the UI always provides at least one element, but this is an implicit invariant.
   - Fix: guard against empty iterables or enforce invariants explicitly.

7. **Charge label used as Map key**
   - In `calculateTaxBreakdown`, keys are `charge.label`. Duplicate labels would overwrite values.
   - Fix: enforce unique labels or use a list structure.

### P2 — Tooling / Process
8. **No CI workflow**
   - Add a GitHub Actions workflow to run `flutter analyze` and `flutter test` on pushes/PRs.

9. **No coverage reporting**
   - Add `flutter test --coverage` and optionally a coverage gate (later).

## Test plan (coverage focus)

### Unit tests
- Add `test/charge_calculator_test.dart`
  - verifies `applyRate`
  - verifies compound charging behavior in `calculateFinalPrice`
  - verifies breakdown values in `calculateTaxBreakdown`

### Widget tests (UI)
- Replace template counter test with real tests:
  1. `test/home_navigation_test.dart`
     - Pump `FuckYourChargesApp`
     - Open drawer
     - Switch between "Prices" and "Configure charges"
  2. `test/prices_page_test.dart`
     - Enter a base price in the first `PriceEntry`
     - Validate that "Final:" text updates
     - Confirm that validating input adds a new blank row
  3. `test/charges_config_page_test.dart`
     - Edit label and rate
     - Validate row-add behavior

### (Optional) integration tests
- Consider adding `integration_test/` later once widget tests are stable.

## Implementation checklist
- [ ] Add `AGENTS.md`
- [ ] Replace default widget test with app-relevant widget tests
- [ ] Add unit tests for calculator
- [ ] Add GitHub Actions workflow for analyze/test (+ coverage)
- [ ] Fix P0 code issues that block tests or cause flaky UI behavior

## Decisions log
- 2026-03-22: Focus first on widget tests and unit tests; integration tests optional later.