import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/enhanced_product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EnhancedProductProvider>(
        builder: (context, productProvider, child) {
          final product = productProvider.getProductById(widget.productId);
          
          if (product == null) {
            return const Scaffold(
              body: Center(
                child: Text('Product not found'),
              ),
            );
          }
          
          return CustomScrollView(
            slivers: [
              _buildAppBar(product),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(product),
                    _buildProductInfo(product),
                    _buildVendorInfo(product),
                    _buildDescription(product),
                    _buildSpecifications(product),
                    _buildReviews(product),
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
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // Add to wishlist
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share product
          },
        ),
      ],
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
        ],
      ),
    );
  }

  Widget _buildVendorInfo(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: product.vendor.logo,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Icon(Icons.store),
                errorWidget: (context, url, error) => const Icon(Icons.store),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (product.vendor.isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 16,
                      ),
                  ],
                ),
                if (product.vendor.rating > 0)
                  Text(
                    '⭐ ${product.vendor.rating.toStringAsFixed(1)} (${product.vendor.reviewCount} reviews)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to vendor profile
            },
            child: const Text('Visit Store'),
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

  Widget _buildSpecifications(ProductModel product) {
    if (product.specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
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
              children: product.specifications.entries.map((entry) {
                final isLast = product.specifications.entries.last == entry;
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
                              entry.value.toString(),
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
              TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (product.reviewCount == 0)
            const Text(
              'No reviews yet. Be the first to review this product!',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            )
          else
            const Text(
              'Reviews feature coming soon...',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
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
