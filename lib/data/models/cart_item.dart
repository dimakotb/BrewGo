import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  final int quantity;
  final String? note;

  const CartItem({
    required this.item,
    this.quantity = 1,
    this.note,
  });

  double get lineTotal => item.price * quantity;

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      item: MenuItem.fromMap(map['item'] as Map<String, dynamic>),
      quantity: (map['quantity'] ?? 1) as int,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantity': quantity,
      'note': note,
    };
  }

  @override
  String toString() => 'CartItem(item: ${item.name}, qty: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.item == item &&
        other.quantity == quantity &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(item, quantity, note);
}

