import 'package:flutter/foundation.dart';

/// A rung on an item's sliding price ladder: at or above [minQty] pooled, the
/// unit price is [price]. Ladders are stored ascending by [minQty]; the rung at
/// minQty 0 is the retail (highest) price.
@immutable
class PriceTier {
  final int minQty;
  final double price;
  const PriceTier(this.minQty, this.price);
}

/// Layer-2 discount: once a wholesaler's whole order value this cycle reaches
/// [minOrderValue], an extra [discountPct]% comes off the whole order.
@immutable
class ValueTier {
  final double minOrderValue;
  final double discountPct;
  const ValueTier(this.minOrderValue, this.discountPct);
}

@immutable
class Wholesaler {
  final String id;
  final String name;
  final List<ValueTier> valueTiers;
  const Wholesaler({
    required this.id,
    required this.name,
    required this.valueTiers,
  });
}

enum Unit { kg, litre }

extension UnitLabel on Unit {
  String get short => this == Unit.litre ? 'L' : 'kg';
  String get shortHi => this == Unit.litre ? 'लीटर' : 'किलो';
}

/// A product offered in the current cycle. (In later phases this splits into a
/// catalogue Item + a per-cycle Deal, per docs/PLAN.md §6; combined here for
/// Phase 1 so the app is small and runnable.)
@immutable
class Deal {
  final String id;
  final String nameHi;
  final String nameEn;
  final Unit unit;
  final String emoji;
  final int tileColor; // ARGB, e.g. 0xFFFBE7C6
  final String wholesalerId;
  final String category; // 'staple' | 'atta' | 'oil' | 'chai'
  final List<PriceTier> tiers; // ascending by minQty
  final int step; // quantity added per tap
  final int pooledBase; // quantity already pledged by others (at reference family count)
  final double famRate; // extra pooled quantity per additional family (demo lever)

  const Deal({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.unit,
    required this.emoji,
    required this.tileColor,
    required this.wholesalerId,
    required this.category,
    required this.tiers,
    required this.step,
    required this.pooledBase,
    required this.famRate,
  });
}

class WalletTxn {
  final String label;
  final double amount;
  final bool credit; // true = money in, false = held/charged
  WalletTxn(this.label, this.amount, this.credit);
}

class Wallet {
  double balance;
  double held;
  final List<WalletTxn> txns;
  Wallet({this.balance = 2000, this.held = 0, List<WalletTxn>? txns})
      : txns = txns ?? <WalletTxn>[];
  double get available => balance - held;
}

enum OrderStatus { open, ready }

class OrderLine {
  final String emoji;
  final String nameHi;
  final int qty;
  final String unit;
  OrderLine(this.emoji, this.nameHi, this.qty, this.unit);
}

class PooledOrder {
  final String id;
  final List<OrderLine> lines;
  final double retailTotal; // amount held in escrow
  final double estTotal; // expected final amount after both discount layers
  final double saved;
  OrderStatus status;
  PooledOrder({
    required this.id,
    required this.lines,
    required this.retailTotal,
    required this.estTotal,
    required this.saved,
    this.status = OrderStatus.open,
  });
}

@immutable
class ShopCategory {
  final String id;
  final String hi;
  final String en;
  const ShopCategory(this.id, this.hi, this.en);
}
