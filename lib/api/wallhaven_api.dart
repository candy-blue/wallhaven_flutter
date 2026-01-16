import 'package:dio/dio.dart';
import '../models/wallpaper.dart';
import '../models/search_params.dart';
import '../models/collection.dart';

class WallhavenApi {
  static const String baseUrl = 'https://wallhaven.cc/api/v1';
  final Dio _dio;
  String? apiKey; // 改为非final，以便在updateApiKey中更新

  WallhavenApi({this.apiKey}) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    // 不再使用header，改为在查询参数中使用apikey
  }

  void updateApiKey(String? newKey) {
    apiKey = newKey;
    // 不再更新header，改为在查询参数中使用apikey
  }

  Future<WallpaperListResponse> searchWallpapers(SearchParams params) async {
    try {
      // 根据API文档，搜索时如果提供API key，会使用用户的浏览设置和默认过滤器
      final queryParams = Map<String, dynamic>.from(params.toJson());
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      final response = await _dio.get(
        '/search',
        queryParameters: queryParams,
      );
      return WallpaperListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load wallpapers: $e');
    }
  }

  Future<Wallpaper> getWallpaperDetails(String id) async {
    try {
      // NSFW wallpapers需要API key，使用查询参数
      final queryParams = <String, dynamic>{};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      final response = await _dio.get('/w/$id', queryParameters: queryParams);
      return Wallpaper.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load wallpaper details: $e');
    }
  }

  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      // 根据API文档，settings端点也需要API key
      final queryParams = <String, dynamic>{};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      final response = await _dio.get('/settings', queryParameters: queryParams);
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to load user settings: $e');
    }
  }

  Future<List<Collection>> getUserCollections() async {
    try {
      // 根据API文档，获取收藏集列表应该使用查询参数 apikey
      // GET https://wallhaven.cc/api/v1/collections?apikey=****
      final queryParams = <String, dynamic>{};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      final response = await _dio.get('/collections', queryParameters: queryParams);
      return (response.data['data'] as List)
          .map((e) => Collection.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user collections: $e');
    }
  }

  Future<WallpaperListResponse> getCollectionWallpapers(String username, int collectionId, {int page = 1}) async {
    try {
      // 根据API文档：https://wallhaven.cc/help/api
      // 查看收藏夹内容：/collections/USERNAME/ID
      // 如果使用API key认证，可以访问自己的私有收藏夹
      // 对用户名进行URL编码，以支持中文等特殊字符
      final encodedUsername = Uri.encodeComponent(username);
      final queryParams = <String, dynamic>{'page': page};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      final response = await _dio.get(
        '/collections/$encodedUsername/$collectionId',
        queryParameters: queryParams,
      );
      return WallpaperListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load collection wallpapers: $e');
    }
  }
  
  // 尝试通过API key直接获取当前用户的收藏夹内容（如果API支持）
  Future<WallpaperListResponse> getMyCollectionWallpapers(int collectionId, {int page = 1}) async {
    try {
      // 如果API支持，可以尝试使用API key直接访问
      // 但根据文档，这可能需要username，所以这个方法可能不可用
      // 保留此方法以备将来API更新
      final response = await _dio.get(
        '/collections/$collectionId',
        queryParameters: {'page': page},
      );
      return WallpaperListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load collection wallpapers: $e');
    }
  }

  Future<void> addToFavorites(String wallpaperId) async {
    try {
      // 收藏操作需要API key认证
      final queryParams = <String, dynamic>{};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      await _dio.put('/w/$wallpaperId/favorite', queryParameters: queryParams);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String wallpaperId) async {
    try {
      // 取消收藏操作需要API key认证
      final queryParams = <String, dynamic>{};
      if (apiKey != null && apiKey!.isNotEmpty) {
        queryParams['apikey'] = apiKey;
      }
      await _dio.delete('/w/$wallpaperId/favorite', queryParameters: queryParams);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }
}
