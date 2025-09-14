import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/share_service.dart';
import '../screens/product_detail_screen.dart';
import '../utils/page_transitions.dart';
import '../widgets/duplicate_product_dialog.dart';
import '../services/duplicate_product_service.dart';
import '../services/error_service.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isCompact;
  final VoidCallback? onTap;
  final bool showDuplicateButton;
  final VoidCallback? onDuplicate;

  const ProductCard({
    super.key,
    required this.product,
    this.isCompact = false,
    this.onTap,
    this.showDuplicateButton = false,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(
          color: AppColors.divider.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            PageTransitions.heroTransition(
              ProductDetailScreen(productId: product.id),
              heroTag: 'product_${product.id}',
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _buildProductImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // PERMANENT OVERFLOW PREVENTION RULE:
                    // Calculate minimum required height and adjust layout accordingly
                    final availableHeight = constraints.maxHeight;
                    final isConstrainedHeight = availableHeight < 120;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name - always visible, constrained to 2 lines max
                        _buildProductName(),
                        SizedBox(height: isConstrainedHeight ? 2 : 4),
                        
                        // Vendor name - always visible, 1 line max
                        _buildVendorName(),
                        SizedBox(height: isConstrainedHeight ? 2 : 4),
                        
                        // Rating - always visible, 1 line max
                        _buildRating(),
                        
                        // Flexible spacer that adapts to available space
                        if (!isConstrainedHeight)
                          Expanded(
                            child: SizedBox(height: 4),
                          )
                        else
                          SizedBox(height: 2),
                        
                        // Price - always visible, 1 line max
                        _buildPriceRow(),
                        SizedBox(height: isConstrainedHeight ? 4 : 6),
                        
                        // Cart button - always visible, fixed height
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isConstrainedHeight = constraints.maxHeight < 120;
                            return _buildAddToCartButton(context, isConstrainedHeight);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
            if (showDuplicateButton)
              Positioned(
                top: 8,
                right: 8,
                child: _buildDuplicateButton(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLarge),
          ),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: CachedNetworkImage(
              imageUrl: product.mainImage,
              fit: BoxFit.cover,
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
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
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
        // Action buttons
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              _buildWishlistButton(),
              const SizedBox(height: 4),
              _buildShareButton(),
            ],
          ),
        ),
        if (!product.inStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: const Center(
                child: Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.2, // Controlled line height for consistent spacing
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  Widget _buildVendorName() {
    return Text(
      product.vendor.name,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.0, // Tight line height for compact display
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  Widget _buildRating() {
    if (product.rating == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        RatingBarIndicator(
          rating: product.rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 12.0,
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount})',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            '£${product.finalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '£${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWishlistButton() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(product.id);
        
        return GestureDetector(
          onTap: () {
            wishlistProvider.toggleWishlist(product);
            
            // Show feedback
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
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isInWishlist ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => ShareService.shareProduct(product),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.share,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, [bool isConstrainedHeight = false]) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(product.id);
        final quantity = cartProvider.getQuantity(product.id);

        if (isInCart) {
          final buttonSize = isConstrainedHeight ? 24.0 : 28.0;
          final iconSize = isConstrainedHeight ? 14.0 : 16.0;
          final fontSize = isConstrainedHeight ? 10.0 : 12.0;
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () => cartProvider.decrementQuantity(product.id),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isConstrainedHeight ? 6 : 8, 
                  vertical: isConstrainedHeight ? 2 : 4
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ),
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () => cartProvider.incrementQuantity(product.id),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
            ],
          );
        }

        final buttonSize = isConstrainedHeight ? 28.0 : 32.0;
        final iconSize = isConstrainedHeight ? 14.0 : 16.0;
        
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: product.inStock
                  ? () => cartProvider.addItem(product)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDuplicateButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _showDuplicateDialog(context),
        icon: const Icon(
          Icons.copy_all,
          color: AppColors.primary,
          size: 20,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DuplicateProductDialog(
        product: product,
        onSuccess: () {
          onDuplicate?.call();
        },
      ),
    );
  }

  Future<void> _quickDuplicate(BuildContext context) async {
    try {
      final result = await DuplicateProductService.quickDuplicate(int.parse(product.id));
      
      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Product duplicated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        onDuplicate?.call();
      } else {
        throw Exception(result?['message'] ?? 'Failed to duplicate product');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppError ? e.userMessage : e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
