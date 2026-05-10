// lib/data/models/transaction_item_model.dart

import '../../core/constants/firestore_keys.dart';

class TransactionItemModel {
  final String productId;
  final double quantity;
  final String unit;
  final double price;
  final double minPrice; // السعر الأدنى
  final bool isGift; // هل القلم هدية؟

  TransactionItemModel({
    required this.productId,
    required this.quantity,
    required this.unit,
    required this.price,
    this.minPrice = 0.0,
    this.isGift = false,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      productId: map[FirestoreKeys.productId] ?? '',
      quantity: (map[FirestoreKeys.quantity] ?? 0).toDouble(),
      unit: map[FirestoreKeys.unit] ?? '',
      price: (map[FirestoreKeys.price] ?? 0).toDouble(),
      minPrice: (map['min_price'] ?? 0).toDouble(),
      isGift: map['is_gift'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.productId: productId,
      FirestoreKeys.quantity: quantity,
      FirestoreKeys.unit: unit,
      FirestoreKeys.price: price,
      'min_price': minPrice,
      'is_gift': isGift,
    };
  }

  TransactionItemModel copyWith({
    String? productId, double? quantity, String? unit,
    double? price, double? minPrice, bool? isGift,
  }) {
    return TransactionItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      minPrice: minPrice ?? this.minPrice,
      isGift: isGift ?? this.isGift,
    );
  }
}