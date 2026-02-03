import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/order.dart' as models;
import '../data/models/order_item.dart';

class OrderViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<models.Order> _orders = [];
  models.Order? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<models.Order> get orders => List.unmodifiable(_orders);
  models.Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<models.Order?> createOrder({
    required List<OrderItem> items,
    required String shopId,
    double taxes = 0,
    double serviceFees = 0,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User must be authenticated to create an order';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
      final totalPrice = subtotal + taxes + serviceFees;

      final order = models.Order(
        id: '',
        items: items,
        taxes: taxes,
        totalPrice: totalPrice,
        status: models.OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final orderMap = {
        'userId': userId,
        'shopId': shopId,
        'items': items.map((item) => item.toMap()).toList(),
        'taxes': taxes,
        'totalPrice': totalPrice,
        'status': order.status.name,
        'createdAt': order.createdAt.toIso8601String(),
      };

      final docRef = await _firestore.collection('orders').add(orderMap);

      final createdOrder = order.copyWith(id: docRef.id);

      _orders.insert(0, createdOrder);
      _currentOrder = createdOrder;
      _isLoading = false;
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<models.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return null;

      return _orderFromFirestore(doc);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrderStatus(
    String orderId,
    models.OrderStatus status,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: status);
        if (_currentOrder?.id == orderId) {
          _currentOrder = _orders[index];
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadOrders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _orders.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      _orders.clear();
      for (var doc in querySnapshot.docs) {
        final order = _orderFromFirestore(doc);
        if (order != null) {
          _orders.add(order);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  models.Order? _orderFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return models.Order(
        id: doc.id,
        items:
            (data['items'] as List<dynamic>)
                .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
                .toList(),
        taxes: ((data['taxes'] ?? 0) as num).toDouble(),
        totalPrice: ((data['totalPrice'] ?? 0) as num).toDouble(),
        status: _statusFromString(data['status'] as String?),
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  models.OrderStatus _statusFromString(String? value) {
    return models.OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => models.OrderStatus.pending,
    );
  }

  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, models.OrderStatus.cancelled);
  }

  List<models.Order> getOrdersByStatus(models.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<models.Order> get pendingOrders =>
      getOrdersByStatus(models.OrderStatus.pending);

  List<models.Order> get completedOrders =>
      getOrdersByStatus(models.OrderStatus.completed);


  void setCurrentOrder(models.Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}
