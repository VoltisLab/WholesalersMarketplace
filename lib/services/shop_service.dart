import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class ShopService {
  /// Get shop data and statistics for a supplier
  static Future<Map<String, dynamic>?> getShopData({
    required String token,
    String? sellerId,
  }) async {
    try {
      debugPrint('🔄 Fetching shop data...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.getShopData),
          variables: {
            'sellerId': sellerId,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 Shop Data GraphQL Error Details:');
          debugPrint('   Message: ${graphqlError.message}');
          debugPrint('   Locations: ${graphqlError.locations}');
          debugPrint('   Path: ${graphqlError.path}');
          debugPrint('   Extensions: ${graphqlError.extensions}');
          throw createError(ErrorCode.graphqlQueryError, details: 'Shop Data GraphQL Error: ${graphqlError.message} (Path: ${graphqlError.path})');
        }
        
        // Detailed network error handling
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 Shop Data Network Error Details:');
          debugPrint('   Type: ${linkException.runtimeType}');
          debugPrint('   Message: ${linkException.toString()}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'Shop Data Network Error: ${linkException.runtimeType} - ${linkException.toString()}');
        }
        
        debugPrint('🚨 Shop Data Unknown Exception Details:');
        debugPrint('   Type: ${exception.runtimeType}');
        debugPrint('   Message: ${exception.toString()}');
        throw createError(ErrorCode.unknown, details: 'Shop Data Unknown Error: ${exception.runtimeType} - ${exception.toString()}');
      }

      final shopData = result.data?['getShopData'];
      
      if (shopData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: shopData?['message'] ?? 'Failed to fetch shop data');
      }

      debugPrint('✅ Shop data fetched successfully');
      return shopData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get shop data exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  /// Update shop settings for a supplier
  static Future<Map<String, dynamic>?> updateShopSettings({
    required String token,
    String? shopName,
    String? shopDescription,
    String? shopLogoUrl,
    String? shopBannerUrl,
    String? shopContactEmail,
    String? shopContactPhone,
    String? shopAddress,
    String? shopCity,
    String? shopCountry,
    String? shopPostalCode,
  }) async {
    try {
      debugPrint('🔄 Updating shop settings...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateShopSettings),
          variables: {
            'shopName': shopName,
            'shopDescription': shopDescription,
            'shopLogoUrl': shopLogoUrl,
            'shopBannerUrl': shopBannerUrl,
            'shopContactEmail': shopContactEmail,
            'shopContactPhone': shopContactPhone,
            'shopAddress': shopAddress,
            'shopCity': shopCity,
            'shopCountry': shopCountry,
            'shopPostalCode': shopPostalCode,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        // Detailed GraphQL error handling
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          debugPrint('🚨 Update Shop Settings GraphQL Error Details:');
          debugPrint('   Message: ${graphqlError.message}');
          debugPrint('   Locations: ${graphqlError.locations}');
          debugPrint('   Path: ${graphqlError.path}');
          debugPrint('   Extensions: ${graphqlError.extensions}');
          throw createError(ErrorCode.graphqlMutationError, details: 'Update Shop Settings GraphQL Error: ${graphqlError.message} (Path: ${graphqlError.path})');
        }
        
        // Detailed network error handling
        if (exception.linkException != null) {
          final linkException = exception.linkException!;
          debugPrint('🚨 Update Shop Settings Network Error Details:');
          debugPrint('   Type: ${linkException.runtimeType}');
          debugPrint('   Message: ${linkException.toString()}');
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update Shop Settings Network Error: ${linkException.runtimeType} - ${linkException.toString()}');
        }
        
        debugPrint('🚨 Update Shop Settings Unknown Exception Details:');
        debugPrint('   Type: ${exception.runtimeType}');
        debugPrint('   Message: ${exception.toString()}');
        throw createError(ErrorCode.unknown, details: 'Update Shop Settings Unknown Error: ${exception.runtimeType} - ${exception.toString()}');
      }

      final updateData = result.data?['updateShopSettings'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update shop settings');
      }

      debugPrint('✅ Shop settings updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update shop settings exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}



