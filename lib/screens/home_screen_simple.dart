import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/enhanced_product_provider.dart';
import '../widgets/vendor_card.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';
import '../utils/page_transitions.dart';
import 'vendor_list_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'vendor_dashboard_screen.dart';

class HomeScreenSimple extends StatefulWidget {
  const HomeScreenSimple({super.key});

  @override
  State<HomeScreenSimple> createState() => _HomeScreenSimpleState();
}

class _HomeScreenSimpleState extends State<HomeScreenSimple> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedTab(),
          const SearchScreen(),
          const VendorListScreen(),
          const CartScreen(),
          authProvider.isVendor ? const VendorDashboardScreen() : const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFeedTab() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildTrendingProducts(),
              const SizedBox(height: 24),
              _buildFeaturedVendors(),
              const SizedBox(height: 24),
              _buildCategoryShowcase(),
              const SizedBox(height: 24),
              _buildRecentlyAdded(),
              const SizedBox(height: 24),
              _buildPopularProducts(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Arc Vest',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          actions: [
            badges.Badge(
              badgeContent: Text(
                cartProvider.itemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: cartProvider.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.slideFromBottom(const CartScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildTrendingProducts() {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        final trendingProducts = productProvider.products.take(8).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.trending_up, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Trending Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                itemCount: trendingProducts.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(product: trendingProducts[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Arc Vest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover amazing vendors and products near you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransitions.slideFromRight(const VendorListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Browse Vendors'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.map, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map view requires Google Maps API key'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedVendors() {
    return Consumer2<VendorProvider, EnhancedProductProvider>(
      builder: (context, vendorProvider, productProvider, child) {
        final featuredVendors = vendorProvider.vendors.where((v) => v.isVerified).take(4).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Featured Collections',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280, // Increased height for gallery design
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                itemCount: featuredVendors.length,
                itemBuilder: (context, index) {
                  final vendor = featuredVendors[index];
                  final vendorProducts = productProvider.products
                      .where((p) => p.vendor.id == vendor.id)
                      .take(4)
                      .toList();
                  
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildVendorGalleryCard(vendor, vendorProducts),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVendorGalleryCard(VendorModel vendor, List<ProductModel> products) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/vendor-shop',
          arguments: vendor,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor header with logo and name
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: vendor.logo,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.store, size: 20),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.store, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.warning, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              vendor.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (vendor.isVerified)
                    const Icon(Icons.verified, color: AppColors.primary, size: 16),
                ],
              ),
            ),
            
            // Product gallery grid (2x2)
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: products.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.divider.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No products',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          if (index < products.length) {
                            final product = products[index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider.withOpacity(0.3)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.images.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.divider.withOpacity(0.3),
                                    child: const Center(
                                      child: Icon(Icons.image, size: 20, color: AppColors.textSecondary),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColors.divider.withOpacity(0.3),
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 20, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Empty placeholder
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.divider.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider.withOpacity(0.3)),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),
            
            // View collection button
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Text(
                  'View Collection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShowcase() {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        final categories = ['Dresses', 'Outerwear', 'Bags', 'Shoes', 'Accessories', 'Tops'];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: AppColors.info),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Shop by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final color = _getCategoryColor(index);
                  final icon = _getCategoryIcon(category);
                  
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () {
                        productProvider.setSelectedCategory(category);
                        Navigator.push(
                          context,
                          PageTransitions.slideAndFade(const SearchScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                            ),
                            child: Icon(icon, color: color, size: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentlyAdded() {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        final recentProducts = productProvider.products.skip(20).take(6).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fiber_new, color: AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Recently Added',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recentProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: recentProducts[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopularProducts() {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        final popularProducts = productProvider.products.skip(50).take(4).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_fire_department, color: AppColors.warning),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Popular This Week',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: popularProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: popularProducts[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dresses':
        return Icons.checkroom_rounded;
      case 'Outerwear':
        return Icons.dry_cleaning_rounded;
      case 'Bags':
        return Icons.shopping_bag_rounded;
      case 'Shoes':
        return Icons.directions_walk_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'Tops':
        return Icons.checkroom_rounded;
      case 'Electronics':
        return Icons.phone_android_rounded;
      case 'Fashion':
        return Icons.shopping_bag_rounded;
      case 'Home':
        return Icons.home_rounded;
      case 'Beauty':
        return Icons.face_rounded;
      case 'Sports':
        return Icons.sports_soccer_rounded;
      case 'Books':
        return Icons.book_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildBottomNavigationBar() {
    final authProvider = context.watch<AuthProvider>();
    
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dynamic_feed_rounded),
          activeIcon: Icon(Icons.dynamic_feed_rounded),
          label: 'Feed',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          activeIcon: Icon(Icons.store_rounded),
          label: 'Suppliers',
        ),
        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return badges.Badge(
                badgeContent: Text(
                  cartProvider.itemCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                showBadge: cartProvider.itemCount > 0,
                child: const Icon(Icons.shopping_cart_rounded),
              );
            },
          ),
          activeIcon: const Icon(Icons.shopping_cart_rounded),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(authProvider.isVendor ? Icons.dashboard_rounded : Icons.person_rounded),
          activeIcon: Icon(authProvider.isVendor ? Icons.dashboard_rounded : Icons.person_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}
