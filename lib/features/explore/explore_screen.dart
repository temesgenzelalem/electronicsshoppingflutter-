import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/product_provider.dart';
import 'package:electromart_pro/core/providers/category_provider.dart';
import 'package:electromart_pro/core/models/product_model.dart';
import 'package:electromart_pro/core/models/category_model.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  List<String> _selectedBrands = [];
  double? _minRating;
  bool? _inStock;
  String? _sortBy;
  bool _descending = false;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list
          _buildCategoriesList(),

          // Sort options
          _buildSortOptions(),

          // Products list/grid
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(productsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (products) => _buildProductsView(products),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (categories) {
        return Container(
          height: 50,
          margin:
              const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            itemCount: categories.length + 1, // +1 for "All"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                    'All', null, _selectedCategoryId == null);
              }
              final category = categories[index - 1];
              return _buildCategoryChip(
                category.name,
                category.id,
                _selectedCategoryId == category.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String name, String? categoryId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = selected ? categoryId : null;
          });
          _refreshProducts();
        },
      ),
    );
  }

  Widget _buildSortOptions() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Row(
        children: [
          const Text('Sort by:'),
          const SizedBox(width: AppConstants.paddingSmall),
          DropdownButton<String>(
            value: _sortBy,
            hint: const Text('Default'),
            items: const [
              DropdownMenuItem(value: 'price', child: Text('Price')),
              DropdownMenuItem(value: 'rating', child: Text('Rating')),
              DropdownMenuItem(value: 'createdAt', child: Text('Newest')),
            ],
            onChanged: (value) {
              setState(() => _sortBy = value);
              _refreshProducts();
            },
          ),
          if (_sortBy != null)
            IconButton(
              icon:
                  Icon(_descending ? Icons.arrow_downward : Icons.arrow_upward),
              onPressed: () {
                setState(() => _descending = !_descending);
                _refreshProducts();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductsView(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductListItem(product);
        },
      );
    }
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/product-detail', arguments: product.id);
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadiusMedium),
                  ),
                  image: product.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.images.first),
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
                      const Icon(Icons.star, size: 16, color: Colors.amber),
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
    );
  }

  Widget _buildProductListItem(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: product.images.isNotEmpty
            ? Image.network(
                product.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image, size: 60),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.brand),
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
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(product.rating.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/product-detail', arguments: product.id);
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        selectedBrands: _selectedBrands,
        minRating: _minRating,
        inStock: _inStock,
        onApply: (filters) {
          setState(() {
            _minPrice = filters['minPrice'];
            _maxPrice = filters['maxPrice'];
            _selectedBrands = filters['brands'] ?? [];
            _minRating = filters['minRating'];
            _inStock = filters['inStock'];
          });
          _refreshProducts();
        },
      ),
    );
  }

  void _refreshProducts() {
    ref.read(productsProvider.notifier).loadProducts(
          categoryId: _selectedCategoryId,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          brands: _selectedBrands.isNotEmpty ? _selectedBrands : null,
          minRating: _minRating,
          inStock: _inStock,
          sortBy: _sortBy,
          descending: _descending,
          refresh: true,
        );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final List<String> selectedBrands;
  final double? minRating;
  final bool? inStock;
  final Function(Map<String, dynamic>) onApply;

  const _FilterBottomSheet({
    this.minPrice,
    this.maxPrice,
    required this.selectedBrands,
    this.minRating,
    this.inStock,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double? _minPrice;
  late double? _maxPrice;
  late List<String> _selectedBrands;
  late double? _minRating;
  late bool? _inStock;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _selectedBrands = List.from(widget.selectedBrands);
    _minRating = widget.minRating;
    _inStock = widget.inStock;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppConstants.headline2,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _minPrice = null;
                    _maxPrice = null;
                    _selectedBrands.clear();
                    _minRating = null;
                    _inStock = null;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Price Range
          Text('Price Range', style: AppConstants.bodyText1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min Price',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minPrice = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max Price',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxPrice = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Rating
          Text('Minimum Rating', style: AppConstants.bodyText1),
          Slider(
            value: _minRating ?? 0,
            min: 0,
            max: 5,
            divisions: 5,
            label: (_minRating ?? 0).toString(),
            onChanged: (value) {
              setState(() => _minRating = value > 0 ? value : null);
            },
          ),

          // In Stock
          CheckboxListTile(
            title: const Text('In Stock Only'),
            value: _inStock ?? false,
            onChanged: (value) {
              setState(() => _inStock = value);
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({
                  'minPrice': _minPrice,
                  'maxPrice': _maxPrice,
                  'brands': _selectedBrands,
                  'minRating': _minRating,
                  'inStock': _inStock,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
