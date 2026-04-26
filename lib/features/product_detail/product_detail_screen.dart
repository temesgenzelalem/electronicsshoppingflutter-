import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/product_provider.dart';
import 'package:electromart_pro/core/providers/cart_provider.dart';
import 'package:electromart_pro/core/providers/wishlist_provider.dart';
import 'package:electromart_pro/core/providers/analytics_provider.dart';
import 'package:electromart_pro/core/models/product_model.dart';
import 'package:electromart_pro/core/models/cart_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  final Map<String, String> _selectedVariants = {};
  int _quantity = 1;
  bool _productViewLogged = false;

  @override
  void initState() {
    super.initState();
    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView('Product Detail');
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final wishlistAsync =
                  ref.watch(wishlistProvider('test_user')); // TODO: Get user ID
              return wishlistAsync.when(
                loading: () => const Icon(Icons.favorite_border),
                error: (error, stack) => const Icon(Icons.favorite_border),
                data: (wishlist) {
                  final isInWishlist = wishlist.contains(widget.productId);
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        ref
                            .read(wishlistProvider('test_user').notifier)
                            .removeFromWishlist(widget.productId);
                      } else {
                        ref
                            .read(wishlistProvider('test_user').notifier)
                            .addToWishlist(widget.productId);
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(productProvider(widget.productId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          // Log product view
          if (!_productViewLogged) {
            _productViewLogged = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(analyticsServiceProvider).logProductView(
                    product.id,
                    product.name,
                    product.categoryId,
                  );
            });
          }
          return _buildProductDetail(product);
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) {
          if (product == null) return null;
          return _buildBottomBar(product);
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildProductDetail(ProductModel product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          _buildImageCarousel(product),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Text(
                  product.name,
                  style: AppConstants.headline1,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    Text(
                      '\$${product.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    if (product.isOnSale) ...[
                      const SizedBox(width: AppConstants.paddingMedium),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
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

                // Rating and Stock
                const SizedBox(height: AppConstants.paddingMedium),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: AppConstants.bodyText1,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      '(${product.stock} in stock)',
                      style: AppConstants.bodyText2,
                    ),
                  ],
                ),

                // Brand
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Brand: ${product.brand}',
                  style: AppConstants.bodyText1,
                ),

                // Variants
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  const Text(
                    'Variants',
                    style: AppConstants.headline2,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildVariantsSelector(product),
                ],

                // Quantity Selector
                const SizedBox(height: AppConstants.paddingLarge),
                const Text(
                  'Quantity',
                  style: AppConstants.headline2,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildQuantitySelector(product),

                // Description
                const SizedBox(height: AppConstants.paddingLarge),
                const Text(
                  'Description',
                  style: AppConstants.headline2,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  product.description,
                  style: AppConstants.bodyText1,
                ),

                // Specifications
                if (product.specifications.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  const Text(
                    'Specifications',
                    style: AppConstants.headline2,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildSpecifications(product),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(ProductModel product) {
    if (product.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 100),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() => _selectedImageIndex = index);
            },
          ),
          items: product.images.map((imageUrl) {
            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            );
          }).toList(),
        ),

        // Image indicators
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: product.images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedImageIndex == entry.key
                      ? AppConstants.primaryColor
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSelector(ProductModel product) {
    // Group variants by name
    final variantGroups = <String, List<ProductVariant>>{};
    for (final variant in product.variants) {
      variantGroups.putIfAbsent(variant.name, () => []).add(variant);
    }

    return Column(
      children: variantGroups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style:
                  AppConstants.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              children: entry.value.map((variant) {
                final isSelected =
                    _selectedVariants[entry.key] == variant.value;
                return ChoiceChip(
                  label: Text(variant.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVariants[entry.key] = variant.value;
                      } else {
                        _selectedVariants.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(ProductModel product) {
    return Row(
      children: [
        IconButton(
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          icon: const Icon(Icons.remove),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _quantity.toString(),
            style: AppConstants.bodyText1,
          ),
        ),
        IconButton(
          onPressed: _quantity < product.stock
              ? () => setState(() => _quantity++)
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildSpecifications(ProductModel product) {
    return Column(
      children: product.specifications.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${entry.key}:',
                  style: AppConstants.bodyText1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  entry.value.toString(),
                  style: AppConstants.bodyText1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Add to cart
                final cartItem = CartItemModel(
                  productId: product.id,
                  productName: product.name,
                  productImage:
                      product.images.isNotEmpty ? product.images.first : '',
                  price: product.price,
                  discountPrice: product.discountPrice,
                  quantity: _quantity,
                  selectedVariants: _selectedVariants,
                  addedAt: DateTime.now(),
                );
                ref
                    .read(cartProvider('test_user').notifier)
                    .addToCart(cartItem);
                // Log add to cart event
                ref.read(analyticsServiceProvider).logAddToCart(
                      product.id,
                      product.name,
                      product.currentPrice,
                      'USD', // Assuming USD, TODO: Get from user settings
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Buy now - navigate to checkout
              },
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}
