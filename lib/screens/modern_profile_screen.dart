import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../utils/page_transitions.dart';
import '../data/country_codes.dart';
import '../services/share_service.dart';
import 'customer_analytics_screen.dart';

class ModernProfileScreen extends StatefulWidget {
  const ModernProfileScreen({super.key});

  @override
  State<ModernProfileScreen> createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            // Redirect to sign-in screen instead of showing login prompt
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/sign-in');
            });
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return CustomScrollView(
            slivers: [
              _buildProfileHeader(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 60), // Added bottom padding to fix overflow
                  child: Column(
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      // Show Business section first for suppliers
                      if (user?.accountType?.toLowerCase() == 'supplier' || user?.userType?.toLowerCase() == 'supplier') ...[
                        _buildMenuSection('Business', [
                          _buildMenuItem(
                            icon: Icons.store_outlined,
                            title: 'Supplier Dashboard',
                            subtitle: 'Manage your business',
                            onTap: () => Navigator.pushNamed(context, '/supplier-dashboard'),
                            hasArrow: true,
                          ),
                          _buildMenuItem(
                            icon: Icons.analytics_outlined,
                            title: 'Sales Analytics',
                            subtitle: 'View performance metrics',
                            onTap: () => Navigator.pushNamed(context, '/sales-analytics'),
                          ),
                          _buildMenuItem(
                            icon: Icons.people_outline,
                            title: 'Customer Analytics',
                            subtitle: 'Analyze customer behavior & insights',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerAnalyticsScreen()),
                            ),
                          ),
                        _buildMenuItem(
                          icon: Icons.add_circle_outline,
                          title: 'Create a Product',
                          subtitle: 'Add new product to your inventory',
                          onTap: () => Navigator.pushNamed(context, '/add-product'),
                        ),
                        _buildMenuItem(
                          icon: Icons.inventory_2_outlined,
                          title: 'Inventory Management',
                          subtitle: 'Manage your products',
                          onTap: () => Navigator.pushNamed(context, '/inventory-management'),
                        ),
                        ]),
                        const SizedBox(height: 24),
                      ],
                      _buildMenuSection('Account', [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          subtitle: 'Update your details',
                          onTap: () => Navigator.pushNamed(context, '/personal-info'),
                        ),
                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Order History',
                          subtitle: 'Track your orders',
                          onTap: () => Navigator.pushNamed(context, '/orders'),
                        ),
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          subtitle: 'Saved items',
                          onTap: () => Navigator.pushNamed(context, '/wishlist'),
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          subtitle: 'Manage delivery addresses',
                          onTap: () => Navigator.pushNamed(context, '/addresses'),
                        ),
                        _buildMenuItem(
                          icon: Icons.swap_horiz,
                          title: 'Account Type',
                          subtitle: 'Switch to Supplier/Reseller/Customer',
                          onTap: () => _showAccountTypeSwitcher(context),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildMenuSection('Security', [
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Reset Password',
                          subtitle: 'Change your password',
                          onTap: () => Navigator.pushNamed(context, '/reset-password'),
                        ),
                        _buildMenuItem(
                          icon: Icons.security_outlined,
                          title: 'Two-Factor Authentication',
                          subtitle: 'Add extra security to your account',
                          onTap: () => Navigator.pushNamed(context, '/two-factor-auth'),
                        ),
                        _buildMenuItem(
                          icon: Icons.devices_outlined,
                          title: 'Active Sessions',
                          subtitle: 'Manage your logged-in devices',
                          onTap: () => Navigator.pushNamed(context, '/active-sessions'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildMenuSection('Support', [
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'Get support and answers',
                          onTap: () => Navigator.pushNamed(context, '/help-center'),
                        ),
                        _buildMenuItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'Contact Us',
                          subtitle: 'Reach our support team',
                          onTap: () => Navigator.pushNamed(context, '/contact-us'),
                          hasArrow: true,
                        ),
                        _buildMenuItem(
                          icon: Icons.share,
                          title: 'Share App',
                          subtitle: 'Tell friends about Arc Vest',
                          onTap: () => ShareService.shareApp(),
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and info',
                          onTap: () => Navigator.pushNamed(context, '/about'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildMenuSection('Legal', [
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          subtitle: 'Platform terms and policies',
                          onTap: () => Navigator.pushNamed(context, '/terms-conditions'),
                        ),
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'How we handle your data',
                          onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                        ),
                      ]),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context, authProvider),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Further reduced to fix overflow
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditProfilePicture(context),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: Colors.white,
                          backgroundImage: _getProfileImage(user),
                          child: _getProfileImage(user) == null
                              ? Text(
                                  ((user?.name ?? user?['name'] ?? 'User').isNotEmpty 
                                      ? (user?.name ?? user?['name'] ?? 'User').substring(0, 1) 
                                      : 'U').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditProfilePicture(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? user?['name'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? user?['email'] ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // Account Type Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showAccountTypeInfo(context, user?.accountType ?? user?.userType ?? 'customer'),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Icon(
                        _getAccountTypeIcon(user?.accountType ?? user?.userType ?? 'customer'),
                        size: 16,
                        color: Colors.white,
                      ),
                          const SizedBox(width: 8),
                          Text(
                            _getAccountTypeLabel(user?.accountType ?? user?.userType ?? 'customer'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(
            icon: Icons.shopping_cart_outlined,
            label: 'Cart',
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          _buildQuickAction(
            icon: Icons.favorite_border,
            label: 'Wishlist',
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          _buildQuickAction(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          _buildQuickAction(
            icon: Icons.support_agent_outlined,
            label: 'Support',
            onTap: () => Navigator.pushNamed(context, '/help-center'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.divider.withOpacity(0.3),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (hasArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(context, authProvider),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'supplier':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getAccountTypeLabel(String userType) {
    switch (userType.toLowerCase()) {
      case 'supplier':
        return 'Supplier Account';
      case 'admin':
        return 'Admin Account';
      default:
        return 'Customer Account';
    }
  }

  void _showAccountTypeSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Account Type',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Choose your account type',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Account type options
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildAccountTypeOption(
                      context: context,
                      icon: Icons.person,
                      title: 'Customer',
                      subtitle: 'Buy products from suppliers',
                      onTap: () {
                        Navigator.pop(context);
                        _switchAccountType(context, 'customer');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAccountTypeOption(
                      context: context,
                      icon: Icons.store,
                      title: 'Supplier',
                      subtitle: 'Sell products to customers',
                      onTap: () {
                        Navigator.pop(context);
                        _switchAccountType(context, 'supplier');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountTypeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountTypeInfo(BuildContext context, String accountType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getAccountTypeLabel(accountType)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAccountTypeDescription(accountType),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Account Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._getAccountTypeFeatures(accountType).map((feature) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeDescription(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'supplier':
        return 'You have a Supplier account, which allows you to sell products to customers and manage your inventory.';
      case 'admin':
        return 'You have an Admin account with full system access and management capabilities.';
      default:
        return 'You have a Customer account, which allows you to browse and purchase products from suppliers.';
    }
  }

  List<String> _getAccountTypeFeatures(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'supplier':
        return [
          'Sell products to customers',
          'Manage inventory and stock',
          'View sales analytics',
          'Respond to customer reviews',
          'Manage product listings',
        ];
      case 'admin':
        return [
          'Full system access',
          'Manage all users',
          'View system analytics',
          'Moderate content',
          'System configuration',
        ];
      default:
        return [
          'Browse and search products',
          'Add items to cart and wishlist',
          'Place orders',
          'Track order history',
          'Leave product reviews',
        ];
    }
  }

  void _switchAccountType(BuildContext context, String newType) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Update the user type in the provider
    if (authProvider.currentUser != null) {
      final updatedUser = authProvider.currentUser!.copyWith(userType: newType);
      authProvider.updateUser(updatedUser);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${newType.toUpperCase()} account!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEditProfilePicture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Save button - only show if there's a selected image
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return _selectedImage != null
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => _saveProfileImageToBackend(authProvider),
                          icon: authProvider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                            authProvider.isLoading
                                ? 'Saving...'
                                : 'Save to Server',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Wholesalers B2B',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.store, size: 48),
      children: [
        const Text('A B2B marketplace for wholesalers and suppliers.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Update profile image locally only (don't save to backend yet)
        final authProvider = context.read<AuthProvider>();
        await authProvider.updateProfileImage(image.path);
        
        // Show message that image is ready to save
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture selected! Tap "Save" to upload to server.'),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    
    // Update profile image in AuthProvider
    final authProvider = context.read<AuthProvider>();
    authProvider.updateProfileImage(null);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture removed'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  ImageProvider? _getProfileImage(dynamic user) {
    // Priority: Selected image > User model profile image > Network image
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      // Check if it's a local file path or network URL
      if (user.profileImage!.startsWith('http')) {
        return NetworkImage(user.profileImage!);
      } else {
        return FileImage(File(user.profileImage!));
      }
    }
    return null;
  }

  Future<void> _saveProfileImageToBackend(AuthProvider authProvider) async {
    if (_selectedImage == null) return;

    try {
      // Show uploading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading profile picture to server...'),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Upload and save the profile image
      await authProvider.updateProfileImage(_selectedImage!.path);
      
      // Clear the selected image since it's now saved
      setState(() {
        _selectedImage = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture uploaded and saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading profile picture: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
