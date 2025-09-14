import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String category;
  final String subcategory;
  final VendorModel vendor;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final bool isActive;
  final bool isFeatured;
  final int views;
  final int likes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
  
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.category,
    required this.subcategory,
    required this.vendor,
    required this.stockQuantity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.specifications = const {},
    this.isActive = true,
    this.isFeatured = false,
    this.views = 0,
    this.likes = 0,
    this.status = 'ACTIVE',
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle category - could be string or object
    String categoryName = '';
    if (json['category'] is Map<String, dynamic>) {
      categoryName = json['category']['name'] ?? '';
    } else {
      categoryName = json['category']?.toString() ?? '';
    }
    
    // Handle subcategory - use size as subcategory
    String subcategoryName = '';
    if (json['size'] is Map<String, dynamic>) {
      subcategoryName = json['size']['name'] ?? '';
    } else {
      subcategoryName = json['size']?.toString() ?? '';
    }
    
    // Handle images - backend uses images_url
    List<String> imageList = [];
    if (json['images_url'] is List) {
      imageList = List<String>.from(json['images_url']);
    } else if (json['imagesUrl'] is List) {
      imageList = List<String>.from(json['imagesUrl']);
    } else if (json['images'] is List) {
      imageList = List<String>.from(json['images']);
    } else if (json['images_url'] is String) {
      // Parse JSON string from backend
      try {
        final List<dynamic> parsedImages = jsonDecode(json['images_url']);
        for (var img in parsedImages) {
          if (img is Map<String, dynamic> && img['url'] != null) {
            imageList.add(img['url'].toString());
          }
        }
      } catch (e) {
        debugPrint('Error parsing images_url JSON: $e');
      }
    } else if (json['imagesUrl'] is String) {
      // Parse JSON string from backend (fallback)
      try {
        final List<dynamic> parsedImages = jsonDecode(json['imagesUrl']);
        for (var img in parsedImages) {
          if (img is Map<String, dynamic> && img['url'] != null) {
            imageList.add(img['url'].toString());
          }
        }
      } catch (e) {
        debugPrint('Error parsing imagesUrl JSON: $e');
      }
    }
    
    // Handle vendor - backend uses seller
    Map<String, dynamic> vendorData = {};
    if (json['seller'] is Map<String, dynamic>) {
      vendorData = json['seller'];
    } else if (json['vendor'] is Map<String, dynamic>) {
      vendorData = json['vendor'];
    }
    
    // Handle tags - backend uses hashtags
    List<String> tagList = [];
    if (json['hashtags'] is List) {
      tagList = List<String>.from(json['hashtags']);
    } else if (json['tags'] is List) {
      tagList = List<String>.from(json['tags']);
    }
    
    // Build specifications from available fields
    Map<String, dynamic> specs = {};
    if (json['brand'] is Map<String, dynamic>) {
      specs['Brand'] = json['brand']['name'] ?? '';
    }
    if (json['custom_brand'] != null && json['custom_brand'].toString().isNotEmpty) {
      specs['Custom Brand'] = json['custom_brand'];
    }
    if (json['style'] != null) {
      specs['Style'] = json['style'];
    }
    if (json['condition'] != null) {
      specs['Condition'] = json['condition'];
    }
    if (json['parcelSize'] != null) {
      specs['Parcel Size'] = json['parcelSize'];
    }
    if (json['color'] is List && (json['color'] as List).isNotEmpty) {
      specs['Color'] = (json['color'] as List).join(', ');
    }
    if (json['materials'] is List && (json['materials'] as List).isNotEmpty) {
      List<String> materialNames = [];
      for (var material in json['materials']) {
        if (material is Map<String, dynamic> && material['name'] != null) {
          materialNames.add(material['name']);
        }
      }
      if (materialNames.isNotEmpty) {
        specs['Materials'] = materialNames.join(', ');
      }
    }
    if (json['hashtags'] is List && (json['hashtags'] as List).isNotEmpty) {
      specs['Hashtags'] = (json['hashtags'] as List).join(', ');
    }
    if (json['views'] != null) {
      specs['Views'] = json['views'].toString();
    }
    if (json['likes'] != null) {
      specs['Likes'] = json['likes'].toString();
    }
    if (json['status'] != null) {
      specs['Status'] = json['status'];
    }
    
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parseDouble(json['price']) ?? 0.0,
      discountPrice: _parseDouble(json['discount_price']) ?? _parseDouble(json['discountPrice']),
      images: imageList,
      category: categoryName,
      subcategory: subcategoryName,
      vendor: VendorModel.fromJson(vendorData),
      stockQuantity: json['stockQuantity'] ?? json['stock_quantity'] ?? 999, // Default to high stock
      rating: _parseDouble(json['rating']) ?? _parseDouble(json['averageRating']) ?? 0.0,
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      tags: tagList,
      specifications: specs,
      isActive: json['isActive'] ?? json['is_active'] ?? (json['status'] == 'ACTIVE'),
      isFeatured: json['isFeatured'] ?? json['is_featured'] ?? false,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'images': images,
      'category': category,
      'subcategory': subcategory,
      'vendor': vendor.toJson(),
      'stock_quantity': stockQuantity,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
      'specifications': specifications,
      'is_active': isActive,
      'is_featured': isFeatured,
      'views': views,
      'likes': likes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  double get finalPrice {
    debugPrint('🔍 Product: $name - price: $price, discountPrice: $discountPrice');
    final result = (discountPrice != null && discountPrice! > 0 && discountPrice! < price) ? discountPrice! : price;
    debugPrint('🔍 Final price: $result');
    return result;
  }
  bool get hasDiscount => discountPrice != null && discountPrice! > 0 && discountPrice! < price;
  double get discountPercentage => hasDiscount ? ((price - discountPrice!) / price * 100) : 0;
  bool get inStock => stockQuantity > 0;
  String get mainImage => images.isNotEmpty ? images.first : '';
}

class VendorModel {
  final String id;
  final String name;
  final String description;
  final String logo;
  final String email;
  final String phone;
  final AddressModel address;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final List<String> categories;
  
  VendorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.email,
    required this.phone,
    required this.address,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.categories = const [],
  });
  
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    // Handle name - could be businessName or firstName + lastName
    String vendorName = '';
    if (json['businessName'] != null && json['businessName'].toString().isNotEmpty) {
      vendorName = json['businessName'];
    } else if (json['firstName'] != null || json['lastName'] != null) {
      vendorName = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    } else {
      vendorName = json['name'] ?? '';
    }
    
    return VendorModel(
      id: json['id']?.toString() ?? '',
      name: vendorName,
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: AddressModel.fromJson(json['address'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'email': email,
      'phone': phone,
      'address': address.toJson(),
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'categories': categories,
    };
  }
}

// Import AddressModel from user_model.dart
class AddressModel {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  
  AddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });
  
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['is_default'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }
  
  String get fullAddress => '$street, $city, $state $zipCode, $country';
}
