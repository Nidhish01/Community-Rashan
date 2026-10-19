import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/money.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onPlaced, required this.onBrowse});
  final VoidCallback onPlaced;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final entries = app.cart.entries.where((e) => e.value > 0).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bar(context, 'टोकरी / Cart', app),
          Expanded(
            child: entries.isEmpty
                ? _empty(context)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    children: [
                      ...entries.map((e) => _row(context, app, e.key, e.value)),
                      _bill(context, app),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 10),
            Text('टोकरी खाली है', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Group deals से सामान जोड़ें और मिलकर बचाएँ।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(backgroundColor: CR.yellow, foregroundColor: CR.yellowInk),
              child: const Text('सामान देखें'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, AppState app, String id, int qty) {
    final d = app.deal(id);
    final cur = app.currentTier(d).price;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(d.tileColor), borderRadius: BorderRadius.circular(10)),
              child: Text(d.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${d.nameHi}  ${d.nameEn}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  Text('${inr(cur)} × $qty ${d.unit.short}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  _mini(context, app, d),
                ],
              ),
            ),
            Text(inr(cur * qty), style: const TextStyle(color: CR.save, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _mini(BuildContext context, AppState app, Deal d) {
    return Container(
      decoration: BoxDecoration(color: CR.green, borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        InkWell(onTap: () => app.decrement(d), child: const SizedBox(width: 30, height: 30, child: Icon(Icons.remove, color: Colors.white, size: 17))),
        Text('${app.cartQty(d.id)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        InkWell(onTap: () => app.increment(d), child: const SizedBox(width: 30, height: 30, child: Icon(Icons.add, color: Colors.white, size: 17))),
      ]),
    );
  }

  Widget _bill(BuildContext context, AppState app) {
    final b = app.bill();
    final discounts = app.activeValueDiscounts();
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('🧾 हिसाब / Bill', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 11),
            _line(context, 'Retail दाम (अकेले लेते तो)', inr(b.retail)),
            _line(context, 'Group दाम', inr(b.finalAmt)),
            if (discounts.isNotEmpty)
              _line(context, 'Bulk छूट 🎉 ${discounts.join(" · ")}', '', save: true),
            _line(context, 'कुल बचत / You save', '− ${inr(b.save)}', save: true),
            const Divider(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('आप देंगे', style: Theme.of(context).textTheme.titleMedium),
              Text(inr(b.finalAmt), style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFBECCB), borderRadius: BorderRadius.circular(11)),
              child: Text('🔒 अभी ${inr(b.retail)} आपके बटुए में रोका जाएगा। गुरुवार को final दाम कटेगा, बाकी ${inr(b.save)} वापस बटुए में।',
                  style: const TextStyle(color: CR.accent, fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
            const SizedBox(height: 13),
            FilledButton(
              onPressed: () {
                context.read<AppState>().placeOrder();
                onPlaced();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order हो गया! पैसा safe 🔒')),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: CR.green, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: Text('Order pakka करें · ${inr(b.retail)} safe रखें',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value, {bool save = false}) {
    final style = TextStyle(
      fontSize: 14,
      color: save ? CR.save : null,
      fontWeight: save ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: style)),
        Text(value, style: style),
      ]),
    );
  }

  Widget _bar(BuildContext context, String title, AppState app) {
    return Container(
      color: CR.green,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        Text('बटुआ ${inr(app.wallet.available)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ]),
    );
  }
}
