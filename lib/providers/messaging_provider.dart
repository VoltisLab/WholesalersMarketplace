import 'package:flutter/material.dart';
import '../services/messaging_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class MessagingProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedConversationId;

  // Getters
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedConversationId => _selectedConversationId;

  // Filtered conversations based on filter
  List<Map<String, dynamic>> getFilteredConversations(MessageFilter filter) {
    switch (filter) {
      case MessageFilter.all:
        return _conversations;
      case MessageFilter.unread:
        return _conversations.where((conv) => (conv['unreadCount'] as int? ?? 0) > 0).toList();
      case MessageFilter.read:
        return _conversations.where((conv) => (conv['unreadCount'] as int? ?? 0) == 0).toList();
      case MessageFilter.online:
        return _conversations.where((conv) => conv['isOnline'] == true).toList();
    }
  }

  // Load conversations from backend
  Future<void> loadConversations() async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view conversations');
      }

      debugPrint('🔄 Loading conversations from backend...');
      
      final conversationsData = await MessagingService.getMyConversations(token: token);
      
      _conversations = conversationsData;
      
      debugPrint('✅ Loaded ${_conversations.length} conversations');
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load conversations: ${e.toString()}');
      }
    } finally {
      setLoading(false);
    }
  }

  // Load the last conversation automatically
  Future<void> loadLastConversation() async {
    await loadConversations();
    
    if (_conversations.isNotEmpty) {
      // Sort conversations by timestamp (most recent first)
      _conversations.sort((a, b) {
        final aTime = a['timestamp'] as DateTime? ?? DateTime(1970);
        final bTime = b['timestamp'] as DateTime? ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      
      // Load the most recent conversation
      final lastConversation = _conversations.first;
      debugPrint('🔄 Auto-loading last conversation: ${lastConversation['id']}');
      await loadMessages(lastConversation['id']);
    }
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    setLoading(true);
    setError(null);
    _selectedConversationId = conversationId;

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view messages');
      }

      debugPrint('🔄 Loading messages for conversation: $conversationId');
      
      final messagesData = await MessagingService.getConversationMessages(
        token: token,
        conversationId: conversationId,
      );
      
      _messages = messagesData;
      
      debugPrint('✅ Loaded ${_messages.length} messages');
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load messages: ${e.toString()}');
      }
    } finally {
      setLoading(false);
    }
  }

  // Send a message
  Future<bool> sendMessage(String conversationId, String message) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to send messages');
      }

      debugPrint('🔄 Sending message to conversation: $conversationId');
      
      final messageData = await MessagingService.sendMessage(
        token: token,
        conversationId: conversationId,
        content: message,
      );
      
      if (messageData != null) {
        // Add the new message to the list
        _messages.add(messageData);
        
        // Update the conversation's last message
        final conversationIndex = _conversations.indexWhere(
          (conv) => conv['id'] == conversationId
        );
        if (conversationIndex != -1) {
          _conversations[conversationIndex]['lastMessage'] = message;
          _conversations[conversationIndex]['timestamp'] = DateTime.now();
        }
        
        notifyListeners();
      }
      
      debugPrint('✅ Message sent successfully');
      return true;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to send message: ${e.toString()}');
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Create a new conversation
  Future<Map<String, dynamic>?> createConversation(String recipientId) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to create conversation');
      }

      debugPrint('🔄 Creating conversation with: $recipientId');
      
      final conversationData = await MessagingService.createConversation(
        token: token,
        participantId: recipientId,
      );
      
      if (conversationData != null) {
        // Add the new conversation to the list
        _conversations.insert(0, conversationData);
        notifyListeners();
      }
      
      debugPrint('✅ Conversation created successfully');
      return conversationData;
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to create conversation: ${e.toString()}');
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      // TODO: Implement markMessageRead method in MessagingService
      // await MessagingService.markMessageRead(
      //   token: token,
      //   messageId: messageId,
      // );
      
      // Update local message state
      final messageIndex = _messages.indexWhere((msg) => msg['id'] == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex]['isRead'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark message as read: $e');
    }
  }

  // Mark all messages as read in a conversation
  Future<void> markAllMessagesAsRead(String conversationId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      // TODO: Implement markAllMessagesRead method in MessagingService
      // await MessagingService.markAllMessagesRead(
      //   token: token,
      //   conversationId: conversationId,
      // );
      
      // Update local conversation state
      final conversationIndex = _conversations.indexWhere(
        (conv) => conv['id'] == conversationId
      );
      if (conversationIndex != -1) {
        _conversations[conversationIndex]['unreadCount'] = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark all messages as read: $e');
    }
  }

  // Get conversation by ID
  Map<String, dynamic>? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((conv) => conv['id'] == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Get unread count for a conversation
  int getUnreadCount(String conversationId) {
    final conversation = getConversationById(conversationId);
    return conversation?['unreadCount'] as int? ?? 0;
  }

  // Get total unread count
  int get totalUnreadCount {
    return _conversations.fold(0, (sum, conv) => sum + (conv['unreadCount'] as int? ?? 0));
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    await loadConversations();
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    if (_selectedConversationId != null) {
      await loadMessages(_selectedConversationId!);
    }
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Format timestamp for display
  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Check if user is online
  bool isUserOnline(String userId) {
    // This would typically check against a real-time presence system
    // For now, we'll use a simple random check
    return DateTime.now().millisecond % 2 == 0;
  }
}

enum MessageFilter { all, unread, read, online }