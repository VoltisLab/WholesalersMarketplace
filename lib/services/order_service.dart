import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class OrderService {
  static Future<List<Map<String, dynamic>>> getMyOrders({
    required String token,
    String? status,
  }) async {
    try {
      debugPrint('🔄 Fetching user orders...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myOrders),
          variables: {
            'status': status,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Orders endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final orders = result.data?['myOrders'] as List? ?? [];
      debugPrint('✅ Fetched ${orders.length} orders');
      return List<Map<String, dynamic>>.from(orders);
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get orders exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createOrder({
    required String token,
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      debugPrint('🔄 Creating order...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createOrder),
          variables: {
            'orderData': orderData,
            'items': items,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Create order endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createOrder'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create order');
      }

      debugPrint('✅ Order created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create order exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> getOrderById({
    required String token,
    required String orderId,
  }) async {
    try {
      debugPrint('🔄 Fetching order: $orderId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql('''
            query GetOrderById(\$id: ID!) {
              orderById(id: \$id) {
                id
                orderNumber
                status
                paymentStatus
                subtotal
                taxAmount
                shippingCost
                totalAmount
                shippingAddress
                billingAddress
                paymentMethod
                trackingNumber
                notes
                createdAt
                updatedAt
                items {
                  id
                  productName
                  quantity
                  unitPrice
                  totalPrice
                  productImage
                }
              }
            }
          '''),
          variables: {'id': orderId},
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Order endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final order = result.data?['orderById'];
      
      if (order == null) {
        throw createError(ErrorCode.orderNotFound, details: 'Order not found');
      }

      debugPrint('✅ Order fetched successfully');
      return order;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get order exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      debugPrint('🔄 Updating order status: $orderId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql('''
            mutation UpdateOrderStatus(
              \$orderId: ID!,
              \$status: String!,
              \$trackingNumber: String,
              \$notes: String
            ) {
              updateOrderStatus(
                orderId: \$orderId,
                status: \$status,
                trackingNumber: \$trackingNumber,
                notes: \$notes
              ) {
                order {
                  id
                  status
                  trackingNumber
                  notes
                  updatedAt
                }
                success
                message
              }
            }
          '''),
          variables: {
            'orderId': orderId,
            'status': status,
            'trackingNumber': trackingNumber,
            'notes': notes,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update order endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateOrderStatus'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update order');
      }

      debugPrint('✅ Order status updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update order exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> cancelOrder({
    required String token,
    required String orderId,
    String? reason,
  }) async {
    try {
      debugPrint('🔄 Cancelling order: $orderId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql('''
            mutation CancelOrder(\$orderId: ID!, \$reason: String) {
              cancelOrder(orderId: \$orderId, reason: \$reason) {
                success
                message
              }
            }
          '''),
          variables: {
            'orderId': orderId,
            'reason': reason,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Cancel order endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final cancelData = result.data?['cancelOrder'];
      
      if (cancelData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: cancelData?['message'] ?? 'Failed to cancel order');
      }

      debugPrint('✅ Order cancelled successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Cancel order exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> trackOrder({
    required String token,
    required String orderId,
  }) async {
    try {
      debugPrint('🔄 Tracking order $orderId...');
      
      final authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.trackOrder),
          variables: {
            'orderId': orderId,
          },
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          final errorMessage = graphqlError.message;
          throw createError(ErrorCode.graphqlQueryError, details: errorMessage);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, 
            details: 'Track order endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final trackData = result.data?['trackOrder'];
      if (trackData != null) {
        debugPrint('✅ Order $orderId tracking data retrieved');
        return trackData;
      }
      
      throw createError(ErrorCode.graphqlQueryError, 
        details: 'No tracking data found for order');
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Track order exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
