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
  }) async {
    try {
      debugPrint('🔄 Fetching products...');
      
      // Build filters object for backend
      final Map<String, dynamic> filters = {};
      if (category != null) filters['category'] = int.tryParse(category);
      if (minPrice != null) filters['min_price'] = minPrice;
      if (maxPrice != null) filters['max_price'] = maxPrice;
      
      // Use simple query for search to avoid backend pagination issues
      final String query = search != null 
        ? '''
          query AllProducts(\$search: String) {
            allProducts(search: \$search) {
              id
              name
              description
              price
              discountPrice
              imagesUrl
              category {
                id
                name
              }
              brand {
                id
                name
              }
              size {
                id
                name
              }
              seller {
                id
                firstName
                lastName
              }
            }
          }
        '''
        : GraphQLQueries.allProducts;
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(query),
          variables: search != null 
            ? {'search': search}
            : {
                'filters': filters.isNotEmpty ? filters : null,
                'search': search,
                'sort': sortBy,
                'pageCount': 50,
                'pageNumber': 1,
              },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 GraphQL Error Details:');
          debugPrint('   Message: ${graphqlError.message}');
          debugPrint('   Locations: ${graphqlError.locations}');
          debugPrint('   Path: ${graphqlError.path}');
          debugPrint('   Extensions: ${graphqlError.extensions}');
          throw createError(ErrorCode.graphqlQueryError, details: 'GraphQL Error: ${graphqlError.message} (Path: ${graphqlError.path})');
        }
        
        // Detailed network error handling
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 Network Error Details:');
          debugPrint('   Type: ${linkException.runtimeType}');
          debugPrint('   Message: ${linkException.toString()}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'Network Error: ${linkException.runtimeType} - ${linkException.toString()}');
        }
        
        debugPrint('🚨 Unknown Exception Details:');
        debugPrint('   Type: ${exception.runtimeType}');
        debugPrint('   Message: ${exception.toString()}');
        throw createError(ErrorCode.unknown, details: 'Unknown Error: ${exception.runtimeType} - ${exception.toString()}');
      }

      final products = result.data?['allProducts'] as List? ?? [];
      
      debugPrint('✅ Fetched ${products.length} products');
      return products.cast<Map<String, dynamic>>();
      
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
      
      // Product queries no longer require authentication
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(GraphQLQueries.productById),
          variables: {
            'id': int.parse(productId),
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('❌ GraphQL Error: ${graphqlError.message}');
          
          if (graphqlError.message.contains('not found') || graphqlError.message.contains('does not exist')) {
            throw createError(ErrorCode.productNotFound, details: 'Product not found');
          }
          
          throw createError(
            ErrorCode.graphqlQueryError,
            details: 'GraphQL Error: ${graphqlError.message}',
          );
        }
        
        throw createError(
          ErrorCode.graphqlQueryError,
          details: 'GraphQL query failed: ${exception.toString()}',
        );
      }

      final product = result.data?['product'];
      if (product == null) {
        throw createError(ErrorCode.productNotFound, details: 'Product not found');
      }

      debugPrint('✅ Product fetched successfully: ${product['name']}');
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

  static Future<List<Map<String, dynamic>>> getProductCategories({String? token}) async {
    try {
      debugPrint('🔄 Fetching product categories...');
      
      // Use authenticated client if token is provided, otherwise use unauthenticated client
      final GraphQLClient client = token != null 
          ? GraphQLService.getAuthenticatedClient(token)
          : GraphQLService.client;
      
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(GraphQLQueries.productCategories),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 Categories GraphQL Error Details:');
          debugPrint('   Message: ${graphqlError.message}');
          debugPrint('   Locations: ${graphqlError.locations}');
          debugPrint('   Path: ${graphqlError.path}');
          debugPrint('   Extensions: ${graphqlError.extensions}');
          throw createError(ErrorCode.graphqlQueryError, details: 'Categories GraphQL Error: ${graphqlError.message} (Path: ${graphqlError.path})');
        }
        
        // Detailed network error handling
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 Categories Network Error Details:');
          debugPrint('   Type: ${linkException.runtimeType}');
          debugPrint('   Message: ${linkException.toString()}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'Categories Network Error: ${linkException.runtimeType} - ${linkException.toString()}');
        }
        
        debugPrint('🚨 Categories Unknown Exception Details:');
        debugPrint('   Type: ${exception.runtimeType}');
        debugPrint('   Message: ${exception.toString()}');
        throw createError(ErrorCode.unknown, details: 'Categories Unknown Error: ${exception.runtimeType} - ${exception.toString()}');
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
    required int category,
    int? size,
    required List<Map<String, String>> imagesUrl,
    double? discount,
    String? condition,
    String? style,
    List<String>? color,
    int? brand,
    List<int>? materials,
    String? customBrand,
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
            'category': category,
            'size': size,
            'imagesUrl': imagesUrl,
            'discount': discount,
            'condition': condition,
            'style': style,
            'color': color,
            'brand': brand,
            'materials': materials,
            'customBrand': customBrand,
            'isFeatured': isFeatured,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 CreateProduct GraphQL Error Details:');
          debugPrint('   Message: ${graphqlError.message}');
          debugPrint('   Locations: ${graphqlError.locations}');
          debugPrint('   Path: ${graphqlError.path}');
          debugPrint('   Extensions: ${graphqlError.extensions}');
          debugPrint('   Variables sent: {name: $name, category: $category, imagesUrl: $imagesUrl}');
          throw createError(ErrorCode.graphqlMutationError, details: 'CreateProduct GraphQL Error: ${graphqlError.message} (Path: ${graphqlError.path})');
        }
        
        // Detailed network error handling
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 CreateProduct Network Error Details:');
          debugPrint('   Type: ${linkException.runtimeType}');
          debugPrint('   Message: ${linkException.toString()}');
          debugPrint('   Variables sent: {name: $name, category: $category, imagesUrl: $imagesUrl}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'CreateProduct Network Error: ${linkException.runtimeType} - ${linkException.toString()}');
        }
        
        debugPrint('🚨 CreateProduct Unknown Exception Details:');
        debugPrint('   Type: ${exception.runtimeType}');
        debugPrint('   Message: ${exception.toString()}');
        debugPrint('   Variables sent: {name: $name, category: $category, imagesUrl: $imagesUrl}');
        throw createError(ErrorCode.unknown, details: 'CreateProduct Unknown Error: ${exception.runtimeType} - ${exception.toString()}');
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
  }) async {
    try {
      debugPrint('🔄 Searching products: $query');
      
      // Use getAllProducts with search parameter since backend doesn't have dedicated searchProducts query
      return await getAllProducts(
        search: query,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );
      
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

  // Note: Backend doesn't have getAllVendors query, only individual vendor profile queries
  // Use vendorProfileById for specific vendor data

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
