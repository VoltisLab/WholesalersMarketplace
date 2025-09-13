import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/wishlist_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<ProductModel> _wishlistItems = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _wishlistItems.isEmpty;
  bool get isNotEmpty => _wishlistItems.isNotEmpty;
  int get itemCount => _wishlistItems.length;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view wishlist');
      }

      final wishlistData = await WishlistService.getMyWishlist(token);
      _wishlistItems = wishlistData.map((item) => ProductModel.fromJson(item['product'] ?? {})).toList();
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load wishlist: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> addToWishlist(ProductModel product) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to add to wishlist');
      }

      await WishlistService.addToWishlist(
        token: token,
        productId: product.id,
      );

      // Add to local list
      if (!isInWishlist(product.id)) {
        _wishlistItems.add(product);
        notifyListeners();
      }
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to add to wishlist: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to remove from wishlist');
      }

      await WishlistService.removeFromWishlist(
        token: token,
        productId: productId,
      );

      // Remove from local list
      _wishlistItems.removeWhere((item) => item.id == productId);
      notifyListeners();
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to remove from wishlist: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  Future<bool> checkWishlistStatus(String productId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return false;
      
      return await WishlistService.isInWishlist(
        token: token,
        productId: productId,
      );
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
      return false;
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}