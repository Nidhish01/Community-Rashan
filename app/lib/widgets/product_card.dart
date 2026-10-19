import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/pricing.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/money.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final pooled = app.totalPooled(deal);
    final cur = app.currentTier(deal);
    final next = app.upcomingTier(deal);
    final retail = retailPrice(deal);
    final inCart = app.cartQty(deal.id) > 0;
    final off = retail > cur.price ? ((1 - cur.price / retail) * 100).round() : 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: inCart ? CR.green : scheme.outlineVariant, width: inCart ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tile + OFF tag
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(deal.tileColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(deal.emoji, style: const TextStyle(fontSize: 42)),
                  ),
                  if (off > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: CR.green, borderRadius: BorderRadius.circular(7)),
                        child: Text('$off% OFF',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: deal.nameHi, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              TextSpan(text: '  ${deal.nameEn}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            ]), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(deal.unit == Unit.litre ? 'प्रति लीटर' : 'प्रति किलो',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 6),
            _Ladder(deal: deal, pooled: pooled),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text(inr(cur.price), style: const TextStyle(color: CR.save, fontWeight: FontWeight.w700, fontSize: 17)),
              if (off > 0) ...[
                const SizedBox(width: 6),
                Text(inr(retail),
                    style: TextStyle(color: scheme.onSurfaceVariant, decoration: TextDecoration.lineThrough, fontSize: 12.5)),
              ],
            ]),
            const SizedBox(height: 2),
            SizedBox(
              height: 16,
              child: Text(
                next != null ? '+${next.minQty - pooled} ${deal.unit.short} और → ${inr(next.price)}' : '★ सबसे कम दाम!',
                style: TextStyle(color: next != null ? CR.accent : CR.save, fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ),
            const SizedBox(height: 8),
            if (inCart) _Stepper(deal: deal) else _AddButton(deal: deal),
          ],
        ),
      ),
    );
  }
}

class _Ladder extends StatelessWidget {
  const _Ladder({required this.deal, required this.pooled});
  final Deal deal;
  final int pooled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(deal.tiers.length, (i) {
        final on = pooled >= deal.tiers[i].minQty;
        final best = i == deal.tiers.length - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < deal.tiers.length - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: on ? (best ? CR.yellow : CR.green) : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.read<AppState>().add(deal),
        style: OutlinedButton.styleFrom(
          foregroundColor: CR.green,
          side: const BorderSide(color: CR.green, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
        child: const Text('＋ ADD', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final qty = context.watch<AppState>().cartQty(deal.id);
    return Container(
      decoration: BoxDecoration(color: CR.green, borderRadius: BorderRadius.circular(11)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => app.decrement(deal), icon: const Icon(Icons.remove), color: Colors.white),
          Text('$qty ${deal.unit.short}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          IconButton(onPressed: () => app.increment(deal), icon: const Icon(Icons.add), color: Colors.white),
        ],
      ),
    );
  }
}
