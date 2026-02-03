import 'order_item.dart';

enum OrderStatus { pending, preparing, ready, completed, cancelled }

class Order {
  final String id;
  final List<OrderItem> items;
  final double taxes;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    this.taxes = 0,
    this.totalPrice = 0,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  double get subtotal =>
      items.fold(0, (total, item) => total + item.lineTotal);

  double get total => subtotal + taxes + totalPrice;

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? taxes,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      taxes: taxes ?? this.taxes,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      taxes: ((map['taxes'] ?? 0) as num).toDouble(),
      totalPrice: ((map['totalPrice'] ?? 0) as num).toDouble(),
      status: _statusFromString(map['status'] as String?),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'taxes': taxes,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static OrderStatus _statusFromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  @override
  String toString() => 'Order(id: $id, totalPrice: $totalPrice, status: ${status.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.taxes == taxes &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.createdAt == createdAt &&
        _listEquals(other.items, items);
  }

  @override
  int get hashCode =>
      Object.hash(id, taxes, totalPrice, status, createdAt, items.length);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
