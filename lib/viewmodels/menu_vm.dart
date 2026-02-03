import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/menu_item.dart';
import '../data/models/shop.dart';

class MenuViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Shop? _currentShop;
  List<MenuItem> _allMenuItems = [];
  List<MenuItem> _filteredMenuItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  Shop? get currentShop => _currentShop;
  List<MenuItem> get menuItems => List.unmodifiable(_filteredMenuItems);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setShop(Shop shop) async {
    _currentShop = shop;
    await loadMenu(shop.id);
  }

  /// Load menu items for a shop from Firestore (READ ONLY).
  Future<void> loadMenu(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch menu items from Firestore
      final querySnapshot =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('menuItems')
              .get();

      final totalDocs = querySnapshot.docs.length;
      debugPrint('Found $totalDocs menu item documents in Firestore');

      _allMenuItems =
          querySnapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  data['id'] = doc.id;  
                  final menuItem = MenuItem.fromMap(data);
                  debugPrint('Successfully parsed menu item: ${menuItem.name} (${doc.id})');
                  return menuItem;
                } catch (e, stackTrace) {
                  debugPrint('❌ Error parsing menu item ${doc.id}: $e');
                  debugPrint('Stack trace: $stackTrace');
                  debugPrint('Raw data: ${doc.data()}');
                  return null;
                }
              })
              .whereType<MenuItem>()
              .toList();

      debugPrint('✅ Successfully loaded ${_allMenuItems.length} out of $totalDocs menu items from Firestore');
      if (_allMenuItems.length < totalDocs) {
        debugPrint('⚠️ WARNING: ${totalDocs - _allMenuItems.length} menu item(s) failed to parse and were skipped!');
      }

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load menu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchMenu(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMenuItems = List.from(_allMenuItems);

    if (_selectedCategory == 'All') {
      // Show all items - no filtering
      debugPrint(
        'Showing all items: ${_allMenuItems.length} total',
      );
    } else if (_selectedCategory == 'Best sellers') {
      // Show items with rating >= 4.5 for "Best sellers"
      final beforeCount = _filteredMenuItems.length;
      _filteredMenuItems =
          _allMenuItems.where((item) => item.rating >= 4.5).toList();
      debugPrint(
        'Best sellers filter: ${_allMenuItems.length} total, ${_filteredMenuItems.length} filtered (${beforeCount - _filteredMenuItems.length} items hidden due to rating < 4.5)',
      );
    } else {
      // Filter by name containing category keywords
      final categoryKeywords = _selectedCategory.toLowerCase();
      final beforeCount = _filteredMenuItems.length;
      _filteredMenuItems =
          _allMenuItems.where((item) {
            return item.name.toLowerCase().contains(categoryKeywords) ||
                item.description.toLowerCase().contains(categoryKeywords);
          }).toList();
      debugPrint(
        'Category filter "$_selectedCategory": ${_allMenuItems.length} total, ${_filteredMenuItems.length} filtered (${beforeCount - _filteredMenuItems.length} items hidden)',
      );
    }

    if (_searchQuery.isNotEmpty) {
      _filteredMenuItems =
          _filteredMenuItems.where((item) {
            return item.name.toLowerCase().contains(_searchQuery) ||
                item.description.toLowerCase().contains(_searchQuery);
          }).toList();
      debugPrint(
        'Search filter "$_searchQuery": ${_filteredMenuItems.length} results',
      );
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  MenuItem? getMenuItemById(String itemId) {
    try {
      return _allMenuItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    if (_currentShop != null) {
      await loadMenu(_currentShop!.id);
    }
  }
}
