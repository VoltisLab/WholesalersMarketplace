import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class CartService {
  static Future<Map<String, dynamic>?> getMyCart(String token) async {
    try {
      debugPrint('🔄 Fetching user cart...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myCart),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Cart endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final cart = result.data?['myCart'];
      debugPrint('✅ Cart fetched successfully');
      return cart;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get cart exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> addToCart({
    required String token,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      debugPrint('🔄 Adding product to cart: $productId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.addToCart),
          variables: {
            'productId': productId,
            'quantity': quantity,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Add to cart endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final addData = result.data?['addToCart'];
      
      if (addData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: addData?['message'] ?? 'Failed to add to cart');
      }

      debugPrint('✅ Product added to cart successfully');
      return addData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Add to cart exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateCartItem({
    required String token,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      debugPrint('🔄 Updating cart item: $cartItemId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateCartItem),
          variables: {
            'cartItemId': cartItemId,
            'quantity': quantity,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update cart item endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateCartItem'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update cart item');
      }

      debugPrint('✅ Cart item updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update cart item exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> removeFromCart({
    required String token,
    required String cartItemId,
  }) async {
    try {
      debugPrint('🔄 Removing cart item: $cartItemId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.removeFromCart),
          variables: {
            'cartItemId': cartItemId,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Remove from cart endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final removeData = result.data?['removeFromCart'];
      
      if (removeData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: removeData?['message'] ?? 'Failed to remove from cart');
      }

      debugPrint('✅ Cart item removed successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Remove from cart exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> clearCart(String token) async {
    try {
      debugPrint('🔄 Clearing cart...');
      
      // Get current cart items first
      final cart = await getMyCart(token);
      final items = cart?['items'] as List? ?? [];
      
      // Remove each item
      for (final item in items) {
        final itemId = item['id'] as String?;
        if (itemId != null) {
          await removeFromCart(token: token, cartItemId: itemId);
        }
      }
      
      debugPrint('✅ Cart cleared successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Clear cart exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
