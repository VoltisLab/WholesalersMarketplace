import 'package:flutter/material.dart';
import '../models/product_model.dart';

class VendorProvider extends ChangeNotifier {
  List<VendorModel> _vendors = [];
  bool _isLoading = false;
  String? _error;

  List<VendorModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadVendors() async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _vendors = _generateMockVendors();
      
      setLoading(false);
    } catch (e) {
      setError('Failed to load vendors: ${e.toString()}');
      setLoading(false);
    }
  }

  VendorModel? getVendorById(String id) {
    try {
      return _vendors.firstWhere((vendor) => vendor.id == id);
    } catch (e) {
      return null;
    }
  }

  List<VendorModel> getVendorsByCategory(String category) {
    return _vendors.where((vendor) => vendor.categories.contains(category)).toList();
  }

  List<VendorModel> searchVendors(String query) {
    return _vendors.where((vendor) => 
      vendor.name.toLowerCase().contains(query.toLowerCase()) ||
      vendor.description.toLowerCase().contains(query.toLowerCase()) ||
      vendor.categories.any((category) => 
        category.toLowerCase().contains(query.toLowerCase())
      )
    ).toList();
  }

  List<VendorModel> _generateMockVendors() {
    final List<Map<String, dynamic>> vendorData = [
      {'name': 'TechStore Pro', 'category': 'Electronics', 'city': 'Pakistan', 'rating': 4.8, 'reviews': 1250},
      {'name': 'Fashion Hub', 'category': 'Fashion', 'city': 'India', 'rating': 4.6, 'reviews': 890},
      {'name': 'Home & Garden Paradise', 'category': 'Home', 'city': 'China', 'rating': 4.4, 'reviews': 567},
      {'name': 'Sports Central', 'category': 'Sports', 'city': 'Austria', 'rating': 4.7, 'reviews': 423},
      {'name': 'Book Haven', 'category': 'Books', 'city': 'Germany', 'rating': 4.5, 'reviews': 789},
      {'name': 'Beauty Bliss', 'category': 'Beauty', 'city': 'Turkey', 'rating': 4.9, 'reviews': 1100},
      {'name': 'Auto Parts Plus', 'category': 'Automotive', 'city': 'Italy', 'rating': 4.3, 'reviews': 654},
      {'name': 'Pet Paradise', 'category': 'Pets', 'city': 'Spain', 'rating': 4.7, 'reviews': 432},
      {'name': 'Music World', 'category': 'Music', 'city': 'France', 'rating': 4.6, 'reviews': 876},
      {'name': 'Kitchen Masters', 'category': 'Kitchen', 'city': 'Netherlands', 'rating': 4.5, 'reviews': 543},
      {'name': 'Toy Kingdom', 'category': 'Toys', 'city': 'Belgium', 'rating': 4.8, 'reviews': 765},
      {'name': 'Office Supplies Co', 'category': 'Office', 'city': 'Switzerland', 'rating': 4.2, 'reviews': 321},
      {'name': 'Jewelry Boutique', 'category': 'Jewelry', 'city': 'Poland', 'rating': 4.9, 'reviews': 987},
      {'name': 'Craft Corner', 'category': 'Crafts', 'city': 'Czech Republic', 'rating': 4.4, 'reviews': 234},
      {'name': 'Health Plus', 'category': 'Health', 'city': 'Hungary', 'rating': 4.6, 'reviews': 678},
      {'name': 'Baby World', 'category': 'Baby', 'city': 'Romania', 'rating': 4.7, 'reviews': 456},
      {'name': 'Outdoor Adventures', 'category': 'Outdoor', 'city': 'Bulgaria', 'rating': 4.8, 'reviews': 789},
      {'name': 'Gaming Zone', 'category': 'Gaming', 'city': 'Greece', 'rating': 4.5, 'reviews': 543},
      {'name': 'Art Supplies Store', 'category': 'Art', 'city': 'Portugal', 'rating': 4.3, 'reviews': 321},
      {'name': 'Travel Gear', 'category': 'Travel', 'city': 'Croatia', 'rating': 4.6, 'reviews': 654},
      {'name': 'Vintage Finds', 'category': 'Vintage', 'city': 'Slovenia', 'rating': 4.4, 'reviews': 432},
      {'name': 'Tech Gadgets', 'category': 'Electronics', 'city': 'Slovakia', 'rating': 4.7, 'reviews': 876},
      {'name': 'Fashion Forward', 'category': 'Fashion', 'city': 'Lithuania', 'rating': 4.8, 'reviews': 765},
      {'name': 'Green Thumb', 'category': 'Garden', 'city': 'Latvia', 'rating': 4.5, 'reviews': 543},
      {'name': 'Fitness First', 'category': 'Fitness', 'city': 'Estonia', 'rating': 4.6, 'reviews': 678},
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

    return List.generate(50, (index) {
      final data = vendorData[index];
      final vendorId = (index + 1).toString();
      
      return VendorModel(
        id: vendorId,
        name: data['name'],
        description: 'Premium ${data['category'].toLowerCase()} products and services. Quality guaranteed with excellent customer service.',
        logo: 'https://picsum.photos/80/80?random=${index + 500}',
        email: '${data['name'].toLowerCase().replaceAll(' ', '').replaceAll('&', '')}@example.com',
        phone: '+1 (555) ${(100 + index).toString().padLeft(3, '0')}-${(1000 + index * 7).toString().padLeft(4, '0')}',
        address: AddressModel(
          id: vendorId,
          street: '${100 + index * 10} ${data['category']} Street',
          city: data['city'],
          state: _getStateFromCity(data['city']),
          zipCode: '${10000 + index * 100}',
          country: 'USA',
          latitude: 37.7749 + (index * 0.1) - 2.5,
          longitude: -122.4194 + (index * 0.1) - 2.5,
        ),
        rating: data['rating'].toDouble(),
        reviewCount: data['reviews'],
        isVerified: index % 3 == 0, // Every 3rd vendor is verified
        createdAt: DateTime.now().subtract(Duration(days: 30 + index * 10)),
        categories: [data['category'], 'General'],
      );
    });
  }

  String _getStateFromCity(String city) {
    final cityStates = {
      'San Francisco': 'CA', 'New York': 'NY', 'Austin': 'TX', 'Denver': 'CO',
      'Boston': 'MA', 'Los Angeles': 'CA', 'Detroit': 'MI', 'Miami': 'FL',
      'Nashville': 'TN', 'Chicago': 'IL', 'Orlando': 'FL', 'Seattle': 'WA',
      'Las Vegas': 'NV', 'Portland': 'OR', 'Phoenix': 'AZ', 'Atlanta': 'GA',
      'Colorado Springs': 'CO', 'San Jose': 'CA', 'Santa Fe': 'NM', 'San Diego': 'CA',
      'Charleston': 'SC', 'Palo Alto': 'CA', 'Beverly Hills': 'CA', 'Miami Beach': 'FL',
      'Cambridge': 'MA', 'Hollywood': 'CA', 'Indianapolis': 'IN', 'Tampa': 'FL',
      'Memphis': 'TN', 'New Orleans': 'LA', 'Disney World': 'FL', 'Dallas': 'TX',
      'Asheville': 'NC', 'Scottsdale': 'AZ', 'Savannah': 'GA', 'Boulder': 'CO',
      'Taos': 'NM', 'Honolulu': 'HI', 'Silicon Valley': 'CA', 'Milan District': 'NY',
      'Napa Valley': 'CA', 'Venice Beach': 'CA', 'Harvard Square': 'MA', 'Rodeo Drive': 'CA',
      'Daytona': 'FL', 'Key West': 'FL',
    };
    return cityStates[city] ?? 'CA';
  }
}
