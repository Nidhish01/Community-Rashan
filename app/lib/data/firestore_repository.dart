import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'repository.dart';

/// Firestore-backed catalogue. Mirrors the collections in docs/PLAN.md §6.
///
/// On first run it seeds the sample society / wholesalers / deals so the app
/// has something to show, then reads them back. Pledges, orders and wallets are
/// kept in [AppState] for now; persisting them is the next step.
class FirestoreRepository implements Repository {
  FirestoreRepository._({
    required String society,
    required String pickup,
    required List<ShopCategory> cats,
    required List<Wholesaler> wholesalers,
    required List<Deal> deals,
  })  : _society = society,
        _pickup = pickup,
        _cats = cats,
        _wholesalers = wholesalers,
        _deals = deals;

  final String _society;
  final String _pickup;
  final List<ShopCategory> _cats;
  final List<Wholesaler> _wholesalers;
  final List<Deal> _deals;

  @override
  String get societyName => _society;
  @override
  String get pickupPoint => _pickup;
  @override
  List<ShopCategory> get categories => _cats;
  @override
  List<Wholesaler> get wholesalers => _wholesalers;
  @override
  List<Deal> get deals => _deals;

  static const String societyId = 'green-meadows';

  static Future<FirestoreRepository> load() async {
    final db = FirebaseFirestore.instance;
    await _seedIfEmpty(db);

    final societyDoc = await db.collection('societies').doc(societyId).get();
    final society = (societyDoc.data()?['name'] as String?) ?? 'Green Meadows Society';
    final pickup = (societyDoc.data()?['pickupPoint'] as String?) ?? 'Tower B lobby';

    final catsSnap = await db.collection('categories').orderBy('order').get();
    final cats = catsSnap.docs
        .map((d) => ShopCategory(d.data()['id'] as String, d.data()['hi'] as String, d.data()['en'] as String))
        .toList();

    final wsSnap = await db.collection('wholesalers').get();
    final wholesalers = wsSnap.docs.map(_wholesalerFrom).toList();

    final dealsSnap = await db.collection('deals').get();
    final deals = dealsSnap.docs.map(_dealFrom).toList();

    return FirestoreRepository._(
      society: society,
      pickup: pickup,
      cats: cats.isEmpty ? const [ShopCategory('all', 'सब', 'All')] : cats,
      wholesalers: wholesalers,
      deals: deals,
    );
  }

  static Future<void> _seedIfEmpty(FirebaseFirestore db) async {
    final existing = await db.collection('deals').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final mock = MockRepository();
    final batch = db.batch();
    batch.set(db.collection('societies').doc(societyId),
        {'name': mock.societyName, 'pickupPoint': mock.pickupPoint});
    for (var i = 0; i < mock.categories.length; i++) {
      final c = mock.categories[i];
      batch.set(db.collection('categories').doc(c.id), {'id': c.id, 'hi': c.hi, 'en': c.en, 'order': i});
    }
    for (final w in mock.wholesalers) {
      batch.set(db.collection('wholesalers').doc(w.id), _wholesalerMap(w));
    }
    for (final d in mock.deals) {
      batch.set(db.collection('deals').doc(d.id), _dealMap(d));
    }
    await batch.commit();
  }

  // ---- mappers ----
  static Map<String, dynamic> _wholesalerMap(Wholesaler w) => {
        'id': w.id,
        'name': w.name,
        'valueTiers': w.valueTiers
            .map((v) => {'minOrderValue': v.minOrderValue, 'discountPct': v.discountPct})
            .toList(),
      };

  static Wholesaler _wholesalerFrom(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Wholesaler(
      id: m['id'] as String,
      name: m['name'] as String,
      valueTiers: (m['valueTiers'] as List)
          .map((e) => ValueTier((e['minOrderValue'] as num).toDouble(), (e['discountPct'] as num).toDouble()))
          .toList(),
    );
  }

  static Map<String, dynamic> _dealMap(Deal d) => {
        'id': d.id,
        'nameHi': d.nameHi,
        'nameEn': d.nameEn,
        'unit': d.unit.name,
        'emoji': d.emoji,
        'tileColor': d.tileColor,
        'wholesalerId': d.wholesalerId,
        'category': d.category,
        'step': d.step,
        'pooledBase': d.pooledBase,
        'famRate': d.famRate,
        'tiers': d.tiers.map((t) => {'minQty': t.minQty, 'price': t.price}).toList(),
      };

  static Deal _dealFrom(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Deal(
      id: m['id'] as String,
      nameHi: m['nameHi'] as String,
      nameEn: m['nameEn'] as String,
      unit: (m['unit'] == 'litre') ? Unit.litre : Unit.kg,
      emoji: m['emoji'] as String,
      tileColor: (m['tileColor'] as num).toInt(),
      wholesalerId: m['wholesalerId'] as String,
      category: m['category'] as String,
      step: (m['step'] as num).toInt(),
      pooledBase: (m['pooledBase'] as num).toInt(),
      famRate: (m['famRate'] as num).toDouble(),
      tiers: (m['tiers'] as List)
          .map((e) => PriceTier((e['minQty'] as num).toInt(), (e['price'] as num).toDouble()))
          .toList(),
    );
  }
}
