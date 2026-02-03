import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/search_service.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  // Filters
  int? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  int? _minRating;
  String _sortBy = 'created_at';
  bool _inStock = false;

  Map<String, dynamic> _filters = {};
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _searchProducts();
  }

  Future<void> _loadFilters() async {
    final filters = await SearchService.getFilters();
    setState(() {
      _filters = filters;
    });
  }

  Future<void> _searchProducts() async {
    setState(() {
      _isLoading = true;
    });

    final result = await SearchService.searchProducts(
      query: _searchController.text.isNotEmpty ? _searchController.text : null,
      categoryId: _selectedCategoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
      inStock: _inStock,
      sortBy: _sortBy,
      page: _currentPage,
    );

    setState(() {
      _products = result['products'] as List<Product>;
      _totalPages = result['last_page'] as int;
      _isLoading = false;
    });
  }

  Future<void> _loadSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final suggestions = await SearchService.getSearchSuggestions(query);
    setState(() {
      _suggestions = suggestions;
      _showSuggestions = true;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            _buildFilterContent(scrollController),
      ),
    );
  }

  Widget _buildFilterContent(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      _selectedCategoryId = null;
                      _minPrice = null;
                      _maxPrice = null;
                      _minRating = null;
                      _inStock = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Filter
            if (_filters['categories'] != null) ...[
              const Text(
                'Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: (_filters['categories'] as List).map((category) {
                  final isSelected = _selectedCategoryId == category['id'];
                  return FilterChip(
                    label: Text(category['name']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedCategoryId = selected ? category['id'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Price Range
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setModalState(() {
                        _minPrice = double.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setModalState(() {
                        _maxPrice = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rating Filter
            const Text(
              'Minimum Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((rating) {
                final isSelected = _minRating == rating;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$rating'),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setModalState(() {
                      _minRating = selected ? rating : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // In Stock Filter
            SwitchListTile(
              title: const Text('In Stock Only'),
              value: _inStock,
              onChanged: (value) {
                setModalState(() {
                  _inStock = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Apply Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentPage = 1;
                });
                _searchProducts();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _showSuggestions = false;
                      });
                      _searchProducts();
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            _loadSuggestions(value);
          },
          onSubmitted: (value) {
            setState(() {
              _showSuggestions = false;
              _currentPage = 1;
            });
            _searchProducts();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _currentPage = 1;
              });
              _searchProducts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'created_at', child: Text('Newest')),
              const PopupMenuItem(
                value: 'price_low',
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Text('Highest Rated'),
              ),
              const PopupMenuItem(
                value: 'popular',
                child: Text('Most Popular'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_isLoading) const LinearProgressIndicator(),

              Expanded(
                child: _products.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCard(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            image: product.image_url ?? '',
                            isFavorite: product.isFavorite ?? false,
                            discount: product.discount != null
                                ? product.discount!.isPercentage
                                      ? "${product.discount!.value}% OFF"
                                      : "\$${product.discount!.value} OFF"
                                : "No Discount",
                          );
                        },
                      ),
              ),

              // Pagination
              if (_totalPages > 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _searchProducts();
                              }
                            : null,
                      ),
                      Text('Page $_currentPage of $_totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _searchProducts();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Suggestions Overlay
          if (_showSuggestions && _suggestions.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final product = _suggestions[index];
                    return ListTile(
                      leading: product.image_url != null
                          ? Image.network(
                              product.image_url!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image),
                      title: Text(product.name),
                      subtitle: Text(
                        '\$${product.finalPrice.toStringAsFixed(2)}',
                      ),
                      onTap: () {
                        _searchController.text = product.name;
                        setState(() {
                          _showSuggestions = false;
                        });
                        _searchProducts();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
