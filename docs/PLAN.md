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

| Persona | Who they are | What they need |
|---|---|---|
| **Customer / Resident** | Someone in a society/colony/area | Browse deals nearby, pledge a quantity, see the price drop as the group fills, pay, collect |
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
- An **item** (e.g. Sugar, 1 kg packs)
- A **wholesaler** supplying it
- An **area** it's open to (so only nearby people can join → one delivery)
- A **deadline** (e.g. "closes in 2 days")
- A **price ladder** (tiers):

| Total pledged | Price per unit |
|---|---|
| 0–19 kg | ₹45 (retail) |
| 20–49 kg | ₹41 |
| 50+ kg | ₹38 (wholesale — target) |

### Deal lifecycle (state machine)

```
OPEN ──(target reached OR deadline hit)──> LOCKED ──> CONFIRMED ──> DELIVERED ──> COMPLETED
  │                                                        
  └──(deadline hit below minimum)──> CANCELLED (everyone refunded)
```

1. **OPEN** — customers pledge quantities. A live progress bar shows
   `42 / 50 kg · join to unlock ₹38!`. The displayed price updates in real time
   as the current tier changes.
2. **LOCKED** — deadline reached or target hit. The **final tier price is now
   fixed for everyone**, including early joiners who saw a higher price.
3. **CONFIRMED** — wholesaler accepts the pooled order; payments captured.
4. **DELIVERED** — one drop to the area's pickup point; coordinator marks received.
5. **COMPLETED** — residents collect their shares; deal closed.
6. **CANCELLED** — didn't reach the minimum viable quantity by the deadline;
   all pledges refunded.

### Key product decisions (to confirm — see §9)
- **Everyone pays the final unlocked price**, even if they joined when it showed
  a higher tier. (This is the "join early, it only gets better" promise — it's
  what drives people to pledge *before* the target, not wait.)
- **Payment timing**: pledge now, charged only when the deal LOCKS. (Avoids
  refunds on the common cancel case.)

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
- Simple in-app notifications: "your deal unlocked wholesale!", "collect your order".

**Explicitly out of scope for MVP** (do later)
- In-app payments (MVP can start **cash-on-collection** to avoid payment-gateway
  and refund complexity — a huge shortcut).
- Ratings/reviews, chat, multiple areas, delivery tracking, invoicing, GST.
- iOS.

> Starting cash-on-collection + single society lets us test *"will people
> actually pool?"* — the only question that matters — without building payments.

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
User(id, phone, name, role[customer|wholesaler|coordinator|admin], areaId)

Area(id, name, pincode, pickupPointAddress, coordinatorUserId)

Wholesaler(id, userId, businessName, verified)

Item(id, name, unit[kg|L|pack], photoUrl)

Deal(id, itemId, wholesalerId, areaId,
     tiers:[{minQty, pricePerUnit}],
     targetQty, minViableQty,
     deadline, status, finalPricePerUnit?,
     totalPledgedQty)

Pledge(id, dealId, userId, qty, status[active|locked|collected|refunded], createdAt)

Order(id, dealId, status, totalAmount, deliveredAt?)  // the pooled order to the wholesaler
```

Relationships: a **Deal** belongs to one Wholesaler + one Area; many **Pledges**
point at a Deal; when it locks, pledges roll up into one **Order**.
`totalPledgedQty` is the number the live progress bar reads.

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

## 9. Open questions to decide before Phase 1

1. **Minimum viable quantity** — below the target but above zero, do we still
   ship (at whatever tier was reached) or cancel? I lean "ship at reached tier,
   cancel only below a floor."
2. **Payments** — confirm MVP is cash-on-collection? (Strongly recommended.)
3. **Who creates wholesalers?** — self-signup then we verify, or we onboard them
   manually at first? (Manual is safer at the start.)
4. **One item per deal, or a basket?** — MVP = one item per deal (simpler).
5. **Area definition** — by society name, by pincode, or by map radius?
6. **Trust/fraud** — what if someone pledges and never collects? Coordinator
   vouching + a no-show flag is probably enough for a pilot.

---

## 10. Name & scope note

**Community Rashan** reads as "neighbourhood provisions" — a good fit. The same
engine later extends beyond groceries (cleaning supplies, stationery, anything
with a wholesale break), but groceries are the right wedge: frequent, everyone
needs them, clear price gap.
