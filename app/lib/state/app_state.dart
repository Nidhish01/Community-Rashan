import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../models/models.dart';
import '../models/pricing.dart';

/// Holds the session: which families have joined, the cart, the wallet, and
/// placed orders — plus the pooling + two-layer discount maths that the whole
/// UI reads from.
class AppState extends ChangeNotifier {
  AppState(this.repo);

  final Repository repo;

  /// Reference count the sample `pooledBase` values are calibrated to.
  static const int famStart = 42;

  int families = famStart;
  final Map<String, int> _cart = <String, int>{};
  final Wallet wallet =
      Wallet(txns: [WalletTxn('टॉप-अप / Added money', 2000, true)]);
  final List<PooledOrder> orders = <PooledOrder>[];

  List<Deal> get deals => repo.deals;
  List<Wholesaler> get wholesalers => repo.wholesalers;
  List<ShopCategory> get categories => repo.categories;

  Wholesaler wholesaler(String id) =>
      repo.wholesalers.firstWhere((w) => w.id == id);
  Deal deal(String id) => repo.deals.firstWhere((d) => d.id == id);

  // ---- cart ----
  int cartQty(String id) => _cart[id] ?? 0;
  int get cartCount => _cart.values.where((q) => q > 0).length;
  Map<String, int> get cart => Map<String, int>.unmodifiable(_cart);

  // ---- pooling ----
  int othersPooled(Deal d) {
    final v = (d.pooledBase + (families - famStart) * d.famRate).round();
    return v < 0 ? 0 : v;
  }

  int totalPooled(Deal d) => othersPooled(d) + cartQty(d.id);
  PriceTier currentTier(Deal d) => tierFor(d.tiers, totalPooled(d));
  PriceTier? upcomingTier(Deal d) => nextTier(d.tiers, totalPooled(d));

  /// Layer-2 gross order value for a wholesaler this cycle.
  double grossValue(String wholesalerId) {
    var g = 0.0;
    for (final d in deals.where((d) => d.wholesalerId == wholesalerId)) {
      g += currentTier(d).price * totalPooled(d);
    }
    return g;
  }

  double valuePct(String wholesalerId) =>
      valueDiscountPct(wholesaler(wholesalerId), grossValue(wholesalerId));

  // ---- families (the social-proof + demo lever) ----
  void setFamilies(int value) {
    families = value < 0 ? 0 : value;
    notifyListeners();
  }

  void addFamily() {
    families += 1;
    notifyListeners();
  }

  // ---- cart mutations ----
  void add(Deal d) {
    _cart[d.id] = cartQty(d.id) + d.step;
    notifyListeners();
  }

  void increment(Deal d) => add(d);

  void decrement(Deal d) {
    final q = cartQty(d.id) - d.step;
    if (q <= 0) {
      _cart.remove(d.id);
    } else {
      _cart[d.id] = q;
    }
    notifyListeners();
  }

  // ---- bill ----
  Bill bill() {
    var retail = 0.0;
    var finalAmt = 0.0;
    _cart.forEach((id, qty) {
      if (qty <= 0) return;
      final d = deal(id);
      final cur = currentTier(d).price;
      final vp = valuePct(d.wholesalerId);
      retail += retailPrice(d) * qty;
      finalAmt += cur * (1 - vp / 100) * qty;
    });
    return Bill(retail: retail, finalAmt: finalAmt, save: retail - finalAmt);
  }

  /// Active Layer-2 discounts, for the cart's "bulk chhoot" line.
  List<String> activeValueDiscounts() {
    final out = <String>[];
    for (final w in wholesalers) {
      final pct = valuePct(w.id);
      if (pct > 0) out.add('${w.name}: extra $pct% off');
    }
    return out;
  }

  // ---- place order ----
  void placeOrder() {
    final lines = <OrderLine>[];
    _cart.forEach((id, qty) {
      if (qty > 0) {
        final d = deal(id);
        lines.add(OrderLine(d.emoji, d.nameHi, qty, d.unit.short));
      }
    });
    if (lines.isEmpty) return;

    final b = bill();
    wallet.held += b.retail;
    wallet.txns.insert(0, WalletTxn('Order hold · गुरुवार cycle', b.retail, false));
    orders.insert(
      0,
      PooledOrder(
        id: 'CR${1000 + orders.length * 7 + 3}',
        lines: lines,
        retailTotal: b.retail,
        estTotal: b.finalAmt,
        saved: b.save,
      ),
    );
    _cart.clear();
    families += 1; // you just joined this cycle
    notifyListeners();
  }

  void markReady(PooledOrder order) {
    order.status = OrderStatus.ready;
    notifyListeners();
  }
}

class Bill {
  final double retail;
  final double finalAmt;
  final double save;
  const Bill({required this.retail, required this.finalAmt, required this.save});
}
