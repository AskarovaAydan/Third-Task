import 'package:dio/dio.dart';
import '../models/meal.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final Dio _dio;

  MealApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<List<Meal>> fetchMeals({String query = ''}) async {
    try {
      final response = await _dio.get(
        '/search.php',
        queryParameters: {'s': query},
      );

      final List<dynamic>? mealsJson = response.data['meals'];

      if (mealsJson == null) {
        return [];
      }

      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  Future<Meal> fetchMealDetail(String id) async {
    try {
      final response = await _dio.get(
        '/lookup.php',
        queryParameters: {'i': id},
      );

      final List<dynamic>? mealsJson = response.data['meals'];

      if (mealsJson == null || mealsJson.isEmpty) {
        throw Exception('Yemək tapılmadı');
      }

      return Meal.fromJson(mealsJson.first);
    } on DioException catch (e) {
      throw Exception(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Bağlantı vaxtı bitdi. İnternetinizi yoxlayın.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'İnternet bağlantısı yoxdur.';
    }
    if (e.response != null) {
      return 'Server xətası: ${e.response?.statusCode}';
    }
    return 'Naməlum xəta baş verdi.';
  }
}
