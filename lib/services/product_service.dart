import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class ProductService {
  static Future<List<Map<String, dynamic>>> getAllProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching products...');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.allProducts),
          variables: {
            'first': first ?? 20,
            'after': after,
            'category': category,
            'search': search,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'sortBy': sortBy,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Products endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['allProducts']?['edges'] as List? ?? [];
      final products = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${products.length} products');
      return products;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get products exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      debugPrint('🔄 Fetching product: $productId');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.productById),
          variables: {'id': productId},
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Product endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final product = result.data?['productById'];
      
      if (product == null) {
        throw createError(ErrorCode.productNotFound, details: 'Product not found');
      }

      debugPrint('✅ Product fetched successfully');
      return product;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get product exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getFeaturedProducts({int? limit}) async {
    try {
      debugPrint('🔄 Fetching featured products...');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.featuredProducts),
          variables: {'limit': limit ?? 10},
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Featured products endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final products = result.data?['featuredProducts'] as List? ?? [];
      debugPrint('✅ Fetched ${products.length} featured products');
      return List<Map<String, dynamic>>.from(products);
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get featured products exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getProductCategories() async {
    try {
      debugPrint('🔄 Fetching product categories...');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.productCategories),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Categories endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final categories = result.data?['productCategories'] as List? ?? [];
      debugPrint('✅ Fetched ${categories.length} categories');
      return List<Map<String, dynamic>>.from(categories);
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get categories exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createProduct({
    required String token,
    required String name,
    required String description,
    required double price,
    double? discount,
    List<Map<String, String>>? imagesUrl,
    int? category,
    int? brand,
    String? customBrand,
    int? size,
    int? materials,
    String? color,
    String? condition,
    String? style,
    bool? isFeatured,
  }) async {
    try {
      debugPrint('🔄 Creating product: $name');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createProduct),
          variables: {
            'name': name,
            'description': description,
            'price': price,
            'discount': discount,
            'imagesUrl': imagesUrl,
            'category': category,
            'brand': brand,
            'customBrand': customBrand,
            'size': size,
            'materials': materials,
            'color': color,
            'condition': condition,
            'style': style,
            'isFeatured': isFeatured,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Create product endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createProduct'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create product');
      }

      debugPrint('✅ Product created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create product exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateProduct({
    required String token,
    required String productId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? imagesUrl,
    String? category,
    String? subcategory,
    int? stockQuantity,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? dimensions,
    double? weight,
    List<String>? materials,
    String? careInstructions,
    bool? isActive,
  }) async {
    try {
      debugPrint('🔄 Updating product: $productId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateProduct),
          variables: {
            'productId': productId,
            'name': name,
            'description': description,
            'price': price,
            'discountPrice': discountPrice,
            'imagesUrl': imagesUrl,
            'category': category,
            'subcategory': subcategory,
            'stockQuantity': stockQuantity,
            'tags': tags,
            'specifications': specifications,
            'dimensions': dimensions,
            'weight': weight,
            'materials': materials,
            'careInstructions': careInstructions,
            'isActive': isActive,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update product endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateProduct'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update product');
      }

      debugPrint('✅ Product updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update product exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> deleteProduct({
    required String token,
    required String productId,
  }) async {
    try {
      debugPrint('🔄 Deleting product: $productId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteProduct),
          variables: {
            'productId': productId,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlMutationError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Delete product endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final deleteData = result.data?['deleteProduct'];
      
      if (deleteData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: deleteData?['message'] ?? 'Failed to delete product');
      }

      debugPrint('✅ Product deleted successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Delete product exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Searching products: $query');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.searchProducts),
          variables: {
            'query': query,
            'category': category,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'sortBy': sortBy,
            'first': first ?? 20,
            'after': after,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Search endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['searchProducts']?['edges'] as List? ?? [];
      final products = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Found ${products.length} products for query: $query');
      return products;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Search products exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllVendors({
    String? search,
    String? category,
    bool? isVerified,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching vendors...');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.allVendors),
          variables: {
            'first': first ?? 20,
            'after': after,
            'search': search,
            'category': category,
            'isVerified': isVerified,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Vendors endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['allVendors']?['edges'] as List? ?? [];
      final vendors = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${vendors.length} vendors');
      return vendors;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get vendors exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> getVendorById(String vendorId) async {
    try {
      debugPrint('🔄 Fetching vendor: $vendorId');
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.vendorById),
          variables: {'id': vendorId},
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Vendor endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final vendor = result.data?['vendorById'];
      
      if (vendor == null) {
        throw createError(ErrorCode.vendorNotFound, details: 'Vendor not found');
      }

      debugPrint('✅ Vendor fetched successfully');
      return vendor;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get vendor exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
