import 'package:flutter/foundation.dart';
import '../api/wallhaven_api.dart';
import '../models/search_params.dart';
import '../models/wallpaper.dart';

class WallpaperProvider with ChangeNotifier {
  final WallhavenApi _api = WallhavenApi();
  
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  SearchParams _params = SearchParams();
  
  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  SearchParams get params => _params;

  void updateApiKey(String apiKey) {
    _api.updateApiKey(apiKey);
    fetchWallpapers(refresh: true);
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
      final response = await _api.searchWallpapers(_params);
      
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchParams(SearchParams newParams) {
    _params = newParams;
    fetchWallpapers(refresh: true);
  }
  
  void setSearchQuery(String query) {
    _params.q = query;
    fetchWallpapers(refresh: true);
  }

  void setCategory({bool? general, bool? anime, bool? people}) {
    String current = _params.categories;
    String newGeneral = general != null ? (general ? '1' : '0') : current[0];
    String newAnime = anime != null ? (anime ? '1' : '0') : current[1];
    String newPeople = people != null ? (people ? '1' : '0') : current[2];
    
    _params.categories = '$newGeneral$newAnime$newPeople';
    fetchWallpapers(refresh: true);
  }
  
  void setPurity({bool? sfw, bool? sketchy, bool? nsfw}) {
    String current = _params.purity;
    String newSfw = sfw != null ? (sfw ? '1' : '0') : current[0];
    String newSketchy = sketchy != null ? (sketchy ? '1' : '0') : current[1];
    String newNsfw = nsfw != null ? (nsfw ? '1' : '0') : (current.length > 2 ? current[2] : '0');
    
    _params.purity = '$newSfw$newSketchy$newNsfw';
    fetchWallpapers(refresh: true);
  }
}
