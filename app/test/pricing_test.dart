import 'package:flutter_test/flutter_test.dart';
import 'package:community_rashan/models/models.dart';
import 'package:community_rashan/models/pricing.dart';

void main() {
  const tiers = [
    PriceTier(0, 45),
    PriceTier(20, 41),
    PriceTier(30, 38),
    PriceTier(50, 34),
  ];

  group('tierFor', () {
    test('below first threshold -> retail', () {
      expect(tierFor(tiers, 0).price, 45);
      expect(tierFor(tiers, 19).price, 45);
    });
    test('crossing thresholds steps the price down', () {
      expect(tierFor(tiers, 20).price, 41);
      expect(tierFor(tiers, 29).price, 41);
      expect(tierFor(tiers, 30).price, 38);
      expect(tierFor(tiers, 49).price, 38);
      expect(tierFor(tiers, 50).price, 34);
      expect(tierFor(tiers, 999).price, 34);
    });
  });

  group('nextTier', () {
    test('returns the next unreached rung', () {
      expect(nextTier(tiers, 0)!.minQty, 20);
      expect(nextTier(tiers, 25)!.minQty, 30);
    });
    test('returns null at the best price', () {
      expect(nextTier(tiers, 50), isNull);
      expect(nextTier(tiers, 100), isNull);
    });
  });

  group('valueDiscountPct (Layer 2)', () {
    const w = Wholesaler(id: 'w', name: 'W', valueTiers: [
      ValueTier(50000, 2),
      ValueTier(100000, 4),
    ]);
    test('no discount below first threshold', () {
      expect(valueDiscountPct(w, 49999), 0);
    });
    test('steps up with order value', () {
      expect(valueDiscountPct(w, 50000), 2);
      expect(valueDiscountPct(w, 99999), 2);
      expect(valueDiscountPct(w, 100000), 4);
    });
  });
}
