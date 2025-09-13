import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class InventoryService {
  static Future<List<Map<String, dynamic>>> getInventoryItems({
    required String token,
    String? filter,
    String? sortBy,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching inventory items...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.inventoryItems),
          variables: {
            'filter': filter,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Inventory items endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['inventoryItems']?['edges'] as List? ?? [];
      final items = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${items.length} inventory items');
      return items;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get inventory items exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateInventoryItem({
    required String token,
    required String itemId,
    int? stockQuantity,
    int? lowStockThreshold,
    double? price,
    bool? isActive,
  }) async {
    try {
      debugPrint('🔄 Updating inventory item: $itemId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateInventoryItem),
          variables: {
            'itemId': itemId,
            'stockQuantity': stockQuantity,
            'lowStockThreshold': lowStockThreshold,
            'price': price,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update inventory item endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateInventoryItem'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update inventory item');
      }

      debugPrint('✅ Inventory item updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update inventory item exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
