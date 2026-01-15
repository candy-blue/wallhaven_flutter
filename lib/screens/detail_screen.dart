import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/wallpaper.dart';
import '../models/tag.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class DetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDownloading = false;
  late Wallpaper _wallpaper;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _wallpaper = widget.wallpaper;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      // Fetch full details including tags and uploader
      final provider = context.read<WallpaperProvider>();
      final fullWallpaper = await provider.getWallpaperDetails(_wallpaper.id);
      if (mounted) {
        setState(() {
          _wallpaper = fullWallpaper;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load full details: $e')),
        );
      }
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      String url = _wallpaper.path;

      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Web download not fully implemented yet')),
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        // ... (GallerySaver logic)
        bool? success =
            await GallerySaver.saveImage(url, albumName: 'Wallhaven');
        if (!mounted) return;
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to Gallery!')),
          );
        }
      } else {
        // Desktop download
        final settings = context.read<SettingsProvider>();
        String? downloadPath = settings.downloadPath;

        if (downloadPath == null) {
           final directory = await getDownloadsDirectory();
           downloadPath = directory?.path;
        }

        if (downloadPath != null) {
          final String fileName = url.split('/').last;
          final String filePath = '$downloadPath/$fileName';

          await Dio().download(url, filePath);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $filePath')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.cannotOpenLink}: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.cannotOpenLink}: $e')),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      await Share.share(
        _wallpaper.shortUrl, 
        subject: 'Check out this wallpaper from Wallhaven!'
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.shareFailed}: $e')),
        );
      }
    }
  }

  void _searchByTag(Tag tag) {
    context.read<WallpaperProvider>().setSearchQuery('id:${tag.id}');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _searchByColor(String color) {
    // Implement color search logic in provider if needed, or simple search
    // For now, let's just print or ignore as API color search is specific
    // SearchParams has colors list.
    // We can update params.
    final provider = context.read<WallpaperProvider>();
    final newParams = provider.params;
    newParams.colors = color.replaceAll('#', '');
    provider.updateSearchParams(newParams);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B3238),
      body: GestureDetector(
        onTap: () {
          // Toggle controls visibility or just let user tap the image to zoom
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                extendBodyBehindAppBar: true,
                body: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: _wallpaper.path,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
              pinned: true,
              backgroundColor: const Color(0xFF2B3238),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: _wallpaper.id,
                  child: CachedNetworkImage(
                    imageUrl: _wallpaper.path,
                    fit: BoxFit.contain, // Show full image initially
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.home, color: Color(0xFF9CCC65)),
                          onPressed: () {
                             Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.crop, color: Color(0xFF9CCC65)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Crop not implemented')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Color(0xFF9CCC65)),
                          onPressed: _shareImage,
                        ),
                        IconButton(
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download, color: Color(0xFF9CCC65)),
                          onPressed:
                              _isDownloading ? null : () => _downloadImage(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    
                    // Uploader Info
                    if (_wallpaper.uploader != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: GestureDetector(
                          onTap: () {
                             context.read<WallpaperProvider>().setSearchQuery('@${_wallpaper.uploader!.username}');
                             Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(_wallpaper.uploader!.avatar),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                             context.read<WallpaperProvider>().setSearchQuery('@${_wallpaper.uploader!.username}');
                             Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text(
                            'Uploader: ${_wallpaper.uploader!.username}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        trailing: IconButton(
                           icon: Icon(
                             _wallpaper.isFavorited == true 
                                 ? Icons.bookmark 
                                 : Icons.bookmark_border, 
                             color: const Color(0xFF9CCC65)
                           ),
                           onPressed: () async {
                             final provider = context.read<WallpaperProvider>();
                             if (!provider.isLoggedIn) {
                               if (mounted) {
                                 final l10n = AppLocalizations.of(context)!;
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text(l10n.pleaseLoginFirst),
                                     backgroundColor: Colors.orange,
                                   ),
                                 );
                               }
                               return;
                             }
                             try {
                               final wasFavorited = _wallpaper.isFavorited == true;
                               await provider.toggleFavorite(
                                 _wallpaper.id, 
                                 wasFavorited
                               );
                               if (mounted) {
                                 setState(() {
                                   _wallpaper = Wallpaper(
                                     id: _wallpaper.id,
                                     url: _wallpaper.url,
                                     shortUrl: _wallpaper.shortUrl,
                                     views: _wallpaper.views,
                                     favorites: wasFavorited 
                                         ? _wallpaper.favorites - 1 
                                         : _wallpaper.favorites + 1,
                                     source: _wallpaper.source,
                                     purity: _wallpaper.purity,
                                     category: _wallpaper.category,
                                     dimensionX: _wallpaper.dimensionX,
                                     dimensionY: _wallpaper.dimensionY,
                                     resolution: _wallpaper.resolution,
                                     ratio: _wallpaper.ratio,
                                     fileSize: _wallpaper.fileSize,
                                     fileType: _wallpaper.fileType,
                                     createdAt: _wallpaper.createdAt,
                                     colors: _wallpaper.colors,
                                     path: _wallpaper.path,
                                     thumbs: _wallpaper.thumbs,
                                     uploader: _wallpaper.uploader,
                                     tags: _wallpaper.tags,
                                     isFavorited: !wasFavorited,
                                   );
                                 });
                                 final l10n = AppLocalizations.of(context)!;
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text(
                                       wasFavorited 
                                           ? l10n.removedFromFavorites
                                           : l10n.addedToFavorites
                                     ),
                                   ),
                                 );
                               }
                             } catch (e) {
                               if (mounted) {
                                 final l10n = AppLocalizations.of(context)!;
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text('${l10n.operationFailed}: $e'),
                                     backgroundColor: Colors.red,
                                   ),
                                 );
                               }
                             }
                           },
                        ),
                      ),
  
                    // Metadata
                    _buildInfoRow(Icons.link, _wallpaper.shortUrl, isLink: true, onTap: () => _launchUrl(_wallpaper.shortUrl)),
                    _buildInfoRow(Icons.remove_red_eye, '${_wallpaper.views} Views'),
                    _buildInfoRow(Icons.favorite, '${_wallpaper.favorites} Favs'),
                    _buildInfoRow(Icons.aspect_ratio, _wallpaper.resolution),
                    _buildInfoRow(Icons.data_usage,
                        '${(_wallpaper.fileSize / 1024).toStringAsFixed(0)} Kb'),
                    _buildInfoRow(Icons.calendar_today, _wallpaper.createdAt),
                    _buildInfoRow(Icons.info_outline,
                        '${_wallpaper.purity}, ${_wallpaper.category}, ${_wallpaper.fileType}'),
  
                    const SizedBox(height: 16),
                    
                    // Search similar
                    GestureDetector(
                      onTap: () {
                          // Implement similar search if API supports it or just use tags
                          // "like:ID" is supported in search query
                          context.read<WallpaperProvider>().setSearchQuery('like:${_wallpaper.id}');
                          Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Row(
                        children: [
                          Text('Search: ', style: TextStyle(color: Colors.white)),
                          Text('Search images like this', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
  
                    const SizedBox(height: 16),
  
                    // Tags
                    if (_isLoadingDetails)
                      const Center(child: CircularProgressIndicator())
                    else if (_wallpaper.tags.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _wallpaper.tags.map((tag) => _buildTagChip(tag)).toList(),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Colors
                    if (_wallpaper.colors.isNotEmpty)
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _wallpaper.colors.map((colorHex) {
                            return GestureDetector(
                              onTap: () => _searchByColor(colorHex),
                              child: Container(
                                width: 50,
                                color: Color(int.parse(colorHex.replaceAll('#', '0xFF'))),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                    // Add extra padding at bottom to ensure content is scrollable past FAB or bottom edge
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isLink = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CCC65), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                text,
                style: TextStyle(
                  color: isLink ? const Color(0xFF9CCC65) : Colors.white70,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(Tag tag) {
    Color purityColor;
    switch (tag.purity) {
      case 'nsfw':
        purityColor = Colors.red.withOpacity(0.2);
        break;
      case 'sketchy':
        purityColor = Colors.orange.withOpacity(0.2);
        break;
      default:
        purityColor = Colors.white10;
    }

    return GestureDetector(
      onTap: () => _searchByTag(tag),
      child: Chip(
        label: Text(tag.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: purityColor,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
