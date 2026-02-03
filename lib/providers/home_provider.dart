import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;

  List<Category> categories = [];
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<Product> featuredProducts = [];
  List<Product> recommendedProducts = [];

  Business? business;

  String selectedCategory = "All";
  String searchQuery = "";
  bool loading = true;

  HomeProvider({HomeRepository? repo}) : repository = repo ?? HomeRepository() {
    init();
  }

  Future<void> init() async {
    loading = true;
    notifyListeners();

    try {
      final data = await repository.fetchHome();

      categories = (data['categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList();

      allProducts = (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();

      business = Business.fromJson(data['business']);

      applyFilters();
    } catch (e) {
      debugPrint("Fetch home data error: $e");
    }

    loading = false;
    notifyListeners();
  }

  void applyFilters() {
    filteredProducts = allProducts.where((p) {
      final matchesCategory =
          selectedCategory == "All" || p.category == selectedCategory;
      final matchesSearch =
          searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    featuredProducts = allProducts.where((p) => p.isFeatured == true).toList();
    recommendedProducts = allProducts
        .where((p) => p.isRecommended == true)
        .toList();

    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    applyFilters();
  }

  void search(String query) {
    searchQuery = query;
    applyFilters();
  }

  Future<void> refreshData() async {
    await init();
  }

  void toggleFavorite(Product product) {
    product.isFavorite = !(product.isFavorite ?? false);
    notifyListeners();

    if (product.isFavorite == true) {
      repository.favoriteRepository.addFavorite(product.id);
    } else {
      repository.favoriteRepository.removeFavorite(product.id);
    }
  }
}
