import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../l10n/app_localizations.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.categories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Consumer<WallpaperProvider>(
            builder: (context, provider, child) {
              final cats = provider.params.categories;
              return Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.general),
                    selected: cats[0] == '1',
                    onSelected: (val) => provider.setCategory(general: val),
                  ),
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.anime),
                    selected: cats[1] == '1',
                    onSelected: (val) => provider.setCategory(anime: val),
                  ),
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.people),
                    selected: cats[2] == '1',
                    onSelected: (val) => provider.setCategory(people: val),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.purity, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Consumer<WallpaperProvider>(
            builder: (context, provider, child) {
              final purity = provider.params.purity;
              return Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.sfw),
                    selected: purity[0] == '1',
                    onSelected: (val) => provider.setPurity(sfw: val),
                  ),
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.sketchy),
                    selected: purity[1] == '1',
                    onSelected: (val) => provider.setPurity(sketchy: val),
                  ),
                  // Note: NSFW usually requires API Key on Wallhaven
                  FilterChip(
                    label: Text(AppLocalizations.of(context)!.nsfw),
                    selected: purity.length > 2 && purity[2] == '1',
                    onSelected: (val) => provider.setPurity(nsfw: val),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.sorting, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Consumer<WallpaperProvider>(
            builder: (context, provider, child) {
              return Wrap(
                spacing: 8,
                children: [
                  _buildSortChip(context, provider, 'date_added', AppLocalizations.of(context)!.dateAdded),
                  _buildSortChip(context, provider, 'relevance', AppLocalizations.of(context)!.relevance),
                  _buildSortChip(context, provider, 'random', AppLocalizations.of(context)!.random),
                  _buildSortChip(context, provider, 'views', AppLocalizations.of(context)!.views),
                  _buildSortChip(context, provider, 'favorites', AppLocalizations.of(context)!.favorites),
                  _buildSortChip(context, provider, 'toplist', AppLocalizations.of(context)!.toplist),
                  _buildSortChip(context, provider, 'hot', AppLocalizations.of(context)!.hot),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, WallpaperProvider provider, String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: provider.params.sorting == value,
      onSelected: (selected) {
        if (selected) {
          final newParams = provider.params;
          newParams.sorting = value;
          provider.updateSearchParams(newParams);
        }
      },
    );
  }
}
