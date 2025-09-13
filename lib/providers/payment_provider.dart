import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class PaymentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _paymentMethods.isEmpty;

  // Load payment methods from backend
  Future<void> loadPaymentMethods() async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view payment methods');
      }

      final methods = await PaymentService.getMyPaymentMethods(token: token);
      _paymentMethods = methods;
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load payment methods: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  // Add payment method
  Future<bool> addPaymentMethod({
    required String paymentType,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    required String cardHolderName,
    bool isDefault = false,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to add payment method');
      }

      final result = await PaymentService.addPaymentMethod(
        token: token,
        paymentType: paymentType,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardHolderName: cardHolderName,
        isDefault: isDefault,
      );

      if (result != null) {
        // Reload payment methods to get updated list
        await loadPaymentMethods();
        setLoading(false);
        return true;
      }
      
      setLoading(false);
      return false;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to add payment method: ${e.toString()}');
      }
      setLoading(false);
      return false;
    }
  }

  // Update payment method
  Future<bool> updatePaymentMethod({
    required String paymentMethodId,
    bool? isDefault,
    bool? isActive,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to update payment method');
      }

      final success = await PaymentService.updatePaymentMethod(
        token: token,
        paymentMethodId: paymentMethodId,
        isDefault: isDefault,
        isActive: isActive,
      );

      if (success) {
        // Reload payment methods to get updated list
        await loadPaymentMethods();
        setLoading(false);
        return true;
      }
      
      setLoading(false);
      return false;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to update payment method: ${e.toString()}');
      }
      setLoading(false);
      return false;
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to delete payment method');
      }

      final success = await PaymentService.deletePaymentMethod(
        token: token,
        paymentMethodId: paymentMethodId,
      );

      if (success) {
        // Remove from local list
        _paymentMethods.removeWhere((method) => method['id'] == paymentMethodId);
        notifyListeners();
        setLoading(false);
        return true;
      }
      
      setLoading(false);
      return false;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to delete payment method: ${e.toString()}');
      }
      setLoading(false);
      return false;
    }
  }

  // Set default payment method
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    return await updatePaymentMethod(
      paymentMethodId: paymentMethodId,
      isDefault: true,
    );
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Get default payment method
  Map<String, dynamic>? get defaultPaymentMethod {
    try {
      return _paymentMethods.firstWhere(
        (method) => method['isDefault'] == true,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if payment method exists
  bool hasPaymentMethod(String paymentMethodId) {
    return _paymentMethods.any((method) => method['id'] == paymentMethodId);
  }
}
