import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import 'filter_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WallpaperProvider>().fetchWallpapers(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<WallpaperProvider>().fetchWallpapers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ),
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  context.read<WallpaperProvider>().setSearchQuery(value);
                },
              )
            : Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_showSearchBar) {
                  _showSearchBar = false;
                  _searchController.clear();
                  context.read<WallpaperProvider>().setSearchQuery('');
                } else {
                  _showSearchBar = true;
                }
              });
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 300,
        child: SafeArea(
          child: Column(
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.settings, style: Theme.of(context).textTheme.headlineSmall),
              ),
              const Expanded(child: FilterScreen()),
            ],
          ),
        ),
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          if (provider.wallpapers.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.wallpapers.isEmpty) {
            return Center(child: Text(l10n.noWallpapersFound));
          }

          return MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: provider.wallpapers.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.wallpapers.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final wallpaper = provider.wallpapers[index];
              // Calculate aspect ratio for the container
              final aspectRatio = wallpaper.dimensionX / wallpaper.dimensionY;
              
              return AspectRatio(
                aspectRatio: aspectRatio,
                child: WallpaperGridItem(wallpaper: wallpaper),
              );
            },
          );
        },
      ),
    );
  }
}
