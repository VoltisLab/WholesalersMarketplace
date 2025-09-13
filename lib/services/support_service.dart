import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';

class SupportService {
  static Future<Map<String, dynamic>?> createSupportTicket({
    required String token,
    required String ticketType,
    required String subject,
    required String description,
    String? priority,
    String? orderId,
    String? productId,
    List<String>? attachments,
  }) async {
    try {
      debugPrint('🔄 Creating support ticket: $subject');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createSupportTicket),
          variables: {
            'ticketType': ticketType,
            'priority': priority ?? 'medium',
            'subject': subject,
            'description': description,
            'orderId': orderId,
            'productId': productId,
            'attachments': attachments,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Support ticket endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createSupportTicket'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create support ticket');
      }

      debugPrint('✅ Support ticket created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create support ticket exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createFeedback({
    required String token,
    required String feedbackType,
    required String title,
    required String message,
    int? overallRating,
    int? easeOfUseRating,
    int? featuresRating,
    int? performanceRating,
    bool? isAnonymous,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
  }) async {
    try {
      debugPrint('🔄 Creating feedback: $title');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createFeedback),
          variables: {
            'feedbackType': feedbackType,
            'title': title,
            'message': message,
            'overallRating': overallRating,
            'easeOfUseRating': easeOfUseRating,
            'featuresRating': featuresRating,
            'performanceRating': performanceRating,
            'isAnonymous': isAnonymous ?? false,
            'deviceInfo': deviceInfo,
            'appVersion': appVersion,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Feedback endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createFeedback'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create feedback');
      }

      debugPrint('✅ Feedback created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create feedback exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createBugReport({
    required String token,
    required String bugType,
    required String severity,
    required String frequency,
    required String title,
    required String description,
    String? stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
    String? osVersion,
    String? browserInfo,
    List<String>? screenshots,
    List<String>? logFiles,
  }) async {
    try {
      debugPrint('🔄 Creating bug report: $title');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createBugReport),
          variables: {
            'bugType': bugType,
            'severity': severity,
            'frequency': frequency,
            'title': title,
            'description': description,
            'stepsToReproduce': stepsToReproduce,
            'expectedBehavior': expectedBehavior,
            'actualBehavior': actualBehavior,
            'deviceInfo': deviceInfo,
            'appVersion': appVersion,
            'osVersion': osVersion,
            'browserInfo': browserInfo,
            'screenshots': screenshots,
            'logFiles': logFiles,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Bug report endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createBugReport'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create bug report');
      }

      debugPrint('✅ Bug report created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create bug report exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
