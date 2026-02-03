import 'menu_item.dart';

class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final double distanceKm;
  final double rating;
  final List<MenuItem> menu;
  final double? latitude;
  final double? longitude;

  const Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.distanceKm,
    this.rating = 0,
    this.menu = const [],
    this.latitude,
    this.longitude,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? address,
    double? distanceKm,
    double? rating,
    List<MenuItem>? menu,
    double? latitude,
    double? longitude,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      menu: menu ?? this.menu,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      distanceKm: ((map['distanceKm'] ?? 0) as num).toDouble(),
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      menu:
          (map['menu'] as List<dynamic>? ?? [])
              .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
              .toList(),
      latitude:
          map['latitude'] != null
              ? ((map['latitude'] as num).toDouble())
              : null,
      longitude:
          map['longitude'] != null
              ? ((map['longitude'] as num).toDouble())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'distanceKm': distanceKm,
      'rating': rating,
      'menu': menu.map((item) => item.toMap()).toList(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'Shop(id: $id, name: $name, distanceKm: $distanceKm)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shop &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.address == address &&
        other.distanceKm == distanceKm &&
        other.rating == rating &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        _listEquals(other.menu, menu);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    address,
    distanceKm,
    rating,
    latitude,
    longitude,
    menu.length,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
