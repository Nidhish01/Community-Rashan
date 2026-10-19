# Community Rashan — Flutter app (Phase 1)

A neighbourhood **group-buying** grocery app: residents of one society pool their
orders so the whole order crosses the wholesaler's bulk thresholds and everyone
pays wholesale instead of retail. See [`../docs/PLAN.md`](../docs/PLAN.md) for the
full product design.

This Phase-1 scaffold **runs immediately on in-memory sample data** (no backend
needed) so you can see the app on a device/emulator. Firebase is wired in a
second step.

## Run it

You need the Flutter SDK (3.19+). Then:

```bash
cd app
flutter pub get
flutter run        # pick an Android device/emulator, or `flutter run -d chrome`
```

The app opens on the **home feed** with live group pricing, a cart, wallet, and
orders — the same mechanic as the web prototype, now in real Flutter.

## What's here

```
lib/
  main.dart                 app entry; injects AppState (ChangeNotifier) via provider
  theme.dart                Material 3 theme, Baloo 2 + Mukta fonts, aunty-first palette
  util/money.dart           ₹ formatting (en_IN)
  models/
    models.dart             Wholesaler, ValueTier, Deal, PriceTier, Wallet, PooledOrder …
    pricing.dart            PURE domain logic: tier lookup + value-discount (unit-tested)
  data/
    repository.dart         Repository interface + MockRepository (sample society/cycle)
  state/
    app_state.dart          cart, wallet, orders, the pooling + two-layer discount math
  screens/
    root_scaffold.dart      bottom tab bar (Home / Cart / Orders / Wallet)
    home_screen.dart        location bar, search, cycle banner + families counter, grid
    cart_screen.dart        itemised bill, savings, escrow explainer, place order
    orders_screen.dart      order history + status
    wallet_screen.dart      balance / held / transactions
  widgets/
    product_card.dart       one group-deal card (price ladder, add / stepper)
test/
  pricing_test.dart         unit tests for the tier + value-discount logic
```

The **two discount layers** from the plan live in `pricing.dart` + `app_state.dart`:
1. per-item quantity tiers (`tierFor`), and
2. per-wholesaler order-value discount (`valueDiscountPct`).

## Connect Firebase (Phase 2)

1. Install the CLI: `dart pub global activate flutterfire_cli`.
2. Create a Firebase project in the console, then from `app/` run
   `flutterfire configure` — it generates `lib/firebase_options.dart`.
3. In `pubspec.yaml`, uncomment `firebase_core`, `cloud_firestore`,
   `firebase_auth`, and `flutter pub get`.
4. Implement `FirestoreRepository` against the `Repository` interface
   (replace `MockRepository` in `main.dart`), and add phone-OTP auth with
   `firebase_auth`.

Firestore collections mirror the data model in `../docs/PLAN.md` §6
(`societies`, `cycles`, `deals`, `pledges`, `orders`, `wallets`).

> Note: this scaffold was written without a local Flutter toolchain, so run
> `flutter analyze` once after `pub get` and fix any version-specific nits.
