import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/filter_toolbar.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

import 'filter_screen.dart';

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
      final provider = context.read<WallpaperProvider>();
      // Check login status
      if (!provider.isLoggedIn && provider.api.apiKey == null) {
        // Show a gentle reminder after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.loginReminder),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.blue,
              ),
            );
          }
        });
      }
      provider.fetchWallpapers(refresh: true).then((_) {
        // Check if we need to load more to fill the screen
        _checkLoadMore();
      });
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<WallpaperProvider>().fetchWallpapers();
    }
  }

  Future<void> _checkLoadMore({int loadedCount = 0}) async {
    if (!mounted) return;
    // Limit to 5 pages max to avoid infinite loops
    if (loadedCount >= 5) return;

    // Wait for layout to update
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Simple check: if maxScrollExtent is small (less than screen height), try loading more
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent < MediaQuery.of(context).size.height) {
      final provider = context.read<WallpaperProvider>();
      if (provider.hasMore && !provider.isLoading) {
        await provider.fetchWallpapers();
        // Recursively check again
        await _checkLoadMore(loadedCount: loadedCount + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearchBar() {
    setState(() {
      if (_showSearchBar) {
        _showSearchBar = false;
        _searchController.clear();
        context.read<WallpaperProvider>().setSearchQuery('');
      } else {
        _showSearchBar = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    // Dynamic column count based on screen width
    // Increased base width per column to 300dp for larger preview images
    int crossAxisCount = (screenWidth / 300).round();
    if (crossAxisCount < 2) crossAxisCount = 2;

    return Scaffold(
      appBar: AppBar(
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      drawer: _buildDrawer(context, l10n),
      body: Column(
        children: [
          const FilterToolbar(),
          Expanded(
            child: Consumer<WallpaperProvider>(
              builder: (context, provider, child) {
                if (provider.wallpapers.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.wallpapers.isEmpty) {
                  return Center(child: Text(l10n.noWallpapersFound));
                }

                return MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: crossAxisCount,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n) {
    return Drawer(
      child: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          final sorting = provider.params.sorting;
          final categories = provider.params.categories;
          final purity = provider.params.purity;
          final theme = Theme.of(context);
          final activeColor = theme.primaryColor;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: theme.appBarTheme.backgroundColor),
                accountName: Text(
                  provider.isLoggedIn ? (provider.username ?? 'User') : 'Guest',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  provider.isLoggedIn ? 'Logged in' : 'Login in Settings',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Main',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.image,
                text: l10n.dateAdded,
                isSelected: sorting == 'date_added' && provider.collections.isEmpty, // Simplistic check
                onTap: () async {
                  final newParams = provider.params;
                  newParams.sorting = 'date_added';
                  await provider.switchToSearch(); // Ensure we are in search mode
                  provider.updateSearchParams(newParams);
                  Navigator.pop(context);
                },
                activeColor: activeColor,
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.whatshot,
                text: l10n.hot,
                isSelected: sorting == 'hot',
                onTap: () async {
                  final newParams = provider.params;
                  newParams.sorting = 'hot';
                  await provider.switchToSearch();
                  provider.updateSearchParams(newParams);
                  Navigator.pop(context);
                },
                activeColor: activeColor,
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.shuffle,
                text: l10n.random,
                isSelected: sorting == 'random',
                onTap: () async {
                  final newParams = provider.params;
                  newParams.sorting = 'random';
                  await provider.switchToSearch();
                  provider.updateSearchParams(newParams);
                  Navigator.pop(context);
                },
                activeColor: activeColor,
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.trending_up,
                text: l10n.toplist,
                isSelected: sorting == 'toplist',
                onTap: () async {
                  final newParams = provider.params;
                  newParams.sorting = 'toplist';
                  await provider.switchToSearch();
                  provider.updateSearchParams(newParams);
                  Navigator.pop(context);
                },
                activeColor: activeColor,
              ),
              
              if (provider.isLoggedIn && provider.collections.isNotEmpty) ...[
                 const Divider(),
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'My Collections',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...provider.collections.map((collection) {
                  return _buildDrawerItem(
                    context: context,
                    icon: Icons.folder,
                    text: collection.label,
                    isSelected: false, // TODO: track selected collection
                    onTap: () async {
                      if (provider.username != null) {
                        await provider.switchToCollection(collection.id, provider.username!);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Username not found, please relogin')),
                           );
                         }
                      }
                    },
                    activeColor: activeColor,
                  );
                }),
              ],

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: Text(l10n.categories), // Using 'Categories' or a more generic 'Search Filters' label
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FilterScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: isSelected
          ? BoxDecoration(
              color: activeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? activeColor : Colors.white70,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
