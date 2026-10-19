import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/money.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenCart});
  final VoidCallback onOpenCart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _cat = 'all';
  final _famCtrl = TextEditingController();
  final _famFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _famCtrl.text = Provider.of<AppState>(context, listen: false).families.toString();
  }

  @override
  void dispose() {
    _famCtrl.dispose();
    _famFocus.dispose();
    super.dispose();
  }

  List<Deal> _filtered(AppState app) {
    final q = _query.trim().toLowerCase();
    return app.deals.where((d) {
      if (_cat != 'all' && d.category != _cat) return false;
      if (q.isNotEmpty && !('${d.nameHi} ${d.nameEn}').toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    if (!_famFocus.hasFocus) _famCtrl.text = app.families.toString();
    final deals = _filtered(app);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(app),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              children: [
                _banner(app),
                const SizedBox(height: 14),
                _cats(app),
                const SizedBox(height: 14),
                Text('🔥 आज के group deals', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                if (deals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('कुछ नहीं मिला · दूसरा नाम आज़माएँ', style: TextStyle(color: scheme.onSurfaceVariant))),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 264,
                    ),
                    itemCount: deals.length,
                    itemBuilder: (_, i) => ProductCard(deal: deals[i]),
                  ),
                const SizedBox(height: 14),
                Center(child: Text('Working prototype · demo data', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppState app) {
    return Container(
      color: CR.green,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Flexible(child: Text(app.repo.societyName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ]),
                    Text('${app.repo.pickupPoint} पर pickup · Pune',
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('बटुआ', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(inr(app.wallet.available), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'चीनी, आटा, दाल… ढूँढें',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(AppState app) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [CR.yellow, Color(0xFFFFD968)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛒 इस हफ़्ते का group order · गुरुवार को बंद',
              style: TextStyle(color: CR.yellowInk, fontWeight: FontWeight.w700, fontSize: 15.5)),
          const SizedBox(height: 3),
          const Text('जितनी families मिलकर लेंगी, दाम उतना कम — पैसा safe, बचत wallet में वापस।',
              style: TextStyle(color: CR.yellowInk, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(11)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('👨‍👩‍👧 ', style: TextStyle(fontSize: 15)),
                  SizedBox(
                    width: 58,
                    child: TextField(
                      controller: _famCtrl,
                      focusNode: _famFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: CR.yellowInk, fontWeight: FontWeight.w700, fontSize: 15),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => app.setFamilies(int.tryParse(v) ?? app.families),
                      onSubmitted: (_) => _famFocus.unfocus(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(child: Text('families ने order किया',
                      style: TextStyle(color: CR.yellowInk, fontWeight: FontWeight.w600, fontSize: 13))),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () { app.addFamily(); _famCtrl.text = app.families.toString(); },
                    style: FilledButton.styleFrom(
                      backgroundColor: CR.yellowInk,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('+1 family', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 6),
                const Text('नंबर बदलें या +1 दबाएँ — देखिए दाम कैसे गिरते हैं।',
                    style: TextStyle(color: CR.yellowInk, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cats(AppState app) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: app.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = app.categories[i];
          final on = _cat == c.id;
          return ChoiceChip(
            selected: on,
            onSelected: (_) => setState(() => _cat = c.id),
            label: Text('${c.hi} ${c.en}'),
            labelStyle: TextStyle(color: on ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 13),
            selectedColor: CR.green,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
