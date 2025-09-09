import 'package:flutter/material.dart';
import '../models/product_model.dart';

class EnhancedProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ProductModel> get filteredProducts {
    List<ProductModel> filtered = _products;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.vendor.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate 1000 products (20 per vendor for 50 vendors)
      _products = _generateMockProducts();
      _featuredProducts = _products.where((product) => product.isFeatured).toList();
      _categories = ['All', ...{..._products.map((product) => product.category)}];
      
      setLoading(false);
    } catch (e) {
      setError('Failed to load products: ${e.toString()}');
      setLoading(false);
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> getProductsByVendor(String vendorId) {
    return _products.where((product) => product.vendor.id == vendorId).toList();
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<ProductModel> _generateMockProducts() {
    final List<ProductModel> allProducts = [];
    
    // Generate 20 products for each of the 50 vendors
    for (int vendorIndex = 1; vendorIndex <= 50; vendorIndex++) {
      final vendor = _createVendorForProducts(vendorIndex);
      
      for (int productIndex = 1; productIndex <= 20; productIndex++) {
        final productId = '${vendorIndex}_$productIndex';
        final product = _createProductForVendor(productId, vendor, productIndex);
        allProducts.add(product);
      }
    }
    
    return allProducts;
  }

  VendorModel _createVendorForProducts(int vendorIndex) {
    final vendorData = _getVendorData(vendorIndex);
    
    return VendorModel(
      id: vendorIndex.toString(),
      name: vendorData['name'],
      description: 'Premium ${vendorData['category'].toLowerCase()} products and services.',
      logo: 'https://picsum.photos/80/80?random=${vendorIndex + 500}',
      email: '${vendorData['name'].toLowerCase().replaceAll(' ', '').replaceAll('&', '')}@example.com',
      phone: '+1 (555) ${(100 + vendorIndex).toString().padLeft(3, '0')}-${(1000 + vendorIndex * 7).toString().padLeft(4, '0')}',
      address: AddressModel(
        id: vendorIndex.toString(),
        street: '${100 + vendorIndex * 10} ${vendorData['category']} Street',
        city: vendorData['city'],
        state: 'CA',
        zipCode: '${10000 + vendorIndex * 100}',
        country: 'USA',
      ),
      rating: vendorData['rating'].toDouble(),
      reviewCount: vendorData['reviews'],
      isVerified: vendorIndex % 3 == 0,
      createdAt: DateTime.now().subtract(Duration(days: 30 + vendorIndex * 10)),
      categories: [vendorData['category']],
    );
  }

  ProductModel _createProductForVendor(String productId, VendorModel vendor, int productIndex) {
    final productData = _getProductDataForCategory(vendor.categories.first, productIndex);
    final basePrice = productData['basePrice'] + (productIndex * 10.0);
    final hasDiscount = productIndex % 4 == 0;
    
    return ProductModel(
      id: productId,
      name: productData['name'],
      description: productData['description'],
      price: basePrice,
      discountPrice: hasDiscount ? basePrice * 0.8 : null,
      images: _getProductImages(vendor.categories.first, productIndex),
      category: vendor.categories.first,
      subcategory: productData['subcategory'],
      vendor: vendor,
      stockQuantity: 10 + (productIndex * 2),
      rating: 3.5 + (productIndex % 5) * 0.3,
      reviewCount: 50 + (productIndex * 15),
      tags: productData['tags'],
      isFeatured: productIndex <= 3, // First 3 products are featured
      createdAt: DateTime.now().subtract(Duration(days: productIndex * 5)),
      updatedAt: DateTime.now().subtract(Duration(days: productIndex)),
    );
  }

  Map<String, dynamic> _getVendorData(int index) {
    final vendorData = [
      {'name': 'TechStore Pro', 'category': 'Electronics', 'city': 'San Francisco', 'rating': 4.8, 'reviews': 1250},
      {'name': 'Fashion Hub', 'category': 'Fashion', 'city': 'New York', 'rating': 4.6, 'reviews': 890},
      {'name': 'Home & Garden Paradise', 'category': 'Home', 'city': 'Austin', 'rating': 4.4, 'reviews': 567},
      {'name': 'Sports Central', 'category': 'Sports', 'city': 'Denver', 'rating': 4.7, 'reviews': 423},
      {'name': 'Book Haven', 'category': 'Books', 'city': 'Boston', 'rating': 4.5, 'reviews': 789},
      {'name': 'Beauty Bliss', 'category': 'Beauty', 'city': 'Los Angeles', 'rating': 4.9, 'reviews': 1100},
      {'name': 'Auto Parts Plus', 'category': 'Automotive', 'city': 'Detroit', 'rating': 4.3, 'reviews': 654},
      {'name': 'Pet Paradise', 'category': 'Pets', 'city': 'Miami', 'rating': 4.7, 'reviews': 432},
      {'name': 'Music World', 'category': 'Music', 'city': 'Nashville', 'rating': 4.6, 'reviews': 876},
      {'name': 'Kitchen Masters', 'category': 'Kitchen', 'city': 'Chicago', 'rating': 4.5, 'reviews': 543},
      {'name': 'Toy Kingdom', 'category': 'Toys', 'city': 'Orlando', 'rating': 4.8, 'reviews': 765},
      {'name': 'Office Supplies Co', 'category': 'Office', 'city': 'Seattle', 'rating': 4.2, 'reviews': 321},
      {'name': 'Jewelry Boutique', 'category': 'Jewelry', 'city': 'Las Vegas', 'rating': 4.9, 'reviews': 987},
      {'name': 'Craft Corner', 'category': 'Crafts', 'city': 'Portland', 'rating': 4.4, 'reviews': 234},
      {'name': 'Health Plus', 'category': 'Health', 'city': 'Phoenix', 'rating': 4.6, 'reviews': 678},
      {'name': 'Baby World', 'category': 'Baby', 'city': 'Atlanta', 'rating': 4.7, 'reviews': 456},
      {'name': 'Outdoor Adventures', 'category': 'Outdoor', 'city': 'Colorado Springs', 'rating': 4.8, 'reviews': 789},
      {'name': 'Gaming Zone', 'category': 'Gaming', 'city': 'San Jose', 'rating': 4.5, 'reviews': 543},
      {'name': 'Art Supplies Store', 'category': 'Art', 'city': 'Santa Fe', 'rating': 4.3, 'reviews': 321},
      {'name': 'Travel Gear', 'category': 'Travel', 'city': 'San Diego', 'rating': 4.6, 'reviews': 654},
      {'name': 'Vintage Finds', 'category': 'Vintage', 'city': 'Charleston', 'rating': 4.4, 'reviews': 432},
      {'name': 'Tech Gadgets', 'category': 'Electronics', 'city': 'Palo Alto', 'rating': 4.7, 'reviews': 876},
      {'name': 'Fashion Forward', 'category': 'Fashion', 'city': 'Beverly Hills', 'rating': 4.8, 'reviews': 765},
      {'name': 'Green Thumb', 'category': 'Garden', 'city': 'Portland', 'rating': 4.5, 'reviews': 543},
      {'name': 'Fitness First', 'category': 'Fitness', 'city': 'Miami Beach', 'rating': 4.6, 'reviews': 678},
      {'name': 'Book Nook', 'category': 'Books', 'city': 'Cambridge', 'rating': 4.4, 'reviews': 456},
      {'name': 'Beauty Bar', 'category': 'Beauty', 'city': 'Hollywood', 'rating': 4.9, 'reviews': 987},
      {'name': 'Car Care', 'category': 'Automotive', 'city': 'Indianapolis', 'rating': 4.3, 'reviews': 321},
      {'name': 'Pet Care Plus', 'category': 'Pets', 'city': 'Tampa', 'rating': 4.7, 'reviews': 654},
      {'name': 'Sound Studio', 'category': 'Music', 'city': 'Memphis', 'rating': 4.5, 'reviews': 432},
      {'name': 'Gourmet Kitchen', 'category': 'Kitchen', 'city': 'New Orleans', 'rating': 4.8, 'reviews': 789},
      {'name': 'Fun Zone', 'category': 'Toys', 'city': 'Disney World', 'rating': 4.6, 'reviews': 876},
      {'name': 'Business Solutions', 'category': 'Office', 'city': 'Dallas', 'rating': 4.2, 'reviews': 543},
      {'name': 'Diamond District', 'category': 'Jewelry', 'city': 'New York', 'rating': 4.9, 'reviews': 765},
      {'name': 'Creative Crafts', 'category': 'Crafts', 'city': 'Asheville', 'rating': 4.4, 'reviews': 321},
      {'name': 'Wellness Center', 'category': 'Health', 'city': 'Scottsdale', 'rating': 4.7, 'reviews': 654},
      {'name': 'Little Angels', 'category': 'Baby', 'city': 'Savannah', 'rating': 4.8, 'reviews': 432},
      {'name': 'Adventure Gear', 'category': 'Outdoor', 'city': 'Boulder', 'rating': 4.5, 'reviews': 789},
      {'name': 'Game Central', 'category': 'Gaming', 'city': 'Austin', 'rating': 4.6, 'reviews': 876},
      {'name': 'Artist Studio', 'category': 'Art', 'city': 'Taos', 'rating': 4.3, 'reviews': 543},
      {'name': 'Journey Essentials', 'category': 'Travel', 'city': 'Honolulu', 'rating': 4.7, 'reviews': 765},
      {'name': 'Retro Revival', 'category': 'Vintage', 'city': 'Savannah', 'rating': 4.4, 'reviews': 321},
      {'name': 'Smart Solutions', 'category': 'Electronics', 'city': 'Silicon Valley', 'rating': 4.8, 'reviews': 987},
      {'name': 'Style Studio', 'category': 'Fashion', 'city': 'Milan District', 'rating': 4.9, 'reviews': 654},
      {'name': 'Garden Oasis', 'category': 'Garden', 'city': 'Napa Valley', 'rating': 4.5, 'reviews': 432},
      {'name': 'Power Gym', 'category': 'Fitness', 'city': 'Venice Beach', 'rating': 4.6, 'reviews': 789},
      {'name': 'Literary Lounge', 'category': 'Books', 'city': 'Harvard Square', 'rating': 4.4, 'reviews': 876},
      {'name': 'Glamour Gallery', 'category': 'Beauty', 'city': 'Rodeo Drive', 'rating': 4.9, 'reviews': 543},
      {'name': 'Speed Shop', 'category': 'Automotive', 'city': 'Daytona', 'rating': 4.3, 'reviews': 765},
      {'name': 'Furry Friends', 'category': 'Pets', 'city': 'Key West', 'rating': 4.7, 'reviews': 321},
    ];
    
    return vendorData[(index - 1) % vendorData.length];
  }

  List<String> _getProductImages(String category, int productIndex) {
    // Using Picsum for working square images (300x300)
    final imageId1 = (100 + productIndex * 7) % 1000 + 100;
    final imageId2 = (200 + productIndex * 11) % 1000 + 100;
    final imageId3 = (300 + productIndex * 13) % 1000 + 100;
    final imageId4 = (400 + productIndex * 17) % 1000 + 100;
    final imageId5 = (500 + productIndex * 19) % 1000 + 100;
    
    return [
      'https://picsum.photos/300/300?random=$imageId1',
      'https://picsum.photos/300/300?random=$imageId2',
      'https://picsum.photos/300/300?random=$imageId3',
      'https://picsum.photos/300/300?random=$imageId4',
      'https://picsum.photos/300/300?random=$imageId5',
    ];
  }

  Map<String, dynamic> _getProductDataForCategory(String category, int productIndex) {
    final productTemplates = {
      'Fashion': [
        {'name': 'Designer Dress', 'description': 'Elegant dress for special occasions', 'basePrice': 149.0, 'subcategory': 'Dresses', 'tags': ['dress', 'elegant', 'fashion']},
        {'name': 'Leather Jacket', 'description': 'Premium leather jacket with modern style', 'basePrice': 249.0, 'subcategory': 'Outerwear', 'tags': ['jacket', 'leather', 'style']},
        {'name': 'Designer Handbag', 'description': 'Luxury handbag with premium materials', 'basePrice': 199.0, 'subcategory': 'Bags', 'tags': ['handbag', 'luxury', 'accessories']},
        {'name': 'Running Shoes', 'description': 'Comfortable athletic shoes for running', 'basePrice': 129.0, 'subcategory': 'Shoes', 'tags': ['shoes', 'running', 'athletic']},
        {'name': 'Silk Scarf', 'description': 'Premium silk scarf with unique patterns', 'basePrice': 79.0, 'subcategory': 'Accessories', 'tags': ['scarf', 'silk', 'accessories']},
        {'name': 'Cotton T-Shirt', 'description': 'Comfortable cotton t-shirt for everyday wear', 'basePrice': 29.0, 'subcategory': 'Tops', 'tags': ['tshirt', 'cotton', 'casual']},
        {'name': 'Denim Jeans', 'description': 'Classic denim jeans with perfect fit', 'basePrice': 89.0, 'subcategory': 'Bottoms', 'tags': ['jeans', 'denim', 'casual']},
        {'name': 'Evening Gown', 'description': 'Stunning evening gown for formal events', 'basePrice': 299.0, 'subcategory': 'Formal', 'tags': ['gown', 'formal', 'elegant']},
        {'name': 'Casual Sneakers', 'description': 'Comfortable sneakers for daily wear', 'basePrice': 79.0, 'subcategory': 'Footwear', 'tags': ['sneakers', 'casual', 'comfort']},
        {'name': 'Winter Coat', 'description': 'Warm winter coat for cold weather', 'basePrice': 199.0, 'subcategory': 'Outerwear', 'tags': ['coat', 'winter', 'warm']},
      ],
    };

    final defaultTemplate = [
      {'name': 'Premium Product', 'description': 'High-quality product with excellent features', 'basePrice': 99.0, 'subcategory': 'General', 'tags': ['premium', 'quality', 'product']},
      {'name': 'Essential Item', 'description': 'Must-have item for everyday use', 'basePrice': 49.0, 'subcategory': 'General', 'tags': ['essential', 'everyday', 'useful']},
      {'name': 'Deluxe Edition', 'description': 'Deluxe version with extra features', 'basePrice': 149.0, 'subcategory': 'General', 'tags': ['deluxe', 'premium', 'features']},
      {'name': 'Starter Kit', 'description': 'Perfect starter kit for beginners', 'basePrice': 79.0, 'subcategory': 'General', 'tags': ['starter', 'beginner', 'kit']},
      {'name': 'Professional Grade', 'description': 'Professional-grade quality and performance', 'basePrice': 199.0, 'subcategory': 'General', 'tags': ['professional', 'quality', 'performance']},
    ];

    final templates = productTemplates[category] ?? defaultTemplate;
    final template = templates[(productIndex - 1) % templates.length];
    
    return {
      'name': '${template['name']} ${String.fromCharCode(65 + ((productIndex - 1) ~/ templates.length))}',
      'description': template['description'],
      'basePrice': template['basePrice'],
      'subcategory': template['subcategory'],
      'tags': template['tags'],
    };
  }
}
