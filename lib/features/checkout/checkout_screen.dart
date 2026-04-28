import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/cart_provider.dart';
import 'package:electromart_pro/core/providers/analytics_provider.dart';
import 'package:electromart_pro/core/models/cart_model.dart';
import 'package:electromart_pro/core/models/address_model.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  AddressModel? _selectedAddress;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Credit/Debit Card',
    'UPI',
    'Net Banking',
    'Cash on Delivery',
  ];

  @override
  void initState() {
    super.initState();
    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView('Checkout');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider('test_user')); // TODO: Get user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }
          return _buildCheckoutContent(cartItems);
        },
      ),
    );
  }

  Widget _buildCheckoutContent(List<CartItemModel> cartItems) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      onStepTapped: (step) => setState(() => _currentStep = step),
      steps: [
        Step(
          title: const Text('Delivery Address'),
          content: _buildAddressStep(),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Payment Method'),
          content: _buildPaymentStep(),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Order Summary'),
          content: _buildSummaryStep(cartItems),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    // TODO: Load user addresses from Firestore
    final addresses = <AddressModel>[]; // Placeholder

    return Column(
      children: [
        if (addresses.isEmpty) ...[
          const Text('No addresses found. Add a new address.'),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: _addNewAddress,
            child: const Text('Add New Address'),
          ),
        ] else ...[
          ...addresses.map((address) => RadioListTile<AddressModel>(
                title: Text(address.name),
                subtitle: Text('${address.addressLine1}, ${address.city}'),
                value: address,
                groupValue: _selectedAddress,
                onChanged: (value) => setState(() => _selectedAddress = value),
              )),
          const SizedBox(height: AppConstants.paddingMedium),
          OutlinedButton(
            onPressed: _addNewAddress,
            child: const Text('Add New Address'),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children: _paymentMethods
          .map((method) => RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) =>
                    setState(() => _selectedPaymentMethod = value),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryStep(List<CartItemModel> cartItems) {
    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final deliveryCharge = subtotal >= AppConstants.freeDeliveryThreshold
        ? 0.0
        : AppConstants.deliveryCharge;
    final tax = subtotal * AppConstants.taxRate;
    final total = subtotal + deliveryCharge + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Address
        if (_selectedAddress != null) ...[
          const Text(
            'Delivery Address',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(_selectedAddress!.name),
          Text(_selectedAddress!.addressLine1),
          if (_selectedAddress!.addressLine2 != null)
            Text(_selectedAddress!.addressLine2!),
          Text(
              '${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.postalCode}'),
          const SizedBox(height: AppConstants.paddingMedium),
        ],

        // Payment Method
        if (_selectedPaymentMethod != null) ...[
          const Text(
            'Payment Method',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(_selectedPaymentMethod!),
          const SizedBox(height: AppConstants.paddingMedium),
        ],

        // Order Items
        const Text(
          'Order Items',
          style: AppConstants.headline2,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        ...cartItems.map((item) => ListTile(
              title: Text(item.productName),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text(
                  '\$${(item.currentPrice * item.quantity).toStringAsFixed(2)}'),
            )),

        const Divider(),

        // Price Breakdown
        _buildPriceRow('Subtotal', subtotal),
        _buildPriceRow('Delivery', deliveryCharge),
        _buildPriceRow('Tax', tax),
        const Divider(),
        _buildPriceRow('Total', total, isTotal: true),

        const SizedBox(height: AppConstants.paddingLarge),

        // Place Order Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _placeOrder(cartItems, total),
            child: _isProcessing
                ? const CircularProgressIndicator()
                : const Text('Place Order'),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppConstants.headline2 : AppConstants.bodyText1,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppConstants.headline2
                    .copyWith(color: AppConstants.primaryColor)
                : AppConstants.bodyText1,
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _addNewAddress() {
    // TODO: Navigate to add address screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add new address functionality coming soon')),
    );
  }

  Future<void> _placeOrder(List<CartItemModel> cartItems, double total) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // TODO: Create order in Firestore
      // TODO: Process payment
      // TODO: Clear cart
      // TODO: Navigate to order success screen

      // Log purchase event
      final items = cartItems.map((item) {
        return AnalyticsEventItem(
          itemId: item.productId,
          itemName: item.productName,
          price: item.price,
          quantity: item.quantity,
        );
      }).toList();
      final transactionId = DateTime.now().millisecondsSinceEpoch.toString(); // TODO: Use actual order ID
      await ref.read(analyticsServiceProvider).logPurchase(
            transactionId,
            total,
            'USD', // TODO: Get currency from settings
            items,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
