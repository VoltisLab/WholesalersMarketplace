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
      {'name': 'Retro Revival Electronics', 'category': 'Electronics', 'country': 'China', 'rating': 4.8, 'reviews': 1250},
      {'name': 'Vintage Threads & Co', 'category': 'Fashion', 'country': 'India', 'rating': 4.6, 'reviews': 890},
      {'name': 'The Old Curiosity Shop', 'category': 'Home', 'country': 'Germany', 'rating': 4.4, 'reviews': 567},
      {'name': 'Second Chance Sports', 'category': 'Sports', 'country': 'Pakistan', 'rating': 4.7, 'reviews': 423},
      {'name': 'Dusty Pages Bookshop', 'category': 'Books', 'country': 'Russia', 'rating': 4.5, 'reviews': 789},
      {'name': 'Timeless Beauty Finds', 'category': 'Beauty', 'country': 'United States', 'rating': 4.9, 'reviews': 1100},
      {'name': 'Classic Car Parts Co', 'category': 'Automotive', 'country': 'Japan', 'rating': 4.3, 'reviews': 654},
      {'name': 'Paws & Claws Vintage', 'category': 'Pets', 'country': 'United Kingdom', 'rating': 4.7, 'reviews': 432},
      {'name': 'Vinyl & Vintage Music', 'category': 'Music', 'country': 'France', 'rating': 4.6, 'reviews': 876},
      {'name': 'Grandma\'s Kitchen Finds', 'category': 'Kitchen', 'country': 'Italy', 'rating': 4.5, 'reviews': 543},
      {'name': 'Yesteryear Toy Chest', 'category': 'Toys', 'country': 'Brazil', 'rating': 4.8, 'reviews': 765},
      {'name': 'Mad Men Office Supply', 'category': 'Office', 'country': 'Canada', 'rating': 4.2, 'reviews': 321},
      {'name': 'Heirloom Jewelry Box', 'category': 'Jewelry', 'country': 'Australia', 'rating': 4.9, 'reviews': 987},
      {'name': 'Artisan\'s Attic Crafts', 'category': 'Crafts', 'country': 'Spain', 'rating': 4.4, 'reviews': 234},
      {'name': 'Apothecary & Wellness', 'category': 'Health', 'country': 'Netherlands', 'rating': 4.6, 'reviews': 678},
      {'name': 'Little Lamb\'s Legacy', 'category': 'Baby', 'country': 'Sweden', 'rating': 4.7, 'reviews': 456},
      {'name': 'Adventure Seekers Gear', 'category': 'Outdoor', 'country': 'Norway', 'rating': 4.8, 'reviews': 789},
      {'name': 'Retro Gaming Arcade', 'category': 'Gaming', 'country': 'South Korea', 'rating': 4.5, 'reviews': 543},
      {'name': 'The Artist\'s Quarter', 'category': 'Art', 'country': 'Mexico', 'rating': 4.3, 'reviews': 321},
      {'name': 'Wanderlust Vintage', 'category': 'Travel', 'country': 'Argentina', 'rating': 4.6, 'reviews': 654},
      {'name': 'Bygone Era Antiques', 'category': 'Vintage', 'country': 'Belgium', 'rating': 4.4, 'reviews': 432},
      {'name': 'Circuit City Vintage', 'category': 'Electronics', 'country': 'Switzerland', 'rating': 4.7, 'reviews': 876},
      {'name': 'Mod & Vintage Fashion', 'category': 'Fashion', 'country': 'Austria', 'rating': 4.8, 'reviews': 765},
      {'name': 'Heritage Home & Garden', 'category': 'Garden', 'country': 'Denmark', 'rating': 4.5, 'reviews': 543},
      {'name': 'Old School Fitness', 'category': 'Fitness', 'country': 'Finland', 'rating': 4.6, 'reviews': 678},
      {'name': 'Global Tech Solutions', 'category': 'Electronics', 'country': 'Singapore', 'rating': 4.7, 'reviews': 892},
      {'name': 'Fashion Forward', 'category': 'Fashion', 'country': 'Turkey', 'rating': 4.5, 'reviews': 567},
      {'name': 'Home Sweet Home', 'category': 'Home', 'country': 'Poland', 'rating': 4.3, 'reviews': 434},
      {'name': 'Sports Central', 'category': 'Sports', 'country': 'Czech Republic', 'rating': 4.6, 'reviews': 678},
      {'name': 'Book Haven', 'category': 'Books', 'country': 'Greece', 'rating': 4.4, 'reviews': 345},
      {'name': 'Beauty Bliss', 'category': 'Beauty', 'country': 'Portugal', 'rating': 4.8, 'reviews': 789},
      {'name': 'Auto Excellence', 'category': 'Automotive', 'country': 'Ireland', 'rating': 4.2, 'reviews': 456},
      {'name': 'Pet Paradise', 'category': 'Pets', 'country': 'New Zealand', 'rating': 4.9, 'reviews': 623},
      {'name': 'Music Mania', 'category': 'Music', 'country': 'Hungary', 'rating': 4.5, 'reviews': 512},
      {'name': 'Kitchen Kings', 'category': 'Kitchen', 'country': 'Romania', 'rating': 4.3, 'reviews': 389},
      {'name': 'Toy Town', 'category': 'Toys', 'country': 'Bulgaria', 'rating': 4.7, 'reviews': 445},
      {'name': 'Office Oasis', 'category': 'Office', 'country': 'Croatia', 'rating': 4.1, 'reviews': 267},
      {'name': 'Jewelry Junction', 'category': 'Jewelry', 'country': 'Slovenia', 'rating': 4.8, 'reviews': 678},
      {'name': 'Craft Corner', 'category': 'Crafts', 'country': 'Slovakia', 'rating': 4.4, 'reviews': 234},
      {'name': 'Health Hub', 'category': 'Health', 'country': 'Estonia', 'rating': 4.6, 'reviews': 456},
      {'name': 'Baby Boutique', 'category': 'Baby', 'country': 'Latvia', 'rating': 4.5, 'reviews': 345},
      {'name': 'Outdoor Outfitters', 'category': 'Outdoor', 'country': 'Lithuania', 'rating': 4.7, 'reviews': 567},
      {'name': 'Gaming Galaxy', 'category': 'Gaming', 'country': 'Iceland', 'rating': 4.6, 'reviews': 389},
      {'name': 'Art Avenue', 'category': 'Art', 'country': 'Luxembourg', 'rating': 4.3, 'reviews': 234},
      {'name': 'Travel Treasures', 'category': 'Travel', 'country': 'Malta', 'rating': 4.5, 'reviews': 345},
      {'name': 'Vintage Vibes', 'category': 'Vintage', 'country': 'Cyprus', 'rating': 4.4, 'reviews': 278},
      {'name': 'Tech Titans', 'category': 'Electronics', 'country': 'Israel', 'rating': 4.8, 'reviews': 789},
      {'name': 'Style Station', 'category': 'Fashion', 'country': 'South Africa', 'rating': 4.6, 'reviews': 567},
      {'name': 'Home Harmony', 'category': 'Home', 'country': 'Egypt', 'rating': 4.2, 'reviews': 434},
      {'name': 'Sports Spectrum', 'category': 'Sports', 'country': 'Morocco', 'rating': 4.5, 'reviews': 456},
      {'name': 'Literary Lounge', 'category': 'Books', 'country': 'Tunisia', 'rating': 4.3, 'reviews': 345},
      {'name': 'Beauty Boulevard', 'category': 'Beauty', 'country': 'Algeria', 'rating': 4.7, 'reviews': 678},
      {'name': 'Motor Masters', 'category': 'Automotive', 'country': 'Libya', 'rating': 4.1, 'reviews': 234},
      {'name': 'Pet Palace', 'category': 'Pets', 'country': 'Sudan', 'rating': 4.4, 'reviews': 345},
      {'name': 'Melody Makers', 'category': 'Music', 'country': 'Ethiopia', 'rating': 4.6, 'reviews': 456},
      {'name': 'Culinary Creations', 'category': 'Kitchen', 'country': 'Kenya', 'rating': 4.3, 'reviews': 389},
      {'name': 'Playtime Plaza', 'category': 'Toys', 'country': 'Tanzania', 'rating': 4.5, 'reviews': 567},
      {'name': 'Workspace Wonders', 'category': 'Office', 'country': 'Uganda', 'rating': 4.2, 'reviews': 234},
      {'name': 'Gem Gallery', 'category': 'Jewelry', 'country': 'Rwanda', 'rating': 4.8, 'reviews': 456},
      {'name': 'Creative Corner', 'category': 'Crafts', 'country': 'Ghana', 'rating': 4.4, 'reviews': 345},
      {'name': 'Wellness World', 'category': 'Health', 'country': 'Nigeria', 'rating': 4.6, 'reviews': 678},
      {'name': 'Tiny Tots', 'category': 'Baby', 'country': 'Senegal', 'rating': 4.5, 'reviews': 389},
      {'name': 'Adventure Awaits', 'category': 'Outdoor', 'country': 'Mali', 'rating': 4.7, 'reviews': 456},
      {'name': 'Game Zone', 'category': 'Gaming', 'country': 'Burkina Faso', 'rating': 4.3, 'reviews': 234},
      {'name': 'Artistic Expressions', 'category': 'Art', 'country': 'Niger', 'rating': 4.4, 'reviews': 345},
      {'name': 'Journey Junction', 'category': 'Travel', 'country': 'Chad', 'rating': 4.2, 'reviews': 278},
      {'name': 'Retro Relics', 'category': 'Vintage', 'country': 'Cameroon', 'rating': 4.5, 'reviews': 389},
      {'name': 'Digital Dreams', 'category': 'Electronics', 'country': 'Thailand', 'rating': 4.7, 'reviews': 567},
      {'name': 'Fashion Fusion', 'category': 'Fashion', 'country': 'Vietnam', 'rating': 4.6, 'reviews': 456},
      {'name': 'Cozy Corners', 'category': 'Home', 'country': 'Philippines', 'rating': 4.3, 'reviews': 345},
      {'name': 'Athletic Arena', 'category': 'Sports', 'country': 'Indonesia', 'rating': 4.5, 'reviews': 678},
      {'name': 'Reading Room', 'category': 'Books', 'country': 'Malaysia', 'rating': 4.4, 'reviews': 389},
      {'name': 'Glamour Gallery', 'category': 'Beauty', 'country': 'Bangladesh', 'rating': 4.8, 'reviews': 567},
      {'name': 'Vehicle Vault', 'category': 'Automotive', 'country': 'Sri Lanka', 'rating': 4.2, 'reviews': 234},
      {'name': 'Animal Allies', 'category': 'Pets', 'country': 'Myanmar', 'rating': 4.6, 'reviews': 456},
      {'name': 'Sound Studio', 'category': 'Music', 'country': 'Cambodia', 'rating': 4.5, 'reviews': 345},
      {'name': 'Chef\'s Choice', 'category': 'Kitchen', 'country': 'Laos', 'rating': 4.3, 'reviews': 278},
      {'name': 'Fun Factory', 'category': 'Toys', 'country': 'Mongolia', 'rating': 4.7, 'reviews': 456},
      {'name': 'Business Base', 'category': 'Office', 'country': 'Nepal', 'rating': 4.1, 'reviews': 234},
      {'name': 'Precious Pieces', 'category': 'Jewelry', 'country': 'Bhutan', 'rating': 4.9, 'reviews': 345},
      {'name': 'Handmade Haven', 'category': 'Crafts', 'country': 'Afghanistan', 'rating': 4.4, 'reviews': 278},
      {'name': 'Vitality Vault', 'category': 'Health', 'country': 'Uzbekistan', 'rating': 4.6, 'reviews': 389},
      {'name': 'Little Luxuries', 'category': 'Baby', 'country': 'Kazakhstan', 'rating': 4.5, 'reviews': 456},
      {'name': 'Wild Wonders', 'category': 'Outdoor', 'country': 'Kyrgyzstan', 'rating': 4.8, 'reviews': 567},
      {'name': 'Player\'s Paradise', 'category': 'Gaming', 'country': 'Tajikistan', 'rating': 4.3, 'reviews': 234},
      {'name': 'Canvas Creations', 'category': 'Art', 'country': 'Turkmenistan', 'rating': 4.4, 'reviews': 345},
      {'name': 'Wanderer\'s Way', 'category': 'Travel', 'country': 'Azerbaijan', 'rating': 4.6, 'reviews': 456},
      {'name': 'Nostalgia Nook', 'category': 'Vintage', 'country': 'Armenia', 'rating': 4.2, 'reviews': 278},
      {'name': 'Innovation Inc', 'category': 'Electronics', 'country': 'Georgia', 'rating': 4.7, 'reviews': 389},
      {'name': 'Trendy Threads', 'category': 'Fashion', 'country': 'Moldova', 'rating': 4.5, 'reviews': 345},
      {'name': 'Comfort Castle', 'category': 'Home', 'country': 'Belarus', 'rating': 4.3, 'reviews': 456},
      {'name': 'Victory Venue', 'category': 'Sports', 'country': 'Ukraine', 'rating': 4.6, 'reviews': 567},
      {'name': 'Knowledge Nook', 'category': 'Books', 'country': 'Serbia', 'rating': 4.4, 'reviews': 234},
      {'name': 'Radiance Realm', 'category': 'Beauty', 'country': 'Montenegro', 'rating': 4.8, 'reviews': 345},
      {'name': 'Drive Depot', 'category': 'Automotive', 'country': 'Bosnia and Herzegovina', 'rating': 4.1, 'reviews': 278},
      {'name': 'Companion Corner', 'category': 'Pets', 'country': 'North Macedonia', 'rating': 4.5, 'reviews': 389},
      {'name': 'Harmony House', 'category': 'Music', 'country': 'Albania', 'rating': 4.6, 'reviews': 456},
      {'name': 'Gourmet Gallery', 'category': 'Kitchen', 'country': 'Kosovo', 'rating': 4.3, 'reviews': 234},
      {'name': 'Wonder World', 'category': 'Toys', 'country': 'Chile', 'rating': 4.7, 'reviews': 567},
      {'name': 'Professional Plaza', 'category': 'Office', 'country': 'Peru', 'rating': 4.2, 'reviews': 345},
      {'name': 'Sparkle Spot', 'category': 'Jewelry', 'country': 'Colombia', 'rating': 4.9, 'reviews': 456},
      {'name': 'Artisan Alley', 'category': 'Crafts', 'country': 'Venezuela', 'rating': 4.4, 'reviews': 278},
      {'name': 'Health Haven', 'category': 'Health', 'country': 'Ecuador', 'rating': 4.6, 'reviews': 389},
      {'name': 'Bundle of Joy', 'category': 'Baby', 'country': 'Bolivia', 'rating': 4.5, 'reviews': 234},
      {'name': 'Explorer\'s Edge', 'category': 'Outdoor', 'country': 'Paraguay', 'rating': 4.8, 'reviews': 345},
      {'name': 'Gaming Grounds', 'category': 'Gaming', 'country': 'Uruguay', 'rating': 4.3, 'reviews': 456},
      {'name': 'Creative Canvas', 'category': 'Art', 'country': 'Guyana', 'rating': 4.4, 'reviews': 278},
      {'name': 'Voyage Vault', 'category': 'Travel', 'country': 'Suriname', 'rating': 4.6, 'reviews': 389},
      {'name': 'Timeless Treasures', 'category': 'Vintage', 'country': 'French Guiana', 'rating': 4.2, 'reviews': 234},
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
          city: _getCapitalCity(data['country']),
          state: _getStateFromCountry(data['country']),
          zipCode: _getPostcodeFromCountry(data['country'], index),
          country: data['country'] ?? 'China',
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

  String _getCapitalCity(String? country) {
    final capitals = {
      'China': 'Beijing', 'India': 'New Delhi', 'Germany': 'Berlin', 'Pakistan': 'Islamabad',
      'Russia': 'Moscow', 'United States': 'Washington D.C.', 'Japan': 'Tokyo', 'United Kingdom': 'London',
      'France': 'Paris', 'Italy': 'Rome', 'Brazil': 'Brasília', 'Canada': 'Ottawa',
      'Australia': 'Canberra', 'Spain': 'Madrid', 'Netherlands': 'Amsterdam', 'Sweden': 'Stockholm',
      'Norway': 'Oslo', 'South Korea': 'Seoul', 'Mexico': 'Mexico City', 'Argentina': 'Buenos Aires',
      'Belgium': 'Brussels', 'Switzerland': 'Bern', 'Austria': 'Vienna', 'Denmark': 'Copenhagen',
      'Finland': 'Helsinki', 'Singapore': 'Singapore', 'Turkey': 'Ankara', 'Poland': 'Warsaw',
      'Czech Republic': 'Prague', 'Greece': 'Athens', 'Portugal': 'Lisbon', 'Ireland': 'Dublin',
      'New Zealand': 'Wellington', 'Hungary': 'Budapest', 'Romania': 'Bucharest', 'Bulgaria': 'Sofia',
      'Croatia': 'Zagreb', 'Slovenia': 'Ljubljana', 'Slovakia': 'Bratislava', 'Estonia': 'Tallinn',
      'Latvia': 'Riga', 'Lithuania': 'Vilnius', 'Iceland': 'Reykjavik', 'Luxembourg': 'Luxembourg City',
      'Malta': 'Valletta', 'Cyprus': 'Nicosia', 'Israel': 'Jerusalem', 'South Africa': 'Cape Town',
      'Egypt': 'Cairo', 'Morocco': 'Rabat', 'Tunisia': 'Tunis', 'Algeria': 'Algiers',
      'Libya': 'Tripoli', 'Sudan': 'Khartoum', 'Ethiopia': 'Addis Ababa', 'Kenya': 'Nairobi',
      'Tanzania': 'Dodoma', 'Uganda': 'Kampala', 'Rwanda': 'Kigali', 'Ghana': 'Accra',
      'Nigeria': 'Abuja', 'Senegal': 'Dakar', 'Mali': 'Bamako', 'Burkina Faso': 'Ouagadougou',
      'Niger': 'Niamey', 'Chad': 'N\'Djamena', 'Cameroon': 'Yaoundé', 'Thailand': 'Bangkok',
      'Vietnam': 'Hanoi', 'Philippines': 'Manila', 'Indonesia': 'Jakarta', 'Malaysia': 'Kuala Lumpur',
      'Bangladesh': 'Dhaka', 'Sri Lanka': 'Colombo', 'Myanmar': 'Naypyidaw', 'Cambodia': 'Phnom Penh',
      'Laos': 'Vientiane', 'Mongolia': 'Ulaanbaatar', 'Nepal': 'Kathmandu', 'Bhutan': 'Thimphu',
      'Afghanistan': 'Kabul', 'Uzbekistan': 'Tashkent', 'Kazakhstan': 'Nur-Sultan', 'Kyrgyzstan': 'Bishkek',
      'Tajikistan': 'Dushanbe', 'Turkmenistan': 'Ashgabat', 'Azerbaijan': 'Baku', 'Armenia': 'Yerevan',
      'Georgia': 'Tbilisi', 'Moldova': 'Chișinău', 'Belarus': 'Minsk', 'Ukraine': 'Kyiv',
      'Serbia': 'Belgrade', 'Montenegro': 'Podgorica', 'Bosnia and Herzegovina': 'Sarajevo', 'North Macedonia': 'Skopje',
      'Albania': 'Tirana', 'Kosovo': 'Pristina', 'Chile': 'Santiago', 'Peru': 'Lima',
      'Colombia': 'Bogotá', 'Venezuela': 'Caracas', 'Ecuador': 'Quito', 'Bolivia': 'Sucre',
      'Paraguay': 'Asunción', 'Uruguay': 'Montevideo', 'Guyana': 'Georgetown', 'Suriname': 'Paramaribo',
      'French Guiana': 'Cayenne',
    };
    return capitals[country] ?? 'Unknown City';
  }

  String _getStateFromCountry(String? country) {
    final states = {
      'China': 'Beijing Municipality', 'India': 'Delhi', 'Germany': 'Berlin', 'Pakistan': 'Islamabad Capital Territory',
      'Russia': 'Moscow Oblast', 'United States': 'District of Columbia', 'Japan': 'Tokyo Metropolis', 'United Kingdom': 'England',
      'France': 'Île-de-France', 'Italy': 'Lazio', 'Brazil': 'Federal District', 'Canada': 'Ontario',
      'Australia': 'Australian Capital Territory', 'Spain': 'Community of Madrid', 'Netherlands': 'North Holland', 'Sweden': 'Stockholm County',
      'Norway': 'Oslo', 'South Korea': 'Seoul', 'Mexico': 'Mexico City', 'Argentina': 'Buenos Aires',
      'Belgium': 'Brussels-Capital Region', 'Switzerland': 'Bern', 'Austria': 'Vienna', 'Denmark': 'Capital Region',
      'Finland': 'Uusimaa', 'Singapore': 'Central Region', 'Turkey': 'Ankara Province', 'Poland': 'Masovian Voivodeship',
      'Czech Republic': 'Prague', 'Greece': 'Attica', 'Portugal': 'Lisbon District', 'Ireland': 'Leinster',
      'New Zealand': 'Wellington Region', 'Hungary': 'Budapest', 'Romania': 'Bucharest', 'Bulgaria': 'Sofia Province',
      'Croatia': 'Zagreb County', 'Slovenia': 'Central Slovenia', 'Slovakia': 'Bratislava Region', 'Estonia': 'Harju County',
      'Latvia': 'Riga', 'Lithuania': 'Vilnius County', 'Iceland': 'Capital Region', 'Luxembourg': 'Luxembourg District',
      'Malta': 'Southern Region', 'Cyprus': 'Nicosia District', 'Israel': 'Jerusalem District', 'South Africa': 'Western Cape',
      'Egypt': 'Cairo Governorate', 'Morocco': 'Rabat-Salé-Kénitra', 'Tunisia': 'Tunis Governorate', 'Algeria': 'Algiers Province',
    };
    return states[country] ?? 'Unknown State';
  }

  String _getPostcodeFromCountry(String? country, int index) {
    final baseCodes = {
      'China': '100000', 'India': '110001', 'Germany': '10115', 'Pakistan': '44000',
      'Russia': '101000', 'United States': '20001', 'Japan': '100-0001', 'United Kingdom': 'SW1A 1AA',
      'France': '75001', 'Italy': '00118', 'Brazil': '70040-010', 'Canada': 'K1A 0A6',
      'Australia': '2600', 'Spain': '28001', 'Netherlands': '1011', 'Sweden': '10011',
      'Norway': '0001', 'South Korea': '04524', 'Mexico': '06000', 'Argentina': 'C1001',
      'Belgium': '1000', 'Switzerland': '3001', 'Austria': '1010', 'Denmark': '1050',
      'Finland': '00100', 'Singapore': '018956', 'Turkey': '06420', 'Poland': '00-001',
    };
    final baseCode = baseCodes[country] ?? '00000';
    return '$baseCode${(index + 1).toString().padLeft(1, '0')}';
  }
}
