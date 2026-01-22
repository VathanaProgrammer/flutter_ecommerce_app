import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api.dart';
import '../../repositories/favorite_repository.dart';
import '../../screens/products/product_detail_screen.dart';
import '../../widgets/product_card.dart';
import 'package:flutter/cupertino.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool loading = true;
  bool loggedIn = false;
  List<Product> favorites = [];
  late FavoriteRepository favoriteRepo;

  @override
  void initState() {
    super.initState();
    favoriteRepo = FavoriteRepository();
    _checkLoginAndLoad();
  }

  Future<void> _checkLoginAndLoad() async {
    final user = await Api.getCurrentUser();
    if (user == null) {
      setState(() {
        loggedIn = false;
        loading = false;
      });
      return;
    }

    setState(() => loggedIn = true);

    try {
      final favoriteIds = await favoriteRepo.fetchFavorites();
      final data = await Api.getHomeData();
      final allProducts = (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();

      setState(() {
        favorites = allProducts
            .where((p) => favoriteIds.contains(p.id))
            .toList();
        loading = false;
      });
    } catch (e) {
      print('Failed to fetch favorites: $e');
      setState(() => loading = false);
    }
  }

  void _toggleFavorite(Product product) async {
    setState(() {
      product.isFavorite = !(product.isFavorite ?? false);
      if (!product.isFavorite!)
        favorites.removeWhere((p) => p.id == product.id);
    });

    try {
      if (product.isFavorite == true) {
        await favoriteRepo.addFavorite(product.id);
      } else {
        await favoriteRepo.removeFavorite(product.id);
      }
    } catch (e) {
      print('Failed to update favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!loggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are not logged in.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorite products yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final p = favorites[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: p.id),
              ),
            );
          },
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
              _toggleFavorite(p);
            },
          ),
        );
      },
    );
  }
}
