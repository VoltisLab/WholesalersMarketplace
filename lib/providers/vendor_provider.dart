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
      {'name': 'Retro Revival Electronics', 'category': 'Electronics', 'city': 'London', 'rating': 4.8, 'reviews': 1250},
      {'name': 'Vintage Threads & Co', 'category': 'Fashion', 'city': 'Brighton', 'rating': 4.6, 'reviews': 890},
      {'name': 'The Old Curiosity Shop', 'category': 'Home', 'city': 'Bath', 'rating': 4.4, 'reviews': 567},
      {'name': 'Second Chance Sports', 'category': 'Sports', 'city': 'Manchester', 'rating': 4.7, 'reviews': 423},
      {'name': 'Dusty Pages Bookshop', 'category': 'Books', 'city': 'Oxford', 'rating': 4.5, 'reviews': 789},
      {'name': 'Timeless Beauty Finds', 'category': 'Beauty', 'city': 'Edinburgh', 'rating': 4.9, 'reviews': 1100},
      {'name': 'Classic Car Parts Co', 'category': 'Automotive', 'city': 'Birmingham', 'rating': 4.3, 'reviews': 654},
      {'name': 'Paws & Claws Vintage', 'category': 'Pets', 'city': 'Liverpool', 'rating': 4.7, 'reviews': 432},
      {'name': 'Vinyl & Vintage Music', 'category': 'Music', 'city': 'Bristol', 'rating': 4.6, 'reviews': 876},
      {'name': 'Grandma\'s Kitchen Finds', 'category': 'Kitchen', 'city': 'York', 'rating': 4.5, 'reviews': 543},
      {'name': 'Yesteryear Toy Chest', 'category': 'Toys', 'city': 'Canterbury', 'rating': 4.8, 'reviews': 765},
      {'name': 'Mad Men Office Supply', 'category': 'Office', 'city': 'Cambridge', 'rating': 4.2, 'reviews': 321},
      {'name': 'Heirloom Jewelry Box', 'category': 'Jewelry', 'city': 'Windsor', 'rating': 4.9, 'reviews': 987},
      {'name': 'Artisan\'s Attic Crafts', 'category': 'Crafts', 'city': 'Stratford', 'rating': 4.4, 'reviews': 234},
      {'name': 'Apothecary & Wellness', 'category': 'Health', 'city': 'Harrogate', 'rating': 4.6, 'reviews': 678},
      {'name': 'Little Lamb\'s Legacy', 'category': 'Baby', 'city': 'Bournemouth', 'rating': 4.7, 'reviews': 456},
      {'name': 'Adventure Seekers Gear', 'category': 'Outdoor', 'city': 'Lake District', 'rating': 4.8, 'reviews': 789},
      {'name': 'Retro Gaming Arcade', 'category': 'Gaming', 'city': 'Newcastle', 'rating': 4.5, 'reviews': 543},
      {'name': 'The Artist\'s Quarter', 'category': 'Art', 'city': 'St Ives', 'rating': 4.3, 'reviews': 321},
      {'name': 'Wanderlust Vintage', 'category': 'Travel', 'city': 'Dover', 'rating': 4.6, 'reviews': 654},
      {'name': 'Bygone Era Antiques', 'category': 'Vintage', 'city': 'Cotswolds', 'rating': 4.4, 'reviews': 432},
      {'name': 'Circuit City Vintage', 'category': 'Electronics', 'city': 'Sheffield', 'rating': 4.7, 'reviews': 876},
      {'name': 'Mod & Vintage Fashion', 'category': 'Fashion', 'city': 'Nottingham', 'rating': 4.8, 'reviews': 765},
      {'name': 'Heritage Home & Garden', 'category': 'Garden', 'city': 'Chester', 'rating': 4.5, 'reviews': 543},
      {'name': 'Old School Fitness', 'category': 'Fitness', 'city': 'Leicester', 'rating': 4.6, 'reviews': 678},
      {'name': 'The Reading Room', 'category': 'Books', 'city': 'Salisbury', 'rating': 4.4, 'reviews': 456},
      {'name': 'Glamour Days Beauty', 'category': 'Beauty', 'city': 'Cheltenham', 'rating': 4.9, 'reviews': 987},
      {'name': 'Vintage Motor Works', 'category': 'Automotive', 'city': 'Coventry', 'rating': 4.3, 'reviews': 321},
      {'name': 'Furry Friends Vintage', 'category': 'Pets', 'city': 'Plymouth', 'rating': 4.7, 'reviews': 654},
      {'name': 'Melody Lane Records', 'category': 'Music', 'city': 'Portsmouth', 'rating': 4.5, 'reviews': 432},
      {'name': 'Retro Kitchen Co', 'category': 'Kitchen', 'city': 'Southampton', 'rating': 4.8, 'reviews': 789},
      {'name': 'Childhood Memories Toys', 'category': 'Toys', 'city': 'Exeter', 'rating': 4.6, 'reviews': 876},
      {'name': 'Typewriter & Quill Co', 'category': 'Office', 'city': 'Winchester', 'rating': 4.2, 'reviews': 543},
      {'name': 'Crown Jewels Vintage', 'category': 'Jewelry', 'city': 'Canterbury', 'rating': 4.9, 'reviews': 765},
      {'name': 'Handmade Heritage', 'category': 'Crafts', 'city': 'Glastonbury', 'rating': 4.4, 'reviews': 321},
      {'name': 'Victorian Remedies', 'category': 'Health', 'city': 'Warwick', 'rating': 4.7, 'reviews': 654},
      {'name': 'Nursery Rhyme Finds', 'category': 'Baby', 'city': 'Chichester', 'rating': 4.8, 'reviews': 432},
      {'name': 'Explorer\'s Emporium', 'category': 'Outdoor', 'city': 'Peak District', 'rating': 4.5, 'reviews': 789},
      {'name': 'Arcade Legends', 'category': 'Gaming', 'city': 'Derby', 'rating': 4.6, 'reviews': 876},
      {'name': 'Bohemian Art House', 'category': 'Art', 'city': 'Brighton', 'rating': 4.3, 'reviews': 543},
      {'name': 'Grand Tour Vintage', 'category': 'Travel', 'city': 'Hastings', 'rating': 4.7, 'reviews': 765},
      {'name': 'Antique Alley', 'category': 'Vintage', 'city': 'Rye', 'rating': 4.4, 'reviews': 321},
      {'name': 'Gadget Graveyard', 'category': 'Electronics', 'city': 'Guildford', 'rating': 4.8, 'reviews': 987},
      {'name': 'Swinging Sixties Style', 'category': 'Fashion', 'city': 'Margate', 'rating': 4.9, 'reviews': 654},
      {'name': 'Secret Garden Vintage', 'category': 'Garden', 'city': 'Kew', 'rating': 4.5, 'reviews': 432},
      {'name': 'Strongman\'s Gym Gear', 'category': 'Fitness', 'city': 'Blackpool', 'rating': 4.6, 'reviews': 789},
      {'name': 'Leather Bound Books', 'category': 'Books', 'city': 'Hay-on-Wye', 'rating': 4.4, 'reviews': 876},
      {'name': 'Hollywood Glamour', 'category': 'Beauty', 'city': 'Eastbourne', 'rating': 4.9, 'reviews': 543},
      {'name': 'Classic Chrome Motors', 'category': 'Automotive', 'city': 'Goodwood', 'rating': 4.3, 'reviews': 765},
      {'name': 'Pedigree Pet Finds', 'category': 'Pets', 'city': 'Crufts', 'rating': 4.7, 'reviews': 321},
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
        phone: '+44 ${(1000 + index * 7).toString().padLeft(4, '0')} ${(100000 + index * 123).toString().padLeft(6, '0')}',
        address: AddressModel(
          id: vendorId,
          street: '${100 + index * 10} ${data['category']} Street',
          city: data['city'],
          state: _getCountyFromCity(data['city']),
          zipCode: _getPostcodeFromCity(data['city'], index),
          country: 'United Kingdom',
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

  String _getCountyFromCity(String city) {
    final cityCounties = {
      'London': 'Greater London', 'Brighton': 'East Sussex', 'Bath': 'Somerset', 
      'Manchester': 'Greater Manchester', 'Oxford': 'Oxfordshire', 'Edinburgh': 'Midlothian',
      'Birmingham': 'West Midlands', 'Liverpool': 'Merseyside', 'Bristol': 'Gloucestershire',
      'York': 'North Yorkshire', 'Canterbury': 'Kent', 'Cambridge': 'Cambridgeshire',
      'Windsor': 'Berkshire', 'Stratford': 'Warwickshire', 'Harrogate': 'North Yorkshire',
      'Bournemouth': 'Dorset', 'Lake District': 'Cumbria', 'Newcastle': 'Tyne and Wear',
      'St Ives': 'Cornwall', 'Dover': 'Kent', 'Cotswolds': 'Gloucestershire',
      'Sheffield': 'South Yorkshire', 'Nottingham': 'Nottinghamshire', 'Chester': 'Cheshire',
      'Leicester': 'Leicestershire', 'Salisbury': 'Wiltshire', 'Cheltenham': 'Gloucestershire',
      'Coventry': 'West Midlands', 'Plymouth': 'Devon', 'Portsmouth': 'Hampshire',
      'Southampton': 'Hampshire', 'Exeter': 'Devon', 'Winchester': 'Hampshire',
      'Glastonbury': 'Somerset', 'Warwick': 'Warwickshire', 'Chichester': 'West Sussex',
      'Peak District': 'Derbyshire', 'Derby': 'Derbyshire', 'Hastings': 'East Sussex',
      'Rye': 'East Sussex', 'Guildford': 'Surrey', 'Margate': 'Kent', 'Kew': 'Greater London',
      'Blackpool': 'Lancashire', 'Hay-on-Wye': 'Powys', 'Eastbourne': 'East Sussex',
      'Goodwood': 'West Sussex', 'Crufts': 'West Midlands',
    };
    return cityCounties[city] ?? 'England';
  }

  String _getPostcodeFromCity(String city, int index) {
    final cityPostcodes = {
      'London': 'SW1A 1AA', 'Brighton': 'BN1 1AA', 'Bath': 'BA1 1AA',
      'Manchester': 'M1 1AA', 'Oxford': 'OX1 1AA', 'Edinburgh': 'EH1 1AA',
      'Birmingham': 'B1 1AA', 'Liverpool': 'L1 1AA', 'Bristol': 'BS1 1AA',
      'York': 'YO1 1AA', 'Canterbury': 'CT1 1AA', 'Cambridge': 'CB1 1AA',
      'Windsor': 'SL4 1AA', 'Stratford': 'CV37 1AA', 'Harrogate': 'HG1 1AA',
      'Bournemouth': 'BH1 1AA', 'Lake District': 'LA22 1AA', 'Newcastle': 'NE1 1AA',
      'St Ives': 'TR26 1AA', 'Dover': 'CT16 1AA', 'Cotswolds': 'GL54 1AA',
      'Sheffield': 'S1 1AA', 'Nottingham': 'NG1 1AA', 'Chester': 'CH1 1AA',
      'Leicester': 'LE1 1AA', 'Salisbury': 'SP1 1AA', 'Cheltenham': 'GL50 1AA',
      'Coventry': 'CV1 1AA', 'Plymouth': 'PL1 1AA', 'Portsmouth': 'PO1 1AA',
      'Southampton': 'SO14 1AA', 'Exeter': 'EX1 1AA', 'Winchester': 'SO23 1AA',
      'Glastonbury': 'BA6 1AA', 'Warwick': 'CV34 1AA', 'Chichester': 'PO19 1AA',
      'Peak District': 'SK17 1AA', 'Derby': 'DE1 1AA', 'Hastings': 'TN34 1AA',
      'Rye': 'TN31 1AA', 'Guildford': 'GU1 1AA', 'Margate': 'CT9 1AA',
      'Kew': 'TW9 1AA', 'Blackpool': 'FY1 1AA', 'Hay-on-Wye': 'HR3 1AA',
      'Eastbourne': 'BN21 1AA', 'Goodwood': 'PO18 1AA', 'Crufts': 'B40 1AA',
    };
    final basePostcode = cityPostcodes[city] ?? 'EN1 1AA';
    // Vary the postcode slightly based on index
    final parts = basePostcode.split(' ');
    final number = (int.tryParse(parts[1].substring(0, 1)) ?? 1) + (index % 9);
    return '${parts[0]} ${number}${parts[1].substring(1)}';
  }
}
