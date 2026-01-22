import 'package:ecommersflutter_new/providers/cart_provider.dart';
import 'package:ecommersflutter_new/screens/favorite/favorite_screen.dart';
import 'package:ecommersflutter_new/screens/order/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../providers/home_provider.dart';
import './../../widgets/product_card.dart';
import './../../widgets/category_chip.dart';
import '../../screens/profiles/profile_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../repositories/favorite_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoriteScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: provider.loading || provider.business == null
                ? AppBar(elevation: 0, backgroundColor: Colors.white)
                : _buildAppBar(),
            bottomNavigationBar: _buildBottomNav(),
            body: _selectedIndex == 0
                ? _buildHomeBody()
                : _selectedIndex == 1
                ? _buildWishlistPage()
                : _selectedIndex == 2
                ? _buildOrdersPage()
                : const ProfileScreen(),
          );
        },
      ),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: 70,
      title: Consumer<HomeProvider>(
        builder: (context, provider, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.business?.name ?? "",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Phnom Penh, Cambodia',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Search Icon
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ),

        // Cart Icon with Badge
        Consumer<CartProvider>(
          builder: (context, cart, _) => Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: "Wishlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HOME BODY ====================
  Widget _buildHomeBody() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: provider.refreshData,
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildPromoCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Categories', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildCategoryRow(),
              const SizedBox(height: 24),
              _buildSectionHeader('Featured Products', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildFeaturedRow(),
              const SizedBox(height: 24),
              _buildSectionHeader('Recommended', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildRecommendedRow(),
              const SizedBox(height: 24),
              _buildSectionHeader('All Products', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildProductGrid(),
            ],
          ),
        );
      },
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: provider.search,
            decoration: InputDecoration(
              hintText: "Search for products...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: Icon(Icons.tune, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== PROMO CARD ====================
  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 201,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // background circle 1
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // background circle 2
            Positioned(
              right: 40,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 👉 IMAGE ON THE RIGHT
            Positioned(
              right: 20,
              top: 20,
              bottom: -30,
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'images/promo.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // TEXT CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 140, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LIMITED OFFER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Flash Sale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Up to 50% OFF',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onSeeAll,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (trailing != null)
            trailing
          else if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== CATEGORY ROW ====================
  Widget _buildCategoryRow() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final categories = ["All", ...provider.categories.map((c) => c.name)];
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final category = categories[index];
              final isSelected = category == provider.selectedCategory;
              return CategoryChip(
                name: category,
                selected: isSelected,
                onTap: () => provider.selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedRow() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final products = provider.featuredProducts;

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 300,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final p = products[index];

              return SizedBox(
                width: 170,
                child: ProductCard(
                  id: p.id,
                  name: p.name,
                  price: p.price,
                  image: p.image_url ?? '',
                  isFavorite: p.isFavorite ?? false,
                  discount: p.discount != null
                      ? p.discount!.isPercentage
                            ? "${p.discount!.value}% OFF"
                            : "\$${p.discount!.value} OFF"
                      : "",
                  onFavoriteToggle: (_, __) {
                    provider.toggleFavorite(p);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedRow() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final products = provider.recommendedProducts;

        if (products.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 300,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final p = products[index];

              return SizedBox(
                width: 170,
                child: ProductCard(
                  id: p.id,
                  name: p.name,
                  price: p.price,
                  image: p.image_url ?? '',
                  isFavorite: p.isFavorite ?? false,
                  discount: p.discount != null
                      ? p.discount!.isPercentage
                            ? "${p.discount!.value}% OFF"
                            : "\$${p.discount!.value} OFF"
                      : "",
                  onFavoriteToggle: (_, __) => provider.toggleFavorite(p),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== PRODUCT GRID ====================
  Widget _buildProductGrid() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.filteredProducts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final p = provider.filteredProducts[index];
              return ProductCard(
                id: p.id,
                name: p.name,
                isFavorite: p.isFavorite ?? false,
                discount: p.discount != null
                    ? p.discount!.isPercentage
                          ? "${p.discount!.value}% OFF"
                          : "\$${p.discount!.value} OFF"
                    : "No Discount",
                price: p.price,
                image: p.image_url ?? '',
                onFavoriteToggle: (productId, isFav) async {
                  try {
                    final favoriteRepository = FavoriteRepository();
                    if (isFav) {
                      await favoriteRepository.addFavorite(productId);
                    } else {
                      await favoriteRepository.removeFavorite(productId);
                    }
                    // Optionally update the local product list
                    setState(() {
                      p.isFavorite = isFav;
                    });
                  } catch (e) {
                    print("Failed to update favorite: $e");
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  // ==================== PLACEHOLDER PAGES ====================
  Widget _buildWishlistPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
