import '../services/api.dart';

class HomeRepository {
  Future<Map<String, dynamic>> fetchHome({String? category, String? search}) async {
    final data = await Api.getHomeData(category: category, search: search);
    return data;
  }
}
