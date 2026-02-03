import 'menu_item.dart';

class OrderItem {
  final MenuItem item;
  final int quantity;
  final String? note;
  final double priceAtPurchase;

  const OrderItem({
    required this.item,
    this.quantity = 1,
    this.note,
    required this.priceAtPurchase,
  });

  double get lineTotal => item.price * quantity;

  OrderItem copyWith({
    MenuItem? item,
    int? quantity,
    String? note,
    double? priceAtPurchase,
  }) {
    return OrderItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      priceAtPurchase: priceAtPurchase ?? this.priceAtPurchase,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      item: MenuItem.fromMap(map['item'] as Map<String, dynamic>),
      quantity: (map['quantity'] ?? 1) as int,
      note: map['note'] as String?,
      priceAtPurchase: (map['priceAtPurchase'] ?? 0) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantity': quantity,
      'note': note,
      'priceAtPurchase': priceAtPurchase,
    };
  }

  @override
  String toString() => 'OrderItem(item: ${item.name}, qty: $quantity, priceAtPurchase: $priceAtPurchase)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
        other.item == item &&
        other.quantity == quantity &&
        other.note == note &&
        other.priceAtPurchase == priceAtPurchase;
  }

  @override
  int get hashCode => Object.hash(item, quantity, note, priceAtPurchase);
}
