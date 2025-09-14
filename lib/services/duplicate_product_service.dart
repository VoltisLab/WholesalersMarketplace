import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class DuplicateProductService {
  static Future<Map<String, dynamic>?> duplicateProduct({
    required int productId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? condition,
    String? style,
    List<String>? color,
    int? brand,
    List<int>? materials,
    String? customBrand,
  }) async {
    try {
      debugPrint('🔄 Duplicating product: $productId');
      
      // Get authentication token
      final String? token = await TokenService.getToken();
      if (token == null) {
        debugPrint('❌ No authentication token found');
        throw AppError(errorCode: ErrorCode.authTokenExpired, details: 'Authentication required');
      }
      
      // Use authenticated client
      final GraphQLClient authClient = GraphQLService.getAuthenticatedClient(token);
      
      // Build mutation variables
      final Map<String, dynamic> variables = {
        'productId': productId,
      };
      
      // Add optional parameters if provided
      if (name != null) variables['name'] = name;
      if (description != null) variables['description'] = description;
      if (price != null) variables['price'] = price;
      if (discountPrice != null) variables['discountPrice'] = discountPrice;
      if (condition != null) variables['condition'] = condition;
      if (style != null) variables['style'] = style;
      if (color != null) variables['color'] = color;
      if (brand != null) variables['brand'] = brand;
      if (materials != null) variables['materials'] = materials;
      if (customBrand != null) variables['customBrand'] = customBrand;
      
      final String mutation = '''
        mutation DuplicateProduct(
          \$productId: Int!
          \$name: String
          \$description: String
          \$price: Float
          \$discountPrice: Float
          \$condition: ConditionEnum
          \$style: StyleEnum
          \$color: [String]
          \$brand: Int
          \$materials: [Int]
          \$customBrand: String
        ) {
          duplicateProduct(
            productId: \$productId
            name: \$name
            description: \$description
            price: \$price
            discountPrice: \$discountPrice
            condition: \$condition
            style: \$style
            color: \$color
            brand: \$brand
            materials: \$materials
            customBrand: \$customBrand
          ) {
            success
            message
            product {
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
                username
                email
              }
              materials {
                id
                name
              }
              userLiked
            }
          }
        }
      ''';
      
      final QueryResult result = await authClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variables,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 GraphQL Error: ${graphqlError.message}');
          throw createError(ErrorCode.graphqlQueryError, details: 'GraphQL Error: ${graphqlError.message}');
        }
        
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 Network Error: ${linkException.toString()}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'Network Error: ${linkException.toString()}');
        }
        
        throw createError(ErrorCode.unknown, details: 'Unknown Error: ${exception.toString()}');
      }

      final Map<String, dynamic>? data = result.data?['duplicateProduct'];
      if (data == null) {
        throw createError(ErrorCode.unknown, details: 'No data returned from duplicate product mutation');
      }
      
      if (data['success'] == true) {
        debugPrint('✅ Product duplicated successfully');
        return data;
      } else {
        throw createError(ErrorCode.unknown, details: data['message'] ?? 'Failed to duplicate product');
      }
      
    } catch (e) {
      debugPrint('❌ Error duplicating product: $e');
      if (e is AppError) {
        rethrow;
      }
      throw createError(ErrorCode.unknown, details: e.toString());
    }
  }
  
  static Future<Map<String, dynamic>?> quickDuplicate(int productId) async {
    return duplicateProduct(productId: productId);
  }
}
