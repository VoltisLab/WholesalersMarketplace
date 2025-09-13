import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'error_service.dart';
import 'token_service.dart';

class MessagingService {
  static Future<List<Map<String, dynamic>>> getMyConversations({
    required String token,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching conversations...');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.myConversations),
          variables: {
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Conversations endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['myConversations']?['edges'] as List? ?? [];
      final conversations = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${conversations.length} conversations');
      return conversations;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get conversations exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<List<Map<String, dynamic>>> getConversationMessages({
    required String token,
    required String conversationId,
    int? first,
    String? after,
  }) async {
    try {
      debugPrint('🔄 Fetching conversation messages: $conversationId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.conversationMessages),
          variables: {
            'conversationId': conversationId,
            'first': first ?? 50,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Conversation messages endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final edges = result.data?['conversationMessages']?['edges'] as List? ?? [];
      final messages = edges.map((edge) => edge['node'] as Map<String, dynamic>).toList();
      
      debugPrint('✅ Fetched ${messages.length} messages');
      return messages;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Get conversation messages exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> sendMessage({
    required String token,
    required String conversationId,
    required String content,
  }) async {
    try {
      debugPrint('🔄 Sending message to conversation: $conversationId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.sendMessage),
          variables: {
            'conversationId': conversationId,
            'content': content,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Send message endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final sendData = result.data?['sendMessage'];
      
      if (sendData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: sendData?['message'] ?? 'Failed to send message');
      }

      debugPrint('✅ Message sent successfully');
      return sendData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Send message exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }

  static Future<Map<String, dynamic>?> createConversation({
    required String token,
    required String participantId,
  }) async {
    try {
      debugPrint('🔄 Creating conversation with participant: $participantId');
      
      final GraphQLClient authenticatedClient = GraphQLService.getAuthenticatedClient(token);
      
      final QueryResult result = await authenticatedClient.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createConversation),
          variables: {
            'participantId': participantId,
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
          throw createError(ErrorCode.networkConnectionFailed, details: 'Create conversation endpoint unreachable');
        }
        
        throw createError(ErrorCode.unknown, details: exception.toString());
      }

      final createData = result.data?['createConversation'];
      
      if (createData?['success'] != true) {
        throw createError(ErrorCode.graphqlMutationError, details: createData?['message'] ?? 'Failed to create conversation');
      }

      debugPrint('✅ Conversation created successfully');
      return createData;
      
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      
      final error = createError(
        ErrorCode.unknown, 
        details: 'Create conversation exception: ${e.toString()}',
        stackTrace: StackTrace.current.toString(),
      );
      throw error;
    }
  }
}
