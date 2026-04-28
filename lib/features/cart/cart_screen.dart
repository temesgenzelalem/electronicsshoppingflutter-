import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/cart_provider.dart';
import 'package:electromart_pro/core/providers/analytics_provider.dart';
import 'package:electromart_pro/core/models/cart_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView('Cart');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider('test_user')); // TODO: Get user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Clear cart
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(cartProvider('test_user'));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartContent(cartItems);
        },
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (cartItems) {
          if (cartItems.isEmpty) return null;
          return _buildBottomBar(cartItems);
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'Your cart is empty',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          const Text(
            'Add some products to get started',
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

  Widget _buildCartContent(List<CartItemModel> cartItems) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                image: item.productImage.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(item.productImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.productImage.isEmpty
                  ? const Icon(Icons.image, size: 40)
                  : null,
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: AppConstants.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Variants
                  if (item.selectedVariants.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.selectedVariants.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: AppConstants.bodyText2,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${item.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.isOnSale) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '\$${(item.currentPrice * item.quantity).toStringAsFixed(2)}',
                        style: AppConstants.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Quantity Controls
                  Row(
                    children: [
                      IconButton(
                        onPressed: item.quantity > 1
                            ? () => ref
                                .read(cartProvider('test_user').notifier)
                                .updateQuantity(
                                    item.productId, item.quantity - 1)
                            : null,
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.quantity.toString(),
                          style: AppConstants.bodyText1,
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(cartProvider('test_user').notifier)
                            .updateQuantity(item.productId, item.quantity + 1),
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showRemoveDialog(item),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<CartItemModel> cartItems) {
    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final totalItems = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($totalItems items)',
                style: AppConstants.bodyText1,
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppConstants.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Delivery
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery',
                style: AppConstants.bodyText1,
              ),
              Text(
                subtotal >= AppConstants.freeDeliveryThreshold
                    ? 'Free'
                    : '\$${AppConstants.deliveryCharge.toStringAsFixed(2)}',
                style: AppConstants.bodyText1,
              ),
            ],
          ),

          // Tax
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tax',
                style: AppConstants.bodyText1,
              ),
              Text(
                '\$${(subtotal * AppConstants.taxRate).toStringAsFixed(2)}',
                style: AppConstants.bodyText1,
              ),
            ],
          ),

          const Divider(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: AppConstants.headline2,
              ),
              Text(
                '\$${_calculateTotal(cartItems).toStringAsFixed(2)}',
                style: AppConstants.headline2.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/checkout'),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<CartItemModel> cartItems) {
    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    double total = subtotal;
    if (subtotal < AppConstants.freeDeliveryThreshold) {
      total += AppConstants.deliveryCharge;
    }
    total += subtotal * AppConstants.taxRate;
    return total;
  }

  void _showRemoveDialog(CartItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.productName} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(cartProvider('test_user').notifier)
                  .removeFromCart(item.productId);
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
