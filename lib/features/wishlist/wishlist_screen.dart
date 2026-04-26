import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/wishlist_provider.dart';
import 'package:electromart_pro/core/providers/product_provider.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    final wishlistAsync =
        ref.watch(wishlistProvider('test_user')); // TODO: Get user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Clear wishlist
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(wishlistProvider('test_user'));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (productIds) {
          if (productIds.isEmpty) {
            return _buildEmptyWishlist();
          }
          return _buildWishlistContent(productIds);
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            'Your wishlist is empty',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Save products you like for later',
            style: AppConstants.bodyText2,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/explore'),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent(List<String> productIds) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: productIds.length,
      itemBuilder: (context, index) {
        final productId = productIds[index];
        return _buildWishlistItem(productId);
      },
    );
  }

  Widget _buildWishlistItem(String productId) {
    final productAsync = ref.watch(productProvider(productId));

    return productAsync.when(
      loading: () => const Card(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const Card(
        child: Center(child: Icon(Icons.error)),
      ),
      data: (product) {
        if (product == null) {
          return const Card(
            child: Center(child: Text('Product not found')),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/product-detail', arguments: productId);
                },
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(
                                AppConstants.borderRadiusMedium),
                          ),
                          image: product.images.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      product.images.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: product.images.isEmpty
                            ? const Icon(Icons.image, size: 50)
                            : null,
                      ),
                    ),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppConstants.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand,
                            style: AppConstants.bodyText2,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '\$${product.currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product.isOnSale) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: AppConstants.bodyText2,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${product.stock} left',
                                style: AppConstants.bodyText2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Remove from wishlist button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _showRemoveDialog(product.name, productId),
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    iconSize: 20,
                  ),
                ),
              ),

              // Price drop indicator (if applicable)
              if (product.isOnSale)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
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
            ],
          ),
        );
      },
    );
  }

  void _showRemoveDialog(String productName, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Wishlist'),
        content: Text('Remove "$productName" from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(wishlistProvider('test_user').notifier)
                  .removeFromWishlist(productId);
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
