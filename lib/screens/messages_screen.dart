import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/vendor_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'senderId': 'vendor_1',
      'senderName': 'Urban Streetwear Co.',
      'senderAvatar': 'https://picsum.photos/40/40?random=1',
      'message': 'Hey! Thanks for your interest in our Y2K Leather Bomber Jackets. We have them in stock in all sizes.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isMe': false,
    },
    {
      'id': '2',
      'senderId': 'me',
      'senderName': 'You',
      'senderAvatar': 'https://picsum.photos/40/40?random=100',
      'message': 'Great! What\'s the wholesale price for a bulk order of 50 pieces?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      'isMe': true,
    },
    {
      'id': '3',
      'senderId': 'vendor_1',
      'senderName': 'Urban Streetwear Co.',
      'senderAvatar': 'https://picsum.photos/40/40?random=1',
      'message': 'For 50 pieces, we can offer £180 per jacket. That includes free shipping and a 30-day return policy.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      'isMe': false,
    },
    {
      'id': '4',
      'senderId': 'me',
      'senderName': 'You',
      'senderAvatar': 'https://picsum.photos/40/40?random=100',
      'message': 'That sounds reasonable. Can you send me the size chart and available colors?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
      'isMe': true,
    },
    {
      'id': '5',
      'senderId': 'vendor_1',
      'senderName': 'Urban Streetwear Co.',
      'senderAvatar': 'https://picsum.photos/40/40?random=1',
      'message': 'Absolutely! I\'ll send you the complete catalog with measurements. We have Black, Brown, and Vintage Tan available.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isMe': false,
    },
  ];

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 'vendor_1',
      'name': 'Urban Streetwear Co.',
      'avatar': 'https://picsum.photos/50/50?random=1',
      'lastMessage': 'Absolutely! I\'ll send you the complete catalog...',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'unreadCount': 0,
      'isOnline': true,
    },
    {
      'id': 'vendor_2',
      'name': 'Vintage Denim House',
      'avatar': 'https://picsum.photos/50/50?random=2',
      'lastMessage': 'The Levi\'s 501 jeans are back in stock!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'unreadCount': 2,
      'isOnline': false,
    },
    {
      'id': 'vendor_3',
      'name': 'Athletic Gear Pro',
      'avatar': 'https://picsum.photos/50/50?random=3',
      'lastMessage': 'Thanks for the order! Shipping tomorrow.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
      'isOnline': true,
    },
    {
      'id': 'vendor_4',
      'name': 'Luxury Accessories Ltd',
      'avatar': 'https://picsum.photos/50/50?random=4',
      'lastMessage': 'New Burberry collection available',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'unreadCount': 1,
      'isOnline': false,
    },
  ];

  String? _selectedConversationId;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': 'me',
        'senderName': 'You',
        'senderAvatar': 'https://picsum.photos/40/40?random=100',
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isMe': true,
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedConversationId == null
          ? _buildConversationsAppBar()
          : _buildChatAppBar(),
      body: _selectedConversationId == null
          ? _buildConversationsList()
          : _buildChatView(),
    );
  }

  PreferredSizeWidget _buildConversationsAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        'Messages',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement search
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement more options
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    final conversation = _conversations.firstWhere(
      (c) => c['id'] == _selectedConversationId,
    );

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () {
          setState(() {
            _selectedConversationId = null;
          });
        },
      ),
      title: InkWell(
        onTap: () {
          // Navigate to vendor profile
          _openVendorProfile(conversation);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(conversation['avatar']),
                  ),
                  if (conversation['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation['name'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    Text(
                      conversation['isOnline'] ? 'Online' : 'Last seen recently',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement voice call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement more options
          },
        ),
      ],
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedConversationId = conversation['id'];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: 12,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(conversation['avatar']),
                    ),
                    if (conversation['isOnline'])
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimestamp(conversation['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation['lastMessage'],
                              style: TextStyle(
                                fontSize: 14,
                                color: conversation['unreadCount'] > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: conversation['unreadCount'] > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation['unreadCount'] > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation['unreadCount'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(message['senderAvatar']),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: !isMe ? Border.all(color: AppColors.divider.withOpacity(0.3)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(message['senderAvatar']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Implement file attachment
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _openVendorProfile(Map<String, dynamic> conversation) {
    // Find the vendor from the conversation data
    // For demo purposes, we'll use the first vendor from the provider
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final vendor = vendorProvider.vendors.first; // In a real app, match by conversation ID
    
    Navigator.pushNamed(
      context,
      '/vendor-shop',
      arguments: vendor,
    );
  }
}
