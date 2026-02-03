
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 0,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    double? rating,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    if (id == null || id.toString().isEmpty) {
      throw Exception('MenuItem missing required field: id');
    }

    final name = map['name'];
    if (name == null || name.toString().isEmpty) {
      throw Exception('MenuItem missing required field: name');
    }

    final price = map['price'];
    if (price == null) {
      throw Exception('MenuItem missing required field: price');
    }

    return MenuItem(
      id: id.toString(),
      name: name.toString(),
      description: (map['description'] ?? '').toString(),
      price: (price is num ? price : double.tryParse(price.toString()) ?? 0.0).toDouble(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      rating: ((map['rating'] ?? 0) is num 
          ? (map['rating'] as num) 
          : (double.tryParse(map['rating'].toString()) ?? 0.0)).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  @override
  String toString() => 'MenuItem(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.imageUrl == imageUrl &&
        other.rating == rating;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, price, imageUrl, rating);
}
