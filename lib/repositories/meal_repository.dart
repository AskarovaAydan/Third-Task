import '../models/meal.dart';
import '../services/meal_api_service.dart';

class MealRepository {
  final MealApiService _apiService;

  MealRepository({MealApiService? apiService})
    : _apiService = apiService ?? MealApiService();

  Future<List<Meal>> getMeals({String query = ''}) {
    return _apiService.fetchMeals(query: query);
  }

  Future<Meal> getMealDetail(String id) {
    return _apiService.fetchMealDetail(id);
  }
}
