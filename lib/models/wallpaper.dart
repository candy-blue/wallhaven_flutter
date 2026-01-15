import 'tag.dart';
import 'user.dart';

class Wallpaper {
  final String id;
  final String url;
  final String shortUrl;
  final int views;
  final int favorites;
  final String source;
  final String purity;
  final String category;
  final int dimensionX;
  final int dimensionY;
  final String resolution;
  final String ratio;
  final int fileSize;
  final String fileType;
  final String createdAt;
  final List<String> colors;
  final String path;
  final Thumbs thumbs;
  final User? uploader;
  final List<Tag> tags;
  final bool? isFavorited; // Added field

  Wallpaper({
    required this.id,
    required this.url,
    required this.shortUrl,
    required this.views,
    required this.favorites,
    required this.source,
    required this.purity,
    required this.category,
    required this.dimensionX,
    required this.dimensionY,
    required this.resolution,
    required this.ratio,
    required this.fileSize,
    required this.fileType,
    required this.createdAt,
    required this.colors,
    required this.path,
    required this.thumbs,
    this.uploader,
    this.tags = const [],
    this.isFavorited,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      shortUrl: json['short_url'] ?? '',
      views: json['views'] ?? 0,
      favorites: json['favorites'] ?? 0,
      source: json['source'] ?? '',
      purity: json['purity'] ?? 'sfw',
      category: json['category'] ?? 'general',
      dimensionX: json['dimension_x'] ?? 0,
      dimensionY: json['dimension_y'] ?? 0,
      resolution: json['resolution'] ?? '',
      ratio: json['ratio'] ?? '',
      fileSize: json['file_size'] ?? 0,
      fileType: json['file_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      colors: List<String>.from(json['colors'] ?? []),
      path: json['path'] ?? '',
      thumbs: Thumbs.fromJson(json['thumbs'] ?? {}),
      uploader: json['uploader'] != null ? User.fromJson(json['uploader']) : null,
      tags: (json['tags'] as List?)?.map((e) => Tag.fromJson(e)).toList() ?? [],
      // API doesn't always return isFavorited, usually it's implied if we are in favorites collection? 
      // Or maybe there is a field "favorited"? Wallhaven API docs don't explicitly say for search results.
      // But for individual wallpaper details it might have it. 
      // Let's assume it might be there or null.
      isFavorited: json['favorites'] != null ? null : null, // Placeholder, logic needs to be handled by provider or specific API response
    );
  }
}

class Thumbs {
  final String large;
  final String original;
  final String small;

  Thumbs({
    required this.large,
    required this.original,
    required this.small,
  });

  factory Thumbs.fromJson(Map<String, dynamic> json) {
    return Thumbs(
      large: json['large'] ?? '',
      original: json['original'] ?? '',
      small: json['small'] ?? '',
    );
  }
}

class WallpaperListResponse {
  final List<Wallpaper> data;
  final Meta meta;

  WallpaperListResponse({required this.data, required this.meta});

  factory WallpaperListResponse.fromJson(Map<String, dynamic> json) {
    return WallpaperListResponse(
      data: (json['data'] as List?)
              ?.map((e) => Wallpaper.fromJson(e))
              .toList() ??
          [],
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class Meta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Meta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] is int ? json['current_page'] : int.tryParse(json['current_page'].toString()) ?? 1,
      lastPage: json['last_page'] is int ? json['last_page'] : int.tryParse(json['last_page'].toString()) ?? 1,
      perPage: json['per_page'] is int ? json['per_page'] : int.tryParse(json['per_page'].toString()) ?? 24,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total'].toString()) ?? 0,
    );
  }
}
