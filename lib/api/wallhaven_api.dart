import 'package:dio/dio.dart';
import '../models/wallpaper.dart';
import '../models/search_params.dart';

class WallhavenApi {
  static const String baseUrl = 'https://wallhaven.cc/api/v1';
  final Dio _dio;
  final String? apiKey;

  WallhavenApi({this.apiKey}) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    if (apiKey != null && apiKey!.isNotEmpty) {
      _dio.options.headers['X-API-Key'] = apiKey;
    }
  }

  void updateApiKey(String? newKey) {
    if (newKey != null && newKey.isNotEmpty) {
      _dio.options.headers['X-API-Key'] = newKey;
    } else {
      _dio.options.headers.remove('X-API-Key');
    }
  }

  Future<WallpaperListResponse> searchWallpapers(SearchParams params) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: params.toJson(),
      );
      return WallpaperListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load wallpapers: $e');
    }
  }

  Future<Wallpaper> getWallpaperDetails(String id) async {
    try {
      final response = await _dio.get('/w/$id');
      return Wallpaper.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load wallpaper details: $e');
    }
  }
}
