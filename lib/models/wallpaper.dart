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
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 24,
      total: json['total'] ?? 0,
    );
  }
}
