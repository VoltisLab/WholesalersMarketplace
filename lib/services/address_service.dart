import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';

class AddressService {
  static Future<List<Map<String, dynamic>>> getMyAddresses(String token) async {
    try {
      debugPrint('🔄 Fetching user addresses...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myAddresses),
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors.first;
          throw createError(ErrorCode.graphqlQueryError, details: graphqlError.message);
        }
        
        if (exception.linkException != null) {
          throw createError(ErrorCode.networkConnectionFailed, details: 'Addresses endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final addresses = result.data?['myAddresses'] as List? ?? [];
      debugPrint('✅ Fetched ${addresses.length} addresses');
      return List<Map<String, dynamic>>.from(addresses);
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get addresses exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createAddress({
    required String token,
    required String name,
    required String phoneNumber,
    required String streetAddress,
    required String city,
    String? state,
    String? country,
    required String postalCode,
    String? addressType,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? instructions,
  }) async {
    try {
      debugPrint('🔄 Creating address for: $name');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createAddress),
          variables: {
            'name': name,
            'phoneNumber': phoneNumber,
            'streetAddress': streetAddress,
            'city': city,
            'state': state,
            'country': country ?? 'United States',
            'postalCode': postalCode,
            'addressType': addressType ?? 'home',
            'isDefault': isDefault ?? false,
            'latitude': latitude,
            'longitude': longitude,
            'instructions': instructions,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Create address endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createAddress'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create address');
      }

      debugPrint('✅ Address created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create address exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> updateAddress({
    required String token,
    required String addressId,
    String? name,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? addressType,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? instructions,
  }) async {
    try {
      debugPrint('🔄 Updating address: $addressId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateAddress),
          variables: {
            'addressId': addressId,
            'name': name,
            'phoneNumber': phoneNumber,
            'streetAddress': streetAddress,
            'city': city,
            'state': state,
            'country': country,
            'postalCode': postalCode,
            'addressType': addressType,
            'isDefault': isDefault,
            'latitude': latitude,
            'longitude': longitude,
            'instructions': instructions,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Update address endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final updateData = result.data?['updateAddress'];
      
      if (updateData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: updateData?['message'] ?? 'Failed to update address');
      }

      debugPrint('✅ Address updated successfully');
      return updateData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Update address exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<bool> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    try {
      debugPrint('🔄 Deleting address: $addressId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteAddress),
          variables: {
            'addressId': addressId,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Delete address endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final deleteData = result.data?['deleteAddress'];
      
      if (deleteData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: deleteData?['message'] ?? 'Failed to delete address');
      }

      debugPrint('✅ Address deleted successfully');
      return true;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Delete address exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
