import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/product_provider.dart';
import 'package:electromart_pro/core/providers/analytics_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView('Search');
    });
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // TODO: Load recent searches from local storage
    setState(() {
      _recentSearches = ['iPhone', 'Samsung', 'Laptop', 'Headphones'];
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    // Log search event
    ref.read(analyticsServiceProvider).logSearch(query);

    // TODO: Implement search functionality
    // For now, just filter products
    ref.read(productsProvider.notifier).loadProducts(
          searchQuery: query,
          refresh: true,
        );

    setState(() => _isSearching = false);
    _addToRecentSearches(query);
  }

  Future<void> _addToRecentSearches(String query) async {
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > AppConstants.maxRecentSearches) {
          _recentSearches =
              _recentSearches.sublist(0, AppConstants.maxRecentSearches);
        }
      });
      // TODO: Save to local storage
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // TODO: Implement voice search
            },
          ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? _buildSearchSuggestions()
          : _buildSearchResults(productsAsync),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: AppConstants.headline2,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Wrap(
              spacing: 8,
              children: _recentSearches
                  .map((search) => ActionChip(
                        label: Text(search),
                        onPressed: () {
                          _searchController.text = search;
                          _performSearch(search);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Popular Categories
          const Text(
            'Popular Categories',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppConstants.paddingMedium,
            crossAxisSpacing: AppConstants.paddingMedium,
            children: [
              _buildCategoryCard('Smartphones', Icons.phone_android),
              _buildCategoryCard('Laptops', Icons.laptop),
              _buildCategoryCard('Headphones', Icons.headphones),
              _buildCategoryCard('Tablets', Icons.tablet),
              _buildCategoryCard('Smartwatches', Icons.watch),
              _buildCategoryCard('Cameras', Icons.camera),
            ],
          ),

          // Trending Products
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'Trending Products',
            style: AppConstants.headline2,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // TODO: Add trending products
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          _searchController.text = title;
          _performSearch(title);
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppConstants.primaryColor),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                title,
                style: AppConstants.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> productsAsync) {
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: AppConstants.paddingLarge),
                Text(
                  'No products found',
                  style: AppConstants.headline2,
                ),
                SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Try different keywords or check spelling',
                  style: AppConstants.bodyText2,
                ),
              ],
            ),
          );
        }

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
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/product-detail', arguments: product.id);
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
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
