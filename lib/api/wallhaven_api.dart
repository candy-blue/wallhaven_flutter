import 'package:dio/dio.dart';
import '../models/wallpaper.dart';
import '../models/search_params.dart';
import '../models/collection.dart';

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

  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await _dio.get('/settings');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load user settings: $e');
    }
  }

  Future<List<Collection>> getUserCollections() async {
    try {
      final response = await _dio.get('/collections');
      return (response.data['data'] as List)
          .map((e) => Collection.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user collections: $e');
    }
  }

  Future<WallpaperListResponse> getCollectionWallpapers(String username, int collectionId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/collections/$username/$collectionId',
        queryParameters: {'page': page},
      );
      return WallpaperListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load collection wallpapers: $e');
    }
  }

  Future<void> addToFavorites(String wallpaperId, {int collectionId = 1}) async {
    try {
      await _dio.post(
        '/collections/favorites',
        data: {'wallpaper_id': wallpaperId, 'collection_id': collectionId},
      );
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String wallpaperId, {int collectionId = 1}) async {
    try {
      await _dio.post( 
        '/collections/favorites', 
        data: {'wallpaper_id': wallpaperId, 'collection_id': collectionId},
        options: Options(method: 'DELETE'), 
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
}
