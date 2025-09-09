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
import 'enhanced_vendor_list_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'vendor_dashboard_screen.dart';
import 'home_screen.dart';

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
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedTab(),
          const SearchScreen(),
          const EnhancedVendorListScreen(),
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
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildSearchTags(),
              const SizedBox(height: 24),
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildSliderBanner(),
              const SizedBox(height: 24),
              _buildTrendingProducts(),
              const SizedBox(height: 24),
              _buildFeaturedVendors(),
              const SizedBox(height: 24),
              _buildCategoryShowcase(),
              const SizedBox(height: 16),
              _buildRecentlyAdded(),
              const SizedBox(height: 16),
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
            'Wholesalers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
            ),
            badges.Badge(
              badgeContent: Text(
                cartProvider.itemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      PageTransitions.slideFromBottom(const EnhancedVendorListScreen()),
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
                    Navigator.push(
                      context,
                      PageTransitions.slideFromRight(const HomeScreen()),
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
              child: const Text(
                'Featured Collections',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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
          border: Border.all(
            color: AppColors.divider.withOpacity(0.3),
            width: 0.5,
          ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.8),
                                  color.withOpacity(0.6),
                                ],
                              ),
                            ),
                            child:                             ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: _getCategoryClothingImage(category),
                                    fit: BoxFit.cover,
                                  ),
                                  // Enhanced overlay for better text readability
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 8,
                            right: 8,
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Text(
                'Recently Added',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Text(
                'Popular This Week',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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

  String _getCategoryClothingImage(String category) {
    // Category-specific clothing pile images
    switch (category) {
      case 'Dresses':
        return 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=300&h=300&fit=crop&crop=center';
      case 'Outerwear':
        return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=300&fit=crop&crop=center';
      case 'Bags':
        return 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=300&fit=crop&crop=center';
      case 'Shoes':
        return 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=300&fit=crop&crop=center';
      case 'Accessories':
        return 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=300&h=300&fit=crop&crop=center';
      case 'Tops':
        return 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=300&h=300&fit=crop&crop=center';
      default:
        return 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=300&h=300&fit=crop&crop=center';
    }
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
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search products, brands, categories...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildSearchTags() {
    final suggestedTags = [
      'Streetwear', 'Vintage', 'Y2K', 'Workwear', 'Athletic', 'Denim', 'Fleece', 'Hoodies'
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
        itemCount: suggestedTags.length,
        itemBuilder: (context, index) {
          final tag = suggestedTags[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildSliderBanner() {
    return Consumer2<EnhancedProductProvider, VendorProvider>(
      builder: (context, productProvider, vendorProvider, child) {
        final bannerItems = <Map<String, dynamic>>[];
        
        // Add 3 featured products
        final featuredProducts = productProvider.products.where((p) => p.isFeatured).take(3).toList();
        for (final product in featuredProducts) {
          bannerItems.add({
            'type': 'product',
            'title': product.name,
            'subtitle': 'From ${product.vendor.name}',
            'image': product.images.first,
            'data': product,
          });
        }
        
        // Add 2 featured vendors
        final featuredVendors = vendorProvider.vendors.where((v) => v.isVerified).take(2).toList();
        for (final vendor in featuredVendors) {
          bannerItems.add({
            'type': 'vendor',
            'title': vendor.name,
            'subtitle': '${vendor.categories.join(', ')} Specialist',
            'image': vendor.logo,
            'data': vendor,
          });
        }

        return SizedBox(
          height: 220, // Increased height similar to welcome banner
          child: PageView.builder(
            itemCount: bannerItems.length,
            itemBuilder: (context, index) {
              final item = bannerItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: item['type'] == 'product' 
                              ? item['image'] 
                              : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop&crop=center', // HD clothing pile for vendor banners
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.overlay,
                          color: Colors.black.withOpacity(0.3),
                          placeholder: (context, url) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primary.withOpacity(0.2),
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                    // Content overlay - no text as requested
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

