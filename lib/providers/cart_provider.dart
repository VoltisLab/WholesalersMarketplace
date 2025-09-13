import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class CartItem {
  final String id;
  final ProductModel product;
  final int quantity;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;
  int _totalItems = 0;
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  List<CartItem> get items => _cartItems; // Alias for compatibility
  double get totalAmount => _totalAmount;
  int get totalItems => _totalItems;
  int get itemCount => _totalItems; // Alias for compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cartItems.isEmpty;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadCart() async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view cart');
      }

      final cartData = await CartService.getMyCart(token);
      if (cartData != null) {
        final items = cartData['items'] as List? ?? [];
        _cartItems = items.map((item) => CartItem.fromJson(item)).toList();
        _totalAmount = (cartData['totalAmount'] ?? 0.0).toDouble();
        _totalItems = cartData['totalItems'] ?? 0;
      }
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load cart: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to add to cart');
      }

      await CartService.addToCart(
        token: token,
        productId: product.id,
        quantity: quantity,
      );

      // Reload cart to get updated data
      await loadCart();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to add to cart: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to update cart');
      }

      await CartService.updateCartItem(
        token: token,
        cartItemId: cartItemId,
        quantity: quantity,
      );

      // Reload cart to get updated data
      await loadCart();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to update quantity: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to remove from cart');
      }

      await CartService.removeFromCart(
        token: token,
        cartItemId: cartItemId,
      );

      // Reload cart to get updated data
      await loadCart();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to remove from cart: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> clearCart() async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to clear cart');
      }

      await CartService.clearCart(token);
      _cartItems.clear();
      _totalAmount = 0.0;
      _totalItems = 0;
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to clear cart: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  CartItem? getCartItemByProductId(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  bool isInCart(String productId) {
    return getCartItemByProductId(productId) != null;
  }

  int getQuantityForProduct(String productId) {
    final item = getCartItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  // Additional methods for compatibility with cart screen
  Map<String, List<CartItem>> get itemsByVendor {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _cartItems) {
      final vendorId = item.product.vendor?.id ?? 'unknown';
      if (!grouped.containsKey(vendorId)) {
        grouped[vendorId] = [];
      }
      grouped[vendorId]!.add(item);
    }
    return grouped;
  }

  double getVendorTotal(String vendorId) {
    final vendorItems = itemsByVendor[vendorId] ?? [];
    return vendorItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void incrementQuantity(String cartItemId) {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    updateQuantity(cartItemId, item.quantity + 1);
  }

  void decrementQuantity(String cartItemId) {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    if (item.quantity > 1) {
      updateQuantity(cartItemId, item.quantity - 1);
    } else {
      removeFromCart(cartItemId);
    }
  }

  void removeItem(String cartItemId) {
    removeFromCart(cartItemId);
  }

  void addItem(ProductModel product, {int quantity = 1}) {
    addToCart(product, quantity: quantity);
  }

  int getQuantity(String productId) {
    return getQuantityForProduct(productId);
  }
}