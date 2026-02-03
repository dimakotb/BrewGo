import 'package:flutter/foundation.dart';
import '/data/models/order.dart';

class PaymentViewModel extends ChangeNotifier {
  Order? _currentOrder;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _paymentSuccess = false;

  Order? get currentOrder => _currentOrder;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get paymentSuccess => _paymentSuccess;

  void initializePayment(Order order) {
    _currentOrder = order;
    _paymentSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<bool> processPayment({
    required String paymentMethod,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
  }) async {
    if (_currentOrder == null) {
      _errorMessage = 'No order to process';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    _paymentSuccess = false;
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); 


        _paymentSuccess = true;
        _isProcessing = false;
        notifyListeners();
        return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }


  void clearPayment() {
    _currentOrder = null;
    _selectedPaymentMethod = null;
    _isProcessing = false;
    _errorMessage = null;
    _paymentSuccess = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

