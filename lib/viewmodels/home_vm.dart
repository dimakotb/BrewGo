import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/shop.dart';

class HomeViewModel extends ChangeNotifier {
  List<Shop> _shops = [];
  List<Shop> _filteredShops = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Shop> get shops => List.unmodifiable(_filteredShops);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeViewModel() {
    _loadShops();
  }

  Future<void> _loadShops() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('shops').get();

      _shops =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Shop(
              id: doc.id,
              name: data['name'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
              address: data['address'] ?? '',
              distanceKm: (data['distanceKm'] ?? 0).toDouble(),
              rating: (data['rating'] ?? 0).toDouble(),
              latitude:
                  data['latitude'] != null
                      ? (data['latitude'] as num).toDouble()
                      : null,
              longitude:
                  data['longitude'] != null
                      ? (data['longitude'] as num).toDouble()
                      : null,
            );
          }).toList();

      _filteredShops = List.from(_shops);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchShops(String query) {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _filteredShops = List.from(_shops);
    } else {
      _filteredShops =
          _shops.where((shop) {
            return shop.name.toLowerCase().contains(_searchQuery) ||
                shop.address.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredShops = List.from(_shops);
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadShops();
  }

  Shop? getShopById(String shopId) {
    try {
      return _shops.firstWhere((shop) => shop.id == shopId);
    } catch (e) {
      return null;
    }
  }

  void sortByDistance() {
    _filteredShops.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    notifyListeners();
  }

  void sortByRating() {
    _filteredShops.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }
}
