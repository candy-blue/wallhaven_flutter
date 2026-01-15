import 'package:flutter/foundation.dart';
import '../api/wallhaven_api.dart';
import '../models/search_params.dart';
import '../models/wallpaper.dart';
import '../models/collection.dart';

enum WallpaperSource { search, collection }

class WallpaperProvider with ChangeNotifier {
  final WallhavenApi _api = WallhavenApi();
  
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  SearchParams _params = SearchParams();
  
  // User info
  String? _username;
  List<Collection> _collections = [];
  bool _isLoggedIn = false;

  // Collection browsing state
  WallpaperSource _source = WallpaperSource.search;
  int? _currentCollectionId;
  String? _currentCollectionUsername;

  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  SearchParams get params => _params;
  String? get username => _username;
  List<Collection> get collections => _collections;
  bool get isLoggedIn => _isLoggedIn;

  WallhavenApi get api => _api;

  Future<void> updateApiKey(String apiKey) async {
    _api.updateApiKey(apiKey);
    await _verifyLogin();
    fetchWallpapers(refresh: true);
  }

  Future<void> syncApiKey(String apiKey) async {
     _api.updateApiKey(apiKey);
     await _verifyLogin();
     // Do not fetch wallpapers here, let the UI decide when to fetch
  }

  Future<void> _verifyLogin() async {
    try {
      final settings = await _api.getUserSettings();
      _username = settings['username'];
      _isLoggedIn = true;
      await _fetchUserCollections();
    } catch (e) {
      _isLoggedIn = false;
      _username = null;
      _collections = [];
      // If login fails, we MUST clear the API key to prevent subsequent requests from failing with 401
      _api.updateApiKey(null);
      if (kDebugMode) print('Login verification failed: $e');
      rethrow; // Rethrow so the UI knows it failed
    }
    notifyListeners();
  }

  Future<void> _fetchUserCollections() async {
    if (!_isLoggedIn) return;
    try {
      _collections = await _api.getUserCollections();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error fetching collections: $e');
    }
  }

  Future<void> switchToSearch() async {
    _source = WallpaperSource.search;
    await fetchWallpapers(refresh: true);
  }

  Future<void> switchToCollection(int collectionId, String username) async {
    _source = WallpaperSource.collection;
    _currentCollectionId = collectionId;
    _currentCollectionUsername = username;
    await fetchWallpapers(refresh: true);
  }

  Future<void> fetchWallpapers({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _params.page = 1;
      _wallpapers.clear();
      _hasMore = true;
    } else {
      _params.page++;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      WallpaperListResponse response;
      if (_source == WallpaperSource.search) {
        response = await _api.searchWallpapers(_params);
      } else {
        if (_currentCollectionUsername == null || _currentCollectionId == null) {
          throw Exception("Collection info missing");
        }
        response = await _api.getCollectionWallpapers(
          _currentCollectionUsername!,
          _currentCollectionId!,
          page: _params.page,
        );
      }
      
      if (refresh) {
        _wallpapers = response.data;
      } else {
        _wallpapers.addAll(response.data);
      }

      // Check if we reached the last page
      if (response.meta.currentPage >= response.meta.lastPage) {
        _hasMore = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wallpapers: $e');
      }
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Wallpaper> getWallpaperDetails(String id) async {
    return await _api.getWallpaperDetails(id);
  }

  void updateSearchParams(SearchParams newParams) {
    _params = newParams;
    // Changing filters implies switching back to search mode usually,
    // unless we want to filter within collection (which Wallhaven API might not support fully or differently).
    // For now, assume filters apply to search.
    if (_source == WallpaperSource.collection) {
        // If user changes filters, do we switch to search?
        // Or do we just apply params? Collection endpoint doesn't support all search params usually.
        // Let's switch to search if filters are complex.
        // But simply, let's keep it in search mode.
        _source = WallpaperSource.search;
    }
    fetchWallpapers(refresh: true);
  }
  
  void setSearchQuery(String query) {
    _params.q = query;
    _source = WallpaperSource.search;
    fetchWallpapers(refresh: true);
  }

  void setCategory({bool? general, bool? anime, bool? people}) {
    String current = _params.categories;
    String newGeneral = general != null ? (general ? '1' : '0') : current[0];
    String newAnime = anime != null ? (anime ? '1' : '0') : current[1];
    String newPeople = people != null ? (people ? '1' : '0') : current[2];
    
    _params.categories = '$newGeneral$newAnime$newPeople';
    _source = WallpaperSource.search;
    fetchWallpapers(refresh: true);
  }
  
  void setPurity({bool? sfw, bool? sketchy, bool? nsfw}) {
    String current = _params.purity;
    String newSfw = sfw != null ? (sfw ? '1' : '0') : current[0];
    String newSketchy = sketchy != null ? (sketchy ? '1' : '0') : current[1];
    String newNsfw = nsfw != null ? (nsfw ? '1' : '0') : (current.length > 2 ? current[2] : '0');
    
    _params.purity = '$newSfw$newSketchy$newNsfw';
    _source = WallpaperSource.search;
    fetchWallpapers(refresh: true);
  }

  Future<void> toggleFavorite(String wallpaperId, bool isCurrentlyFavorited) async {
    if (!_isLoggedIn) {
      throw Exception('Please login first');
    }
    try {
      if (isCurrentlyFavorited) {
        await _api.removeFromFavorites(wallpaperId);
      } else {
        await _api.addToFavorites(wallpaperId);
      }
      // Update local state
      final index = _wallpapers.indexWhere((w) => w.id == wallpaperId);
      if (index != -1) {
        final wallpaper = _wallpapers[index];
        final updatedWallpaper = Wallpaper(
          id: wallpaper.id,
          url: wallpaper.url,
          shortUrl: wallpaper.shortUrl,
          views: wallpaper.views,
          favorites: isCurrentlyFavorited ? wallpaper.favorites - 1 : wallpaper.favorites + 1,
          source: wallpaper.source,
          purity: wallpaper.purity,
          category: wallpaper.category,
          dimensionX: wallpaper.dimensionX,
          dimensionY: wallpaper.dimensionY,
          resolution: wallpaper.resolution,
          ratio: wallpaper.ratio,
          fileSize: wallpaper.fileSize,
          fileType: wallpaper.fileType,
          createdAt: wallpaper.createdAt,
          colors: wallpaper.colors,
          path: wallpaper.path,
          thumbs: wallpaper.thumbs,
          uploader: wallpaper.uploader,
          tags: wallpaper.tags,
          isFavorited: !isCurrentlyFavorited,
        );
        _wallpapers[index] = updatedWallpaper;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error toggling favorite: $e');
      rethrow;
    }
  }
}
