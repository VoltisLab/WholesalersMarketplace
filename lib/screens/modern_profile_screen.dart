import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../utils/page_transitions.dart';
import '../data/country_codes.dart';
import '../services/share_service.dart';

class ModernProfileScreen extends StatefulWidget {
  const ModernProfileScreen({super.key});

  @override
  State<ModernProfileScreen> createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {

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
                      _buildMenuSection('Account', [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          subtitle: 'Update your details',
                          onTap: () => Navigator.pushNamed(context, '/personal-info'),
                        ),
                        _buildMenuItem(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          subtitle: 'Update your phone number',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone editing coming soon!'),
                                backgroundColor: AppColors.info,
                              ),
                            );
                          },
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
                          subtitle: 'Switch to Vendor/Reseller/Customer',
                          onTap: () => _showAccountTypeSwitcher(context),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildMenuSection('Business', [
                        _buildMenuItem(
                          icon: Icons.store_outlined,
                          title: 'Vendor Dashboard',
                          subtitle: 'Manage your business',
                          onTap: () => Navigator.pushNamed(context, '/vendor-dashboard'),
                          hasArrow: true,
                        ),
                        _buildMenuItem(
                          icon: Icons.analytics_outlined,
                          title: 'Sales Analytics',
                          subtitle: 'View performance metrics',
                          onTap: () => Navigator.pushNamed(context, '/sales-analytics'),
                        ),
                        _buildMenuItem(
                          icon: Icons.inventory_2_outlined,
                          title: 'Inventory Management',
                          subtitle: 'Manage your products',
                          onTap: () => Navigator.pushNamed(context, '/inventory-management'),
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
                          onTap: () => _showAboutDialog(context),
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Privacy Policy coming soon!'),
                                backgroundColor: AppColors.info,
                              ),
                            );
                          },
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
                    Container(
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
                        child: Text(
                          (user?.name ?? user?['name'] ?? 'User').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAccountTypeIcon(user?.userType ?? user?['userType'] ?? 'customer'),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getAccountTypeLabel(user?.userType ?? user?['userType'] ?? 'customer'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
      case 'vendor':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getAccountTypeLabel(String userType) {
    switch (userType.toLowerCase()) {
      case 'vendor':
        return 'Vendor Account';
      case 'admin':
        return 'Admin Account';
      default:
        return 'Customer Account';
    }
  }

  void _showAccountTypeSwitcher(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account type switching coming soon!'),
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
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
