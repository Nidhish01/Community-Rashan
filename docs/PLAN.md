# Community Rashan — Product & Design Plan

> A community group-buying app. Neighbours pool their grocery demand into one
> bulk order so everyone unlocks the wholesaler's wholesale price instead of
> each paying retail. Target platform: **Android** (mobile-first).

_Status: v0.1 design draft · Last updated: 2026-10-19_

---

## 1. The problem & the idea

Today, five neighbours each walk to a shop and buy 1 kg of sugar at **retail**
(say ₹45/kg). The wholesaler would happily sell 50 kg at **₹38/kg**, but no
single resident needs 50 kg and nobody coordinates them.

**Community Rashan aggregates that scattered demand.** When enough people in one
area pledge for the same item, the order crosses the wholesaler's bulk threshold
and the lower price unlocks **for everyone in the group**. One pooled order is
delivered to a single neighbourhood pickup point; residents collect their share.

Everybody wins:
- **Customers** pay wholesale, not retail.
- **Wholesalers** get large, predictable, pre-paid orders with one delivery drop
  instead of chasing many tiny retail sales.

---

## 2. Who uses it (personas)

> **Primary user: the Indian homemaker ("aunty").** Most customers are women
> aged ~35–65 who run the household grocery budget. They're value-conscious,
> trust-driven, heavy WhatsApp users, and have a wide range of English comfort.
> The whole app is designed around them — see §11.

| Persona | Who they are | What they need |
|---|---|---|
| **Customer / Resident (mostly aunties)** | The homemaker who buys the household rashan | Simple bilingual screens, big text, clear savings in ₹, trust that her money is safe, WhatsApp reminders |
| **Wholesaler / Supplier** | A bulk seller (mandi trader, distributor) | List items with tiered/bulk pricing, see pooled orders, confirm & fulfil, get paid |
| **Society / Area Admin** (a *coordinator*) | A trusted resident or RWA member | Manage the area's pickup point, vouch for the group, resolve collection issues |
| **Platform Admin** (us) | Operator | Onboard & verify wholesalers, handle disputes, oversee areas |

> The **coordinator** role is what makes logistics cheap: one delivery to the
> society gate, then self-collection. Without it, per-customer delivery would
> eat the wholesale savings. This is a key design bet.

---

## 3. The core mechanic — the "Group Deal"

This is the heart of the app. Everything else supports it.

A **Deal** is an offer to buy a specific item, in a specific area, before a
deadline, that gets cheaper as more quantity is pledged.

A Deal has:
- An **item** (one product per deal)
- A **wholesaler** supplying it
- An **area** it's open to — a **named society with one fixed pickup point**
  (so only residents of that society can join → one delivery)
- A **cutoff day** — every deal belongs to a weekly **order cycle** that closes
  on a fixed day (default: **Mon / Thu / Sat**); pledges collect until that cutoff
- A **sliding price ladder** of several tiers — customers may pledge **any
  quantity**, and the price steps down as the pooled total grows:

| Total pledged | Price per unit |
|---|---|
| 0–19 kg | ₹45 (retail) |
| 20–29 kg | ₹41 |
| 30–49 kg | ₹38 |
| 50+ kg | ₹34 (best) |

There is **no single pass/fail target** — the deal simply settles at whichever
tier the pooled total has reached when it closes. More neighbours joining only
ever makes it cheaper.

### Order cycles (the ordering rhythm)

Deals don't each run on their own arbitrary clock — they run on a shared
**weekly cycle**. The catalogue of items stays open for ordering until the next
**cutoff day** (default **Mon / Thu / Sat**). During the window residents order
any amount of any item; each item pools its own total on its own price ladder.
On the cutoff day every deal in the cycle **locks together**, the pledges pool
into one order per wholesaler, and a **single delivery** lands at the society's
pickup point. Predictable days keep life simple for residents, wholesalers, and
the coordinator alike.

### Two ways the price drops (two pooling layers)

Discounts come from **two independent pools that stack**:

