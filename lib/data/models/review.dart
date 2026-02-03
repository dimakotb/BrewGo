class Review {
  final String id;
  final String shopId;
  final String userId;
  final String orderId;
  final double rating; // 1–5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.orderId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  Review copyWith({
    String? id,
    String? shopId,
    String? userId,
    String? orderId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      shopId: map['shopId'] as String,
      userId: map['userId'] as String,
      orderId: map['orderId'] as String,
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      comment: (map['comment'] ?? '') as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'userId': userId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Review(id: $id, rating: $rating)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.shopId == shopId &&
        other.userId == userId &&
        other.orderId == orderId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        shopId,
        userId,
        orderId,
        rating,
        comment,
        createdAt,
      );
}
