# 🛒 Community Rashan

**मिलकर खरीदें, सस्ता पाएं** — *Buy together, pay less.*

A neighbourhood **group-buying** grocery app. Residents of one society pool their
orders so the combined order crosses the wholesaler's bulk thresholds — and
**everyone pays the wholesale price instead of retail**. Built mobile-first and
bilingual (Hindi + English) for the household grocery buyer.

---

## 🔗 Live interfaces

| Interface | Link | Notes |
|---|---|---|
| **Live web app** | **https://community-rashan.web.app** | Real app — Google login + Firestore database. Open on any phone. |
| Live web app (alt) | https://community-rashan.firebaseapp.com | Same app, Firebase's other default domain. |

> The web app auto-deploys from `main` via GitHub Actions on every push.
> An installable Android build is the next packaging step.

---

## ✨ What it does

- **Browse group deals** for your society — grocery staples with live, falling prices.
- **Pool demand:** the more families order an item, the lower the price tier for
  *everyone*. A live counter shows how many families have joined this cycle.
- **Two stacking discounts:**
  1. **Item pool (quantity)** — more of the same item → lower per-kg price.
  2. **Order-value pool (money)** — a wholesaler's big combined order (≥ ₹50k / ₹1L)
     unlocks an extra discount shared back to everyone.
- **Weekly cycles** that close on fixed cutoff days (Mon / Thu / Sat); one pooled
  delivery to the society pickup point.
- **Safe wallet:** you're never charged more than you agreed — the extra savings
  come back to your wallet.

See the full product design in **[docs/PLAN.md](docs/PLAN.md)**.

---

## 🧱 Tech stack

- **App:** Flutter (Dart) — Android-first, one codebase for iOS/web later.
- **Auth:** Firebase Authentication (Google sign-in).
- **Database:** Cloud Firestore.
- **State:** `provider`. **Fonts:** Baloo 2 + Mukta (Devanagari + Latin).
- **Hosting/CI:** Firebase Hosting, auto-deployed by GitHub Actions.

The app runs on built-in **sample data** when Firebase isn't configured, so it's
never blocked — it switches to the live backend automatically once connected.

---

## 📁 Repository

```
app/                 Flutter app (lib/, test/, web/)
  lib/models/        domain models + pure pricing logic (unit-tested)
  lib/data/          Repository interface, Mock + Firestore implementations
  lib/services/      auth (Google / guest)
  lib/screens/       home, cart, orders, wallet, login
docs/
  PLAN.md            full product & design plan
  FIREBASE_SETUP.md  how the Firebase project is connected
prototype/           early interactive HTML prototype of the UX
.github/workflows/   Firebase Hosting auto-deploy
```

## ▶️ Run locally

```bash
cd app
flutter pub get
flutter run            # Android device/emulator, or: flutter run -d chrome
flutter test           # pricing logic unit tests
```

## 🗺️ Status

- ✅ Product design, interactive prototype
- ✅ Flutter app: home / cart / orders / wallet, group-buy pricing, bilingual UI
- ✅ Firebase Google login + Firestore wired; live on Firebase Hosting
- ⬜ Persist orders & pledges to Firestore
- ⬜ Coordinator & wholesaler screens
- ⬜ Installable Android (APK) build
- ⬜ Payments & WhatsApp reminders

---

*Built with [Claude Code](https://claude.com/claude-code).*
