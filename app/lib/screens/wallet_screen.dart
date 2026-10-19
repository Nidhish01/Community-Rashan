import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../util/money.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
            child: const Text('बटुआ / Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [CR.green, CR.greenDark]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('इस्तेमाल के लिए उपलब्ध',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5, letterSpacing: .4)),
                      const SizedBox(height: 2),
                      Text(inr(app.wallet.available),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 34)),
                      const SizedBox(height: 4),
                      Text('कुल ${inr(app.wallet.balance)} · ${inr(app.wallet.held)} order में रुका हुआ',
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('लेन-देन / Transactions', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        ...app.wallet.txns.map((t) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(t.label, style: const TextStyle(fontSize: 14))),
                                  Text('${t.credit ? "+" : "−"}${inr(t.amount)}',
                                      style: TextStyle(
                                          color: t.credit ? CR.save : CR.danger, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text('रुका हुआ पैसा गुरुवार को final दाम पर कटेगा, बाकी वापस।',
                      textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
