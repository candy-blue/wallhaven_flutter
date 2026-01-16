class SearchParams {
  String q;
  String categories; // 111 (general/anime/people)
  String purity; // 100 (sfw/sketchy/nsfw)
  String sorting; // date_added, relevance, random, views, favorites, toplist
  String order; // desc, asc
  String topRange; // 1d, 3d, 1w, 1M, 3M, 6M, 1y
  String? colors;
  String? ratios; // 16x9,16x10 etc
  int page;
  String? seed; // For random sorting
  int aiArtFilter; // 1 = filter out AI, 0 = show AI

  SearchParams({
    this.q = '',
    this.categories = '111',
    this.purity = '100',
    this.sorting = 'hot',
    this.order = 'desc',
    this.topRange = '1M',
    this.colors,
    this.ratios,
    this.page = 1,
    this.seed,
    this.aiArtFilter = 1,
  });

  // Clone method
  SearchParams clone() {
    return SearchParams(
      q: q,
      categories: categories,
      purity: purity,
      sorting: sorting,
      order: order,
      topRange: topRange,
      colors: colors,
      ratios: ratios,
      page: page,
      seed: seed,
      aiArtFilter: aiArtFilter,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'q': q,
      'categories': categories,
      'purity': purity,
      'sorting': sorting,
      'order': order,
      'page': page,
      'ai_art_filter': aiArtFilter,
    };
    
    if (sorting == 'toplist') {
      data['topRange'] = topRange;
    }
    
    if (colors != null && colors!.isNotEmpty) {
      data['colors'] = colors;
    }

    if (ratios != null && ratios!.isNotEmpty) {
      data['ratios'] = ratios;
    }

    if (sorting == 'random' && seed != null) {
      data['seed'] = seed;
    }

    return data;
  }
}