| Layer | What pools | Who it rewards |
|---|---|---|
| **1 · Item pool (quantity)** | More of the **same item** → the item's sliding tier price falls | Buyers of that item |
| **2 · Value pool (money)** | **All the different items** going to one wholesaler this cycle, summed into a total order value | Everyone — a bigger order earns the wholesaler's extra volume discount |

A wholesaler would rather sell ₹1 lakh of mixed goods than ₹10k of one item, so
each wholesaler sets **order-value discount tiers** (e.g. total ≥ ₹50,000 →
extra 2% off; ≥ ₹1,00,000 → extra 4% off). The value pool is measured
**per wholesaler per cycle**. At cutoff:

1. Each item locks at its own quantity tier (Layer 1).
2. The wholesaler's items sum to a **total order value**; whichever value tier it
   reaches sets an **extra % discount on the whole order** (Layer 2).
3. That extra discount is distributed **pro-rata** across every buyer's line
   items and **refunded to their wallets**, alongside the Layer-1 refunds.

Net effect: residents can get cheaper prices just because *other* residents
ordered *different* things from the same wholesaler — and the wholesaler is
happy to give it, because the combined order is far larger.

### Deal lifecycle (state machine)

```
OPEN ──(cutoff day reached)──> LOCKED ──> CONFIRMED ──> DELIVERED ──> COMPLETED
  │                                                        
  └──(item below its floor at cutoff)──> CANCELLED (that item refunded)
```

1. **OPEN** — customers pledge any quantity. A live progress bar shows
   `42 kg pooled · ₹38 now · +8 kg unlocks ₹34!`. The displayed price updates in
   real time as the pooled total crosses each tier.
2. **LOCKED** — cutoff day reached. Each item's **tier price reached is now
   fixed for everyone**, including early joiners who saw a higher price. An item
   below its floor drops out and is refunded; the rest of the cycle still ships.
3. **CONFIRMED** — wholesaler accepts the pooled order; escrow captured at the
   locked price, the held difference refunded to each wallet.
4. **DELIVERED** — one drop to the area's pickup point; coordinator marks received.
5. **COMPLETED** — residents collect their shares; deal closed.
6. **CANCELLED** — didn't reach the minimum viable quantity by the deadline;
   all pledges refunded.

