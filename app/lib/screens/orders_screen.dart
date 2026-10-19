import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/money.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: CR.green,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: const Text('Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          Expanded(
            child: app.orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('📦', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 10),
                        Text('अभी कोई order नहीं', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('इस हफ़्ते के group deal में शामिल हों।',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: onBrowse,
                          style: FilledButton.styleFrom(backgroundColor: CR.yellow, foregroundColor: CR.yellowInk),
                          child: const Text('सामान देखें'),
                        ),
                      ]),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    children: [
                      ...app.orders.map((o) => _card(context, app, o)),
                      const SizedBox(height: 8),
                      Center(child: Text('WhatsApp पर भी reminder आएगा 💬', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12))),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, AppState app, PooledOrder o) {
    final ready = o.status == OrderStatus.ready;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${o.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 5),
                      Text(o.lines.map((l) => '${l.emoji} ${l.nameHi} ×${l.qty}${l.unit}').join(' · '),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                _statusPill(ready),
              ],
            ),
            const Divider(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('बचत ${inr(o.saved)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('~${inr(o.estTotal)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            if (!ready) ...[
              const SizedBox(height: 11),
              FilledButton(
                onPressed: () {
                  app.markReady(o);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('माल Tower B पर आ गया — collect करें!')),
                  );
                },
                style: FilledButton.styleFrom(backgroundColor: CR.yellow, foregroundColor: CR.yellowInk),
                child: const Text('Demo: cycle बंद करें (माल आ गया)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill(bool ready) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ready ? const Color(0x2615794A) : const Color(0xFFFBECCB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(ready ? '✓ Tower B पर तैयार' : 'गुरुवार को lock',
          style: TextStyle(color: ready ? CR.save : CR.accent, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
