import '../models/models.dart';

/// Source of catalogue + cycle data. Phase 1 uses [MockRepository]; Phase 2
/// adds a FirestoreRepository implementing the same interface (see README).
abstract class Repository {
  List<Wholesaler> get wholesalers;
  List<Deal> get deals;
  List<ShopCategory> get categories;
  String get societyName;
  String get pickupPoint;
}

class MockRepository implements Repository {
  @override
  String get societyName => 'Green Meadows Society';

  @override
  String get pickupPoint => 'Tower B lobby';

  @override
  final List<ShopCategory> categories = const [
    ShopCategory('all', 'सब', 'All'),
    ShopCategory('staple', 'दाल-चावल', 'Staples'),
    ShopCategory('atta', 'आटा-बेसन', 'Flour'),
    ShopCategory('oil', 'तेल-घी', 'Oil & Ghee'),
    ShopCategory('chai', 'चाय-चीनी', 'Tea & Sugar'),
  ];

  @override
  final List<Wholesaler> wholesalers = const [
    Wholesaler(id: 'sharma', name: 'Sharma Traders', valueTiers: [
      ValueTier(50000, 2),
      ValueTier(100000, 4),
    ]),
    Wholesaler(id: 'verma', name: 'Verma Agro', valueTiers: [
      ValueTier(40000, 2),
      ValueTier(80000, 3.5),
    ]),
  ];

  @override
  final List<Deal> deals = const [
    Deal(
      id: 'sugar', nameHi: 'चीनी', nameEn: 'Sugar', unit: Unit.kg, emoji: '🧂',
      tileColor: 0xFFFBE7C6, wholesalerId: 'sharma', category: 'chai',
      step: 5, pooledBase: 40, famRate: 0.8,
      tiers: [PriceTier(0, 45), PriceTier(20, 41), PriceTier(30, 38), PriceTier(50, 34)],
    ),
    Deal(
      id: 'atta', nameHi: 'चक्की आटा', nameEn: 'Atta', unit: Unit.kg, emoji: '🌾',
      tileColor: 0xFFF3E4C0, wholesalerId: 'sharma', category: 'atta',
      step: 5, pooledBase: 68, famRate: 1.2,
      tiers: [PriceTier(0, 42), PriceTier(25, 38), PriceTier(50, 35), PriceTier(100, 32)],
    ),
    Deal(
      id: 'toor', nameHi: 'तूर दाल', nameEn: 'Toor Dal', unit: Unit.kg, emoji: '🫘',
      tileColor: 0xFFF0D9A8, wholesalerId: 'sharma', category: 'staple',
      step: 1, pooledBase: 16, famRate: 0.5,
      tiers: [PriceTier(0, 140), PriceTier(10, 128), PriceTier(25, 120), PriceTier(50, 112)],
    ),
    Deal(
      id: 'oil', nameHi: 'सूरजमुखी तेल', nameEn: 'Oil', unit: Unit.litre, emoji: '🛢️',
      tileColor: 0xFFFBEEB6, wholesalerId: 'sharma', category: 'oil',
      step: 1, pooledBase: 12, famRate: 0.4,
      tiers: [PriceTier(0, 150), PriceTier(10, 140), PriceTier(20, 132), PriceTier(40, 126)],
    ),
    Deal(
      id: 'ghee', nameHi: 'देसी घी', nameEn: 'Ghee', unit: Unit.kg, emoji: '🧈',
      tileColor: 0xFFFBE3A0, wholesalerId: 'sharma', category: 'oil',
      step: 1, pooledBase: 8, famRate: 0.3,
      tiers: [PriceTier(0, 560), PriceTier(5, 540), PriceTier(10, 520), PriceTier(20, 500)],
    ),
    Deal(
      id: 'salt', nameHi: 'नमक', nameEn: 'Salt', unit: Unit.kg, emoji: '🧊',
      tileColor: 0xFFE7EEF2, wholesalerId: 'sharma', category: 'staple',
      step: 1, pooledBase: 30, famRate: 0.9,
      tiers: [PriceTier(0, 28), PriceTier(20, 25), PriceTier(40, 23), PriceTier(80, 21)],
    ),
    Deal(
      id: 'rice', nameHi: 'बासमती चावल', nameEn: 'Rice', unit: Unit.kg, emoji: '🍚',
      tileColor: 0xFFEEF0E6, wholesalerId: 'verma', category: 'staple',
      step: 5, pooledBase: 28, famRate: 0.7,
      tiers: [PriceTier(0, 95), PriceTier(20, 86), PriceTier(50, 80), PriceTier(100, 74)],
    ),
    Deal(
      id: 'tea', nameHi: 'असम चाय', nameEn: 'Tea', unit: Unit.kg, emoji: '🍵',
      tileColor: 0xFFE3D6C3, wholesalerId: 'verma', category: 'chai',
      step: 1, pooledBase: 6, famRate: 0.3,
      tiers: [PriceTier(0, 320), PriceTier(10, 296), PriceTier(25, 280), PriceTier(50, 262)],
    ),
    Deal(
      id: 'poha', nameHi: 'पोहा', nameEn: 'Poha', unit: Unit.kg, emoji: '🥣',
      tileColor: 0xFFF1EAD6, wholesalerId: 'verma', category: 'staple',
      step: 1, pooledBase: 14, famRate: 0.5,
      tiers: [PriceTier(0, 48), PriceTier(10, 44), PriceTier(25, 40), PriceTier(50, 37)],
    ),
    Deal(
      id: 'besan', nameHi: 'बेसन', nameEn: 'Besan', unit: Unit.kg, emoji: '🟡',
      tileColor: 0xFFF8E9AB, wholesalerId: 'verma', category: 'atta',
      step: 1, pooledBase: 10, famRate: 0.4,
      tiers: [PriceTier(0, 95), PriceTier(8, 88), PriceTier(20, 82), PriceTier(40, 78)],
    ),
  ];
}
