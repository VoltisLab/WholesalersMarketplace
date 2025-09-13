import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/vendor_provider.dart';
import '../providers/messaging_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  MessageFilter _currentFilter = MessageFilter.all;
  String? _selectedConversationId;

  // Sample data for development
  List<Map<String, dynamic>> _sampleTransactions = [
    {'date': DateTime.now().subtract(const Duration(days: 1))},
    {'date': DateTime.now().subtract(const Duration(days: 2))},
    {'date': DateTime.now().subtract(const Duration(days: 3))},
  ];

  List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'John Doe',
      'lastMessage': 'Thanks for the quick delivery!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'unreadCount': 2,
      'isOnline': true,
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'lastMessage': 'Can you provide more details about the product?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'https://via.placeholder.com/50',
    },
  ];

  List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello! I\'m interested in your product.',
      'isFromMe': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'id': '2',
      'text': 'Hi! I\'d be happy to help. What would you like to know?',
      'isFromMe': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load conversations when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    final messagingProvider = context.read<MessagingProvider>();
    return messagingProvider.getFilteredConversations(_currentFilter);
  }

  String _getFilterDisplayName(MessageFilter filter) {
    switch (filter) {
      case MessageFilter.all:
        return 'All';
      case MessageFilter.unread:
        return 'Unread';
      case MessageFilter.read:
        return 'Read';
      case MessageFilter.online:
        return 'Online';
    }
  }

  int _getFilterCount(MessageFilter filter) {
    final messagingProvider = context.read<MessagingProvider>();
    return messagingProvider.getFilteredConversations(filter).length;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedConversationId == null) return;

    final messagingProvider = context.read<MessagingProvider>();
    messagingProvider.sendMessage(
      _selectedConversationId!,
      _messageController.text.trim(),
    );

    _messageController.clear();
  }

  void _showRelationshipDetails(Map<String, dynamic> conversation) {
    print('_showRelationshipDetails called for: ${conversation['name']}');
    // TODO: Load real transaction data from backend
    final totalSpent = 0.0;
    final totalRefunds = 0.0;
    final netSpent = totalSpent - totalRefunds;
    final orderCount = 0;
    final relationshipDays = 0; // TODO: Calculate from real data

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: CachedNetworkImageProvider(conversation['avatar']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Relationship with ${conversation['name']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Customer since ${_formatDate(_sampleTransactions.last['date'])}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildRelationshipStats(netSpent, orderCount, relationshipDays),
                    const SizedBox(height: 24),
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _sampleTransactions.length,
                        itemBuilder: (context, index) {
                          final txn = _sampleTransactions[index];
                          return _buildTransactionCard(txn);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipStats(double netSpent, int orderCount, int relationshipDays) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total Spent', '£${netSpent.toStringAsFixed(2)}', AppColors.primary),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _buildStatItem('Orders', orderCount.toString(), AppColors.success),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _buildStatItem('Relationship', '${relationshipDays} days', AppColors.warning),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    final isRefund = txn['type'] == 'Refund';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                txn['orderId'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRefund ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  txn['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isRefund ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(txn['date']),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            txn['items'].join(', '),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${isRefund ? '-' : '+'}£${txn['amount'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isRefund ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedConversationId == null
          ? _buildConversationsAppBar()
          : _buildChatAppBar(),
      body: _selectedConversationId == null
          ? Column(
              children: [
                _buildFilterTabs(),
                Expanded(
                  child: Consumer<MessagingProvider>(
                    builder: (context, messagingProvider, child) {
                      if (messagingProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (messagingProvider.error != null) {
                        return Center(
                          child: Text('Error: ${messagingProvider.error}'),
                        );
                      }
                      return _buildConversationsList();
                    },
                  ),
                ),
              ],
            )
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
    final messagingProvider = context.read<MessagingProvider>();
    final conversation = messagingProvider.conversations.firstWhere(
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onSelected: (value) {
            print('Selected menu item: $value');
            if (value == 'relationship') {
              print('Showing relationship details for: ${conversation['name']}');
              _showRelationshipDetails(conversation);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'relationship',
              child: Row(
                children: [
                  Icon(Icons.handshake, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Relationship'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MessageFilter.values.map((filter) {
            final isSelected = _currentFilter == filter;
            final count = _getFilterCount(filter);
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFilterDisplayName(filter),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentFilter = filter;
                    });
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider.withOpacity(0.3),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final filteredConversations = _filteredConversations;
    
    if (filteredConversations.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedConversationId = conversation['id'];
            });
            // Load messages for this conversation
            context.read<MessagingProvider>().loadMessages(conversation['id']);
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

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_currentFilter) {
      case MessageFilter.unread:
        message = 'No unread messages';
        icon = Icons.mark_email_read;
        break;
      case MessageFilter.read:
        message = 'No read messages';
        icon = Icons.drafts;
        break;
      case MessageFilter.online:
        message = 'No vendors online';
        icon = Icons.wifi_off;
        break;
      case MessageFilter.all:
      default:
        message = 'No conversations yet';
        icon = Icons.chat_bubble_outline;
        break;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentFilter == MessageFilter.all
                ? 'Start browsing products to connect with vendors'
                : 'Try switching to a different filter',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: Consumer<MessagingProvider>(
            builder: (context, messagingProvider, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: messagingProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = messagingProvider.messages[index];
                  return _buildMessageBubble(message);
                },
              );
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
