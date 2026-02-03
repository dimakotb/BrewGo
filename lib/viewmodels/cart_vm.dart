import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/cart_item.dart';
import '../data/models/menu_item.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _taxes = 0.0;
  double _serviceFees = 0.0;
  static const String _cartBoxName = 'cart_box';
  Box<CartItem>? _cartBox;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get taxes => _taxes;
  double get serviceFees => _serviceFees;
  double get total => subtotal + _taxes + _serviceFees;
  bool get isEmpty => _items.isEmpty;

  /// Initialize Hive box for cart storage.
  Future<void> _initHiveBox() async {
    if (_cartBox == null || !_cartBox!.isOpen) {
      _cartBox = await Hive.openBox<CartItem>(_cartBoxName);
    }
  }

  /// Load cart from local storage.
  Future<void> loadCart() async {
    try {
      await _initHiveBox();
      if (_cartBox != null) {
        _items.clear();
        _items.addAll(_cartBox!.values);
        _calculateFees();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      await _initHiveBox();
      if (_cartBox != null) {
        await _cartBox!.clear();
        for (int i = 0; i < _items.length; i++) {
          await _cartBox!.put(i, _items[i]);
        }
      }
    } catch (e) {
      // Silently fail - cart will still work in memory
      debugPrint('Error saving cart: $e');
    }
  }

  /// Add an item to the cart. If item already exists, increment quantity.
  void addItem(MenuItem item, {int quantity = 1, String? note}) {
    final existingIndex = _items.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex >= 0) {
      // Item already in cart, increment quantity
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        note: note ?? existingItem.note,
      );
    } else {
      _items.add(CartItem(item: item, quantity: quantity, note: note));
    }

    _calculateFees();
    _saveCart();
    notifyListeners();
  }

  /// Remove an item from the cart.
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.item.id == itemId);
    _calculateFees();
    _saveCart();
    notifyListeners();
  }

  /// Update the quantity of an item in the cart.
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _calculateFees();
      _saveCart();
      notifyListeners();
    }
  }

  void updateNote(String itemId, String? note) {
    final index = _items.indexWhere((item) => item.item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(note: note);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _calculateFees();
    _saveCart();
    notifyListeners();
  }

  CartItem? getItem(String itemId) {
    try {
      return _items.firstWhere((item) => item.item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate taxes and service fees.
  void _calculateFees() {
    _taxes = subtotal * 0.14;
    _serviceFees = 20.0;
  }

  void setFees({double? taxes, double? serviceFees}) {
    if (taxes != null) _taxes = taxes;
    if (serviceFees != null) _serviceFees = serviceFees;
    notifyListeners();
  }


  @override
  void dispose() {
    _cartBox?.close();
    super.dispose();
  }
}
