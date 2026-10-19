import 'models.dart';

/// Pure group-buying price logic — no Flutter, no state, so it is easy to test.

/// The price rung that applies when [qty] units are pooled.
PriceTier tierFor(List<PriceTier> tiers, int qty) {
  var current = tiers.first;
  for (final tier in tiers) {
    if (qty >= tier.minQty) current = tier;
  }
  return current;
}

/// The next cheaper rung not yet reached, or null if already at the best price.
PriceTier? nextTier(List<PriceTier> tiers, int qty) {
  for (final tier in tiers) {
    if (tier.minQty > qty) return tier;
  }
  return null;
}

/// Retail (top) price for a deal — the rung at minQty 0.
double retailPrice(Deal deal) => deal.tiers.first.price;

/// Layer-2: the extra order-value discount a wholesaler gives once their whole
/// pooled order this cycle reaches [grossValue].
double valueDiscountPct(Wholesaler wholesaler, double grossValue) {
  var pct = 0.0;
  for (final tier in wholesaler.valueTiers) {
    if (grossValue >= tier.minOrderValue) pct = tier.discountPct;
  }
  return pct;
}
