import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class WishlistService {
  static Future<List<Map<String, dynamic>>> getMyWishlist(String token) async {
    try {
      debugPrint('🔄 Fetching user wishlist...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myWishlist),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Wishlist endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final wishlist = result.data?['myWishlist'] as List? ?? [];
      debugPrint('✅ Fetched ${wishlist.length} wishlist items');
      return List<Map<String, dynamic>>.from(wishlist);
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get wishlist exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> addToWishlist({
    required String token,
    required String productId,
  }) async {
    try {
      debugPrint('🔄 Adding product to wishlist: $productId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.addToWishlist),
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Add to wishlist endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final addData = result.data?['addToWishlist'];
      
      if (addData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: addData?['message'] ?? 'Failed to add to wishlist');
      }

      debugPrint('✅ Product added to wishlist successfully');
      return addData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Add to wishlist exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> removeFromWishlist({
    required String token,
    required String productId,
  }) async {
    try {
      debugPrint('🔄 Removing product from wishlist: $productId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.removeFromWishlist),
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Remove from wishlist endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final removeData = result.data?['removeFromWishlist'];
      
      if (removeData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: removeData?['message'] ?? 'Failed to remove from wishlist');
      }

      debugPrint('✅ Product removed from wishlist successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Remove from wishlist exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> isInWishlist({
    required String token,
    required String productId,
  }) async {
    try {
      final wishlist = await getMyWishlist(token);
      return wishlist.any((item) => item['product']?['id'] == productId);
    } catch (e) {
      debugPrint('Error checking wishlist status: $e');
      return false;
    }
  }
}
