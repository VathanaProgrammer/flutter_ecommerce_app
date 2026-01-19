import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository = HomeRepository();

  List<Category> categories = [];
  List<Product> allProducts = []; // full list
  List<Product> filteredProducts = []; // filtered by category/search
  Business? business;

  String selectedCategory = "All";
  String searchQuery = "";
  bool loading = true;

  HomeProvider() {
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

      applyFilters(); // apply default filter (All + empty search)
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
          searchQuery.isEmpty || p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }

  /// CATEGORY SELECT
  void selectCategory(String category) {
    selectedCategory = category;
    applyFilters();
  }

  /// SEARCH
  void search(String query) {
    searchQuery = query;
    applyFilters();
  }

  /// REFRESH (pull-to-refresh)
  Future<void> refreshData() async {
    await init();
  }
}
