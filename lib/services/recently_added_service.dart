import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';

class RecentlyAddedService {
  static Future<List<Map<String, dynamic>>> getRecentlyAddedProducts({
    int limit = 6,
  }) async {
    try {
      debugPrint('🔄 Fetching recently added products...');
      
      final String query = '''
        query RecentlyAddedProducts(\$sort: SortEnum, \$pageCount: Int, \$pageNumber: Int) {
          allProducts(
            sort: \$sort,
            pageCount: \$pageCount,
            pageNumber: \$pageNumber
          ) {
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
      ''';
      
      final QueryResult result = await GraphQLService.client.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'sort': 'NEWEST',
            'pageCount': limit,
            'pageNumber': 1,
          },
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

      final List<dynamic> products = result.data?['allProducts'] ?? [];
      debugPrint('✅ Fetched ${products.length} recently added products');
      
      return products.cast<Map<String, dynamic>>();
      
    } catch (e) {
      debugPrint('❌ Error fetching recently added products: $e');
      if (e is AppError) {
        rethrow;
      }
      throw createError(ErrorCode.unknown, details: e.toString());
    }
  }
}
