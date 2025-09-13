import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class VendorAnalyticsService {
  static Future<Map<String, dynamic>?> getVendorAnalytics({
    required String token,
    String? timeRange,
  }) async {
    try {
      debugPrint('🔄 Fetching vendor analytics...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.vendorAnalytics),
          variables: {
            'timeRange': timeRange ?? '7d',
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Vendor analytics endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final analytics = result.data?['vendorAnalytics'];
      debugPrint('✅ Vendor analytics fetched successfully');
      return analytics;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get vendor analytics exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getVendorOrders({
    required String token,
    String? status,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching vendor orders...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.vendorOrders),
          variables: {
            'status': status,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Vendor orders endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['vendorOrders']?['edges'] as List? ?? [];
      final orders = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${orders.length} vendor orders');
      return orders;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get vendor orders exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getVendorProducts({
    required String token,
    String? status,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching vendor products...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.vendorProducts),
          variables: {
            'status': status,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Vendor products endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['vendorProducts']?['edges'] as List? ?? [];
      final products = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${products.length} vendor products');
      return products;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get vendor products exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
