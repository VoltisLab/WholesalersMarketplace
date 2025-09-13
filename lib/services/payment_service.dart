import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class PaymentService {
  static Future<List<Map<String, dynamic>>> getMyPaymentMethods({
    required String token,
  }) async {
    try {
      debugPrint('🔄 Fetching payment methods...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myPaymentMethods),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Payment methods endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final paymentMethods = result.data?['myPaymentMethods'] as List? ?? [];
      final methods = paymentMethods.map((method) => method as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${methods.length} payment methods');
      return methods;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get payment methods exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> addPaymentMethod({
    required String token,
    required String paymentType,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    required String cardHolderName,
    bool isDefault = false,
  }) async {
    try {
      debugPrint('🔄 Adding payment method...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.addPaymentMethod),
          variables: {
            'paymentType': paymentType,
            'cardNumber': cardNumber,
            'expiryMonth': expiryMonth,
            'expiryYear': expiryYear,
            'cvv': cvv,
            'cardHolderName': cardHolderName,
            'isDefault': isDefault,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Add payment method endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final addData = result.data?['addPaymentMethod'];
      
      if (addData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: addData?['message'] ?? 'Failed to add payment method');
      }

      debugPrint('✅ Payment method added successfully');
      return addData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Add payment method exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> updatePaymentMethod({
    required String token,
    required String paymentMethodId,
    bool? isDefault,
    bool? isActive,
  }) async {
    try {
      debugPrint('🔄 Updating payment method: $paymentMethodId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updatePaymentMethod),
          variables: {
            'paymentMethodId': paymentMethodId,
            'isDefault': isDefault,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update payment method endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updatePaymentMethod'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update payment method');
      }

      debugPrint('✅ Payment method updated successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update payment method exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> deletePaymentMethod({
    required String token,
    required String paymentMethodId,
  }) async {
    try {
      debugPrint('🔄 Deleting payment method: $paymentMethodId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deletePaymentMethod),
          variables: {
            'paymentMethodId': paymentMethodId,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Delete payment method endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final deleteData = result.data?['deletePaymentMethod'];
      
      if (deleteData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: deleteData?['message'] ?? 'Failed to delete payment method');
      }

      debugPrint('✅ Payment method deleted successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Delete payment method exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
