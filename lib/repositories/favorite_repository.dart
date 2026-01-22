import '../services/favorite_service.dart';

class FavoriteRepository {
  final FavoriteService service;

  FavoriteRepository({FavoriteService? service})
      : service = service ?? FavoriteService();

  Future<List<int>> fetchFavorites() => service.getFavorites();

  Future<void> addFavorite(int productId) => service.addFavorite(productId);

  Future<void> removeFavorite(int productId) => service.removeFavorite(productId);
}
