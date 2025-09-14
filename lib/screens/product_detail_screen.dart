import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/enhanced_product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/share_service.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../services/error_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      // First try to get from provider
      final productProvider = Provider.of<EnhancedProductProvider>(context, listen: false);
      ProductModel? product = productProvider.getProductById(widget.productId);
      
      if (product != null) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        return;
      }

      // If not found in provider, load from backend
      debugPrint('🔄 Loading product ${widget.productId} from backend...');
      final productData = await ProductService.getProductById(widget.productId);
      if (productData != null) {
        product = ProductModel.fromJson(productData!);
      } else {
        throw Exception('Product data is null');
      }
      
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading product: $e');
      setState(() {
        _error = 'Failed to load product: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadProduct();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return const Scaffold(
        body: Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          
          return CustomScrollView(
            slivers: [
              _buildAppBar(_product!),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(_product!),
                    _buildProductInfo(_product!),
                    _buildVendorInfo(_product!),
                    _buildDescription(_product!),
                    _buildProductMetadata(_product!),
                    _buildSpecifications(_product!),
                    _buildReviews(_product!),
                    const SizedBox(height: 24),
                    _buildSimilarProducts(_product!),
                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar(ProductModel product) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, child) {
            final isInWishlist = wishlistProvider.isInWishlist(product.id);
            
            return IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? AppColors.error : AppColors.textPrimary,
              ),
              onPressed: () {
                wishlistProvider.toggleWishlist(product);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWishlist 
                        ? 'Removed from wishlist' 
                        : 'Added to wishlist',
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: isInWishlist 
                      ? AppColors.textSecondary 
                      : AppColors.primary,
                  ),
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _duplicateProduct(product),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => ShareService.shareProduct(product),
        ),
      ],
    );
  }

  void _duplicateProduct(ProductModel product) {
    debugPrint('🔄 Duplicating product: ${product.id}');
    debugPrint('🔄 Product name: ${product.name}');
    debugPrint('🔄 Product specifications: ${product.specifications}');
    
    // Navigate to AddProductScreen with pre-filled data
    Navigator.pushNamed(
      context,
      '/add-product',
      arguments: {
        'isDuplicate': true,
        'originalProduct': product,
      },
    );
  }

  Widget _buildImageCarousel(ProductModel product) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.0, // Square aspect ratio
          child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              aspectRatio: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: product.images.map((imageUrl) {
              return AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (product.images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: product.images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '£${product.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: 12),
                Text(
                  '£${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    '${product.discountPercentage.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (product.rating > 0) ...[
            Row(
              children: [
                RatingBarIndicator(
                  rating: product.rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                product.inStock ? Icons.check_circle : Icons.cancel,
                color: product.inStock ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                product.inStock 
                    ? 'In Stock (${product.stockQuantity} available)'
                    : 'Out of Stock',
                style: TextStyle(
                  color: product.inStock ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (product.views > 0 || product.likes > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (product.views > 0) ...[
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.views} views',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (product.views > 0 && product.likes > 0) ...[
                  const SizedBox(width: 16),
                ],
                if (product.likes > 0) ...[
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.likes} likes',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVendorInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    imageUrl: product.vendor.logo,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(Icons.store, size: 20),
                    errorWidget: (context, url, error) => const Icon(Icons.store, size: 20),
                  ),
                ),
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
                            product.vendor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (product.vendor.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    if (product.vendor.rating > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '⭐ ${product.vendor.rating.toStringAsFixed(1)} (${product.vendor.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/vendor-shop',
                arguments: product.vendor,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.store,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Visit Store',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMetadata(ProductModel product) {
    // Extract all available metadata fields
    final condition = product.specifications['Condition'] ?? '';
    final style = product.specifications['Style'] ?? '';
    final brand = product.specifications['Brand'] ?? '';
    final color = product.specifications['Color'] ?? '';
    final materials = product.specifications['Materials'] ?? '';
    final category = product.category;
    final size = product.subcategory.isNotEmpty ? product.subcategory : '';
    final tags = product.tags.isNotEmpty ? product.tags.join(', ') : '';

    // Only show if we have some metadata
    if (condition.isEmpty && style.isEmpty && brand.isEmpty && color.isEmpty && 
        materials.isEmpty && tags.isEmpty && size.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: AppColors.divider.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                if (category.isNotEmpty) _buildMetadataRow('Category', category),
                if (brand.isNotEmpty) _buildMetadataRow('Brand', brand),
                if (size.isNotEmpty) _buildMetadataRow('Size', size),
                if (condition.isNotEmpty) _buildMetadataRow('Condition', condition),
                if (style.isNotEmpty) _buildMetadataRow('Style', style),
                if (color.isNotEmpty) _buildMetadataRow('Color', color),
                if (materials.isNotEmpty) _buildMetadataRow('Materials', materials),
                if (tags.isNotEmpty) _buildMetadataRow('Tags', tags, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(ProductModel product) {
    // Build comprehensive specifications from all available data
    Map<String, String> allSpecs = {};
    
    // Add specifications from the specifications map
    product.specifications.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        allSpecs[key] = value.toString();
      }
    });
    
    // Add additional product details
    if (product.stockQuantity > 0) {
      allSpecs['Stock Quantity'] = product.stockQuantity.toString();
    }
    
    if (product.rating > 0) {
      allSpecs['Rating'] = '${product.rating.toStringAsFixed(1)}/5.0';
    }
    
    if (product.reviewCount > 0) {
      allSpecs['Reviews'] = '${product.reviewCount} reviews';
    }
    
    if (product.views > 0) {
      allSpecs['Views'] = product.views.toString();
    }
    
    if (product.likes > 0) {
      allSpecs['Likes'] = product.likes.toString();
    }
    
    if (product.isFeatured) {
      allSpecs['Featured'] = 'Yes';
    }
    
    if (product.isActive) {
      allSpecs['Status'] = 'Active';
    }
    
    // Add vendor details
    if (product.vendor.isVerified) {
      allSpecs['Vendor Status'] = 'Verified';
    }
    
    if (product.vendor.rating > 0) {
      allSpecs['Vendor Rating'] = '${product.vendor.rating.toStringAsFixed(1)}/5.0';
    }

    if (allSpecs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              children: allSpecs.entries.map((entry) {
                final isLast = allSpecs.entries.last == entry;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(ProductModel product) {
    // Mock reviews data
    final reviews = _getMockReviews(product);
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (reviews.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Navigate to all reviews
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All reviews feature coming soon!'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rating Summary
          if (product.rating > 0) ...[
            _buildRatingSummary(product),
            const SizedBox(height: 20),
          ],
          
          // Reviews List
          if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Be the first to review this product!',
                    style: TextStyle(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: reviews.take(3).map((review) => _buildReviewCard(review)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              RatingBarIndicator(
                rating: product.rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 16.0,
              ),
              const SizedBox(height: 4),
              Text(
                '${product.reviewCount} reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.6),
                _buildRatingBar(4, 0.3),
                _buildRatingBar(3, 0.1),
                _buildRatingBar(2, 0.0),
                _buildRatingBar(1, 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  review['name'].toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review['rating'].toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 14.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (review['helpful'] > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  '${review['helpful']} people found this helpful',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockReviews(ProductModel product) {
    if (product.reviewCount == 0) return [];
    
    return [
      {
        'name': 'Sarah Johnson',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Excellent quality! The material feels premium and the fit is perfect. Definitely worth the price.',
        'helpful': 12,
      },
      {
        'name': 'Mike Chen',
        'rating': 4,
        'date': '1 week ago',
        'comment': 'Good product overall. Fast shipping and exactly as described. Would recommend to others.',
        'helpful': 8,
      },
      {
        'name': 'Emma Wilson',
        'rating': 5,
        'date': '2 weeks ago',
        'comment': 'Love this! Great value for money and the customer service was fantastic. Will buy again.',
        'helpful': 15,
      },
    ];
  }

  Widget _buildSimilarProducts(ProductModel product) {
    return Consumer<EnhancedProductProvider>(
      builder: (context, productProvider, child) {
        final similarProducts = _getSimilarProducts(product, productProvider);
        
        if (similarProducts.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Similar Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to category or search results
                      Navigator.pushNamed(context, '/search');
                    },
                    child: const Text('View More'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                itemCount: similarProducts.length,
                itemBuilder: (context, index) {
                  final similarProduct = similarProducts[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildSimilarProductCard(similarProduct),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimilarProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.divider.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductDetailScreen(productId: product.id),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.mainImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercentage.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Wishlist button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, child) {
                          final isInWishlist = wishlistProvider.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () => wishlistProvider.toggleWishlist(product),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isInWishlist ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isInWishlist ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.vendor.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (product.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '£${product.finalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            '£${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
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

  List<ProductModel> _getSimilarProducts(ProductModel currentProduct, EnhancedProductProvider productProvider) {
    final allProducts = productProvider.products;
    
    // Filter products by same category, excluding current product
    final similarProducts = allProducts
        .where((product) => 
            product.id != currentProduct.id && 
            product.category == currentProduct.category)
        .take(6)
        .toList();
    
    // If not enough products in same category, add products from same vendor
    if (similarProducts.length < 4) {
      final vendorProducts = allProducts
          .where((product) => 
              product.id != currentProduct.id && 
              product.vendor.id == currentProduct.vendor.id &&
              !similarProducts.contains(product))
          .take(4 - similarProducts.length)
          .toList();
      
      similarProducts.addAll(vendorProducts);
    }
    
    // If still not enough, add random products
    if (similarProducts.length < 4) {
      final randomProducts = allProducts
          .where((product) => 
              product.id != currentProduct.id &&
              !similarProducts.contains(product))
          .take(4 - similarProducts.length)
          .toList();
      
      similarProducts.addAll(randomProducts);
    }
    
    return similarProducts;
  }

  Widget _buildBottomBar() {
    return Consumer2<EnhancedProductProvider, CartProvider>(
      builder: (context, productProvider, cartProvider, child) {
        final product = productProvider.getProductById(widget.productId);
        
        if (product == null) {
          return const SizedBox.shrink();
        }

        final isInCart = cartProvider.isInCart(product.id);
        final quantity = cartProvider.getQuantity(product.id);

        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (isInCart) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cartProvider.decrementQuantity(product.id),
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cartProvider.incrementQuantity(product.id),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: product.inStock
                        ? () {
                            if (isInCart) {
                              // Navigate to cart
                              Navigator.of(context).pushNamed('/cart');
                            } else {
                              cartProvider.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isInCart ? 'Go to Cart' : 'Add to Cart',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