### Key product decisions
- **Everyone pays the final unlocked tier price**, even if they joined when it
  showed a higher price. (This is the "join early, it only gets cheaper"
  promise — it's what drives people to pledge *now*, not wait.)
- **Escrow / wallet pre-pay**: when a customer pledges, the **top (retail) price
  × their quantity is held** in their wallet. When the deal LOCKS at a lower
  tier, they're **charged the unlocked price and the difference is refunded** to
  their wallet. A customer is never charged more than they agreed, and the
  savings return automatically. If the deal cancels, the full hold is refunded.

---

## 4. MVP scope (what we build first)

Deliberately small — prove the mechanic with real people in **one** society.

**In scope for MVP**
- Phone-number login (OTP).
- Customer: see deals open in *my area*, pledge a quantity, watch it fill live,
  see my pledges & their status.
- Wholesaler: create a deal (item + tiers + deadline + area), see pledged total,
  confirm the order.
- Coordinator: mark a delivered order as "arrived at pickup point".
- Real-time deal progress (the live bar is the "wow").
- **Wallet / escrow**: load money, hold on pledge, charge-and-refund on lock.
- Simple in-app notifications: "your deal unlocked a lower price!", "collect your order".

**Explicitly out of scope for MVP** (do later)
- Ratings/reviews, chat, multiple areas, delivery tracking, invoicing, GST.
- iOS.

> Single society + the wallet mechanic lets us test *"will people actually
> pool?"* — the only question that matters — in one controlled area.

---

## 5. Screens & flows (Android)

**Customer**
1. **Login** (phone + OTP) → pick/confirm your area.
2. **Deals feed** — cards: item photo, current price, progress bar, time left.
3. **Deal detail** — price ladder, how much more to unlock next tier, [Pledge qty].
4. **My Pledges** — status of each (open / unlocked / collect / completed).
5. **Notifications**.

**Wholesaler**
1. **Login** → wholesaler dashboard.
2. **Create Deal** — item, unit, tiers, deadline, area.
3. **My Deals** — live pledged totals; [Confirm order] when locked.

**Coordinator**
1. **Area orders** — incoming confirmed deals → [Mark arrived].

A simple bottom-nav app. Role determines which tabs show.

---

## 6. Data model (core entities)

```
User(id, phone, name, role[customer|wholesaler|coordinator|admin], societyId)

Society(id, name, address, pincode, pickupPointAddress, coordinatorUserId)

Wholesaler(id, userId, businessName, verified,
           valueDiscountTiers:[{minOrderValue, discountPct}])  // Layer 2

Item(id, name, unit[kg|L|pack], photoUrl)

Cycle(id, societyId, opensAt, cutoffAt, deliveryAt, status)  // Mon/Thu/Sat rhythm

Deal(id, cycleId, itemId, wholesalerId, societyId,
     tiers:[{minQty, pricePerUnit}],   // sliding ladder, ascending minQty
     minFloorQty,                      // below this at cutoff → this item CANCELLED
     status, lockedPricePerUnit?,
     totalPledgedQty)

Pledge(id, dealId, userId, qty,        // any quantity
       heldAmount,                     // top-tier price × qty, escrowed on pledge
       status[active|locked|collected|refunded], createdAt)

Order(id, cycleId, wholesalerId, societyId,   // one pooled order per wholesaler per cycle
      lineItems:[{dealId, itemId, qty, tierPrice}],
      grossValue,                              // Σ tierPrice × qty  (after Layer 1)
      valueDiscountPct, netValue,              // after Layer 2 order-value tier
      status, deliveredAt?)

Wallet(id, userId, balance)
WalletTxn(id, walletId, type[topup|hold|charge|refund], amount, dealId?, createdAt)
```

Relationships: a **Cycle** holds many **Deals** (one per item); each Deal has
many **Pledges**. At cutoff, all of a wholesaler's deals in the cycle roll up
into **one Order** for that wholesaler — the unit that Layer-2 value discounts
apply to. `totalPledgedQty` is the number the live progress bar reads. Each
Pledge's `heldAmount` moves through the **Wallet** as hold → charge + refund on
lock (Layer-1 and Layer-2 refunds), or a full refund on cancel.

---

## 7. Recommended tech stack

For an Android-first app built by a small team that will likely want iOS later,
and whose killer feature is a **live-updating** deal counter:

| Layer | Recommendation | Why |
|---|---|---|
| **App** | **Flutter** (Dart) | One codebase → Android now, iOS later for free. Fast UI, great for this kind of list/card app. |
| **Backend + DB** | **Firebase** — Firestore, Auth, Cloud Functions | Firestore gives **real-time** pledge updates out of the box (the progress bar just *works*), phone-OTP auth is built in, and Cloud Functions handle the deal-locking logic. Almost no server to run for an MVP. |
| **Notifications** | Firebase Cloud Messaging | Native push, free, integrates with the above. |
| **Deal logic** | A Cloud Function triggered on each pledge / on a schedule | Recomputes current tier, flips OPEN→LOCKED at target or deadline, fixes final price. Keeping this server-side stops clients from cheating the price. |

**Alternative** if you'd rather own a classic backend: Kotlin + Jetpack Compose
(native Android) with a Spring Boot / Node + PostgreSQL API. More control and no
vendor lock-in, but you build auth, real-time, and push yourself, and iOS is a
second project. For an MVP I recommend **Flutter + Firebase** and revisiting
later if you outgrow it.

---

## 8. Build phases (roadmap)

- **Phase 0 — this doc.** Agree the mechanic, scope, stack. ← we are here
- **Phase 1 — Skeleton.** Flutter app + Firebase project, phone login, empty
  deals feed reading from Firestore.
- **Phase 2 — The mechanic.** Create deal (wholesaler), pledge (customer), live
  progress bar, the lock/price-unlock Cloud Function. *This is the demo.*
- **Phase 3 — Fulfilment.** Coordinator "arrived" flow, notifications, My Pledges.
- **Phase 4 — Pilot** in one real society, cash-on-collection.
- **Phase 5 — Payments & scale.** Add a payment gateway, multiple areas,
  ratings, iOS.

---

## 9. Decisions & remaining open questions

**Decided**
- ✅ **Pricing** — a sliding multi-tier ladder (no single pass/fail target); the
  deal settles at whichever tier the pooled total reaches by the deadline.
- ✅ **Quantity** — customers pledge any amount.
- ✅ **Payments** — wallet / escrow pre-pay: hold top-tier price on pledge,
  charge the locked price and refund the difference on lock.
- ✅ **Area** — a named society with one fixed pickup point.
- ✅ **Ordering rhythm** — weekly **order cycles** closing on fixed cutoff days
  (default Mon / Thu / Sat); one pooled delivery per cycle to the society.
- ✅ **Catalogue** — many items open per cycle; **one product per deal**;
  customers order any amount of any item.
- ✅ **Two discount layers** — (1) per-item quantity tiers, plus (2) a
  per-wholesaler order-value discount (e.g. ≥ ₹50k / ₹1L) shared back pro-rata.

**Proposed defaults (confirm / overridable)**
1. **Floor** — each item has a **minimum quantity** (default = the wholesaler's
   smallest sellable unit, e.g. one sack). Clears the floor → ships at whatever
   tier was reached (even top/retail). Below the floor → *that item* cancels and
   refunds; the rest of the cycle still ships. (Alternative: always ship
   everything, even 1 unit, at retail.)
2. **Wholesaler onboarding** — onboard manually / verify at first, open
   self-signup later. (Safer for a pilot.)
3. **Trust/fraud** — a pledge-and-no-collect is handled by coordinator vouching
   + a no-show flag; escrow pre-pay already removes most of this risk.

---

## 10. Name & scope note

**Community Rashan** reads as "neighbourhood provisions" — a good fit. The same
engine later extends beyond groceries (cleaning supplies, stationery, anything
with a wholesale break), but groceries are the right wedge: frequent, everyone
needs them, clear price gap.

---

## 11. Designing for the audience (Indian homemakers / "aunties")

The primary user is the household's grocery decision-maker — mostly women,
~35–65, value-conscious, trust-driven, and far more at home on WhatsApp than in
a typical app. Every UX choice bends to her:

- **Bilingual, plain language.** Hindi + English side by side, big readable
  type, generous tap targets. No finance/English jargon — not "escrow",
  "pledge", "tier", but *"पैसा safe है"* (money is safe), *"जोड़ें"* (add),
  *"कम दाम"* (lower price). (Regional languages — Marathi, Tamil, etc. — later.)
- **Savings first.** The biggest number on the screen is the *bachat* in ₹
  ("आपने ₹120 बचाए"), not a percentage. A good deal is the whole emotional hook.
- **Trust & social proof.** Show how many families in *her* society already
  joined this cycle ("24 families ने order किया") — it's what makes pooling feel
  safe and worth doing. The coordinator is the familiar, trusted "building aunty".
- **Money made simple & safe.** Explain the wallet in her terms: she's never
  charged more than she agreed, and any extra comes straight back. No surprises.
- **Dead-simple flow.** Few screens, few steps, familiar grocery items with
  pictures, and a "my usual list" to reorder staples in one tap (later).
- **WhatsApp-native.** The "cycle closing today" nudge and "collect your order"
  message go to **WhatsApp**, where she already is — not buried in app notifications.
- **Voice & accessibility (later).** Voice search / ordering and high-contrast
  large-text modes widen the door for less tech-comfortable users.

These principles are reflected in the interactive prototype (`prototype/`).
