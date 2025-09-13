import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;

  // Getters
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;

  // Filtered orders based on selected status
  List<Map<String, dynamic>> get filteredOrders {
    if (_selectedStatus == null || _selectedStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => 
      order['status']?.toLowerCase() == _selectedStatus!.toLowerCase()
    ).toList();
  }

  // Order statistics
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((order) => order['status'] == 'pending').length;
  int get processingOrders => _orders.where((order) => order['status'] == 'processing').length;
  int get shippedOrders => _orders.where((order) => order['status'] == 'shipped').length;
  int get deliveredOrders => _orders.where((order) => order['status'] == 'delivered').length;
  int get cancelledOrders => _orders.where((order) => order['status'] == 'cancelled').length;

  // Load orders from backend
  Future<void> loadOrders({String? status}) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view orders');
      }

      debugPrint('🔄 Loading orders from backend...');
      
      final ordersData = await OrderService.getMyOrders(
        token: token,
        status: status,
      );
      
      _orders = ordersData;
      _selectedStatus = status;
      
      debugPrint('✅ Loaded ${_orders.length} orders');
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load orders: ${e.toString()}');
      }
    } finally {
      setLoading(false);
    }
  }

  // Filter orders by status
  void filterByStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Get order by ID
  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(status: _selectedStatus);
  }

  // Create new order
  Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to create order');
      }

      debugPrint('🔄 Creating new order...');
      
      final orderData = await OrderService.createOrder(
        token: token,
        orderData: {
          'shippingAddress': shippingAddress,
          'billingAddress': billingAddress,
          'paymentMethod': paymentMethod,
          'notes': notes,
        },
        items: items,
      );
      
      if (orderData != null) {
        // Add the new order to the list
        _orders.insert(0, orderData);
        notifyListeners();
      }
      
      debugPrint('✅ Order created successfully');
      return orderData;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to create order: ${e.toString()}');
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to cancel order');
      }

      debugPrint('🔄 Cancelling order: $orderId');
      
      final success = await OrderService.cancelOrder(
        token: token,
        orderId: orderId,
      );
      
      if (success) {
        // Update the order status in the list
        final orderIndex = _orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex]['status'] = 'cancelled';
          notifyListeners();
        }
      }
      
      debugPrint('✅ Order cancelled successfully');
      return success;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to cancel order: ${e.toString()}');
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Track order
  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to track order');
      }

      debugPrint('🔄 Tracking order: $orderId');
      
      // TODO: Implement trackOrder method in OrderService
      // final trackingData = await OrderService.trackOrder(
      //   token: token,
      //   orderId: orderId,
      // );
      
      debugPrint('✅ Order tracking data retrieved');
      return null; // TODO: Return actual tracking data when method is implemented
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to track order: ${e.toString()}');
      }
      return null;
    }
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get order status color
  Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get order status icon
  IconData getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }
}

