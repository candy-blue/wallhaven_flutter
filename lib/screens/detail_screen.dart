import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/wallpaper.dart';

class DetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDownloading = false;

  Future<void> _downloadImage(BuildContext context) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      String url = widget.wallpaper.path;
      
      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Web download not fully implemented yet')),
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        bool? success = await GallerySaver.saveImage(url, albumName: 'Wallhaven');
        if (!mounted) return;
        if (success == true) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to Gallery!')),
          );
        }
      } else {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final String fileName = url.split('/').last;
          final String filePath = '${directory.path}/$fileName';
          
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.wallpaper.id,
            child: CachedNetworkImage(
              imageUrl: widget.wallpaper.path,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: _isDownloading ? null : () => _downloadImage(context),
              child: _isDownloading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Icon(Icons.download),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resolution: ${widget.wallpaper.resolution}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Size: ${(widget.wallpaper.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Category: ${widget.wallpaper.category}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
