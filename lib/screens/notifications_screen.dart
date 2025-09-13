import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/notification_provider.dart';
import '../services/graphql_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _isLoadingPreferences = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load notifications and preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _loadNotificationPreferences();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      final preferences = await NotificationService.getMyNotificationPreferences(token: token);
      
      if (mounted && preferences.isNotEmpty) {
        setState(() {
          _pushNotifications = preferences['pushNotifications'] ?? true;
          _emailNotifications = preferences['emailNotifications'] ?? false;
          _orderUpdates = preferences['orderUpdates'] ?? true;
          _promotions = preferences['promotions'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<void> _updateNotificationPreferences() async {
    setState(() => _isLoadingPreferences = true);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to update preferences');
      }

      await NotificationService.updateNotificationPreferences(
        token: token,
        pushNotifications: _pushNotifications,
        emailNotifications: _emailNotifications,
        orderUpdates: _orderUpdates,
        promotions: _promotions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update preferences';
        if (e is AppError) {
          errorMessage = e.userMessage;
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPreferences = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.notifications)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(),
          _buildPreferencesTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notificationProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notificationProvider.loadNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (notificationProvider.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll notify you about important updates',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: notificationProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationProvider.notifications[index];
            return _buildNotificationCard(notification, notificationProvider);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? AppColors.surface : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead 
              ? AppColors.textSecondary.withOpacity(0.3)
              : AppColors.primary,
          child: Icon(
            _getNotificationIcon(notification.type),
            color: notification.isRead ? AppColors.textSecondary : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            provider.markNotificationRead(notification.id);
          }
        },
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        const Text(
          'Notification Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications on your device'),
                value: _pushNotifications,
                onChanged: _isLoadingPreferences ? null : (value) {
                  setState(() => _pushNotifications = value);
                  _updateNotificationPreferences();
                },
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive notifications via email'),
                value: _emailNotifications,
                onChanged: _isLoadingPreferences ? null : (value) {
                  setState(() => _emailNotifications = value);
                  _updateNotificationPreferences();
                },
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Order Updates'),
                subtitle: const Text('Get notified about order status changes'),
                value: _orderUpdates,
                onChanged: _isLoadingPreferences ? null : (value) {
                  setState(() => _orderUpdates = value);
                  _updateNotificationPreferences();
                },
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Promotions & Offers'),
                subtitle: const Text('Receive promotional notifications'),
                value: _promotions,
                onChanged: _isLoadingPreferences ? null : (value) {
                  setState(() => _promotions = value);
                  _updateNotificationPreferences();
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoadingPreferences)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
