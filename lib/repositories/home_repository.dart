import '../services/api.dart';
import 'favorite_repository.dart';

class HomeRepository {
  final FavoriteRepository favoriteRepository;

  HomeRepository({FavoriteRepository? favoriteRepo})
      : favoriteRepository = favoriteRepo ?? FavoriteRepository();

  Future<Map<String, dynamic>> fetchHome({String? category, String? search}) async {
    final data = await Api.getHomeData(category: category, search: search);

    // fetch user favorites
    final favoriteIds = await favoriteRepository.fetchFavorites();

    data['products'] = (data['products'] as List).map((e) {
      final product = e as Map<String, dynamic>;
      product['is_favorite'] = favoriteIds.contains(product['id']);
      return product;
    }).toList();

    return data;
  }
}
