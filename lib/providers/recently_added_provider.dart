import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/recently_added_service.dart';
import '../services/error_service.dart';

class RecentlyAddedProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  AppError? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  Future<void> loadRecentlyAddedProducts({int limit = 6}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final productsData = await RecentlyAddedService.getRecentlyAddedProducts(limit: limit);
      
      _products = productsData.map((data) => ProductModel.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
      
      debugPrint('✅ Loaded ${_products.length} recently added products');
    } catch (e) {
      _isLoading = false;
      if (e is AppError) {
        _error = e;
      } else {
        _error = createError(ErrorCode.unknown, details: e.toString());
      }
      notifyListeners();
      debugPrint('❌ Error loading recently added products: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
