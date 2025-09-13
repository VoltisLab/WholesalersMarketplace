class VendorModel {
  final String id;
  final String name;
  final String description;
  final String email;
  final String? imageUrl;
  final String? logo;
  final String? address;
  final double rating;
  final bool isVerified;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.email,
    this.imageUrl,
    this.logo,
    this.address,
    this.rating = 0.0,
    this.isVerified = false,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['businessName'] ?? 'Unknown Vendor',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      logo: json['logo'],
      address: json['address'] ?? json['location'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      productCount: json['productCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'email': email,
      'imageUrl': imageUrl,
      'logo': logo,
      'address': address,
      'rating': rating,
      'isVerified': isVerified,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
