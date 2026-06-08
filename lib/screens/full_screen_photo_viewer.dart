import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenPhotoViewer extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;

  const FullScreenPhotoViewer({
    super.key,
    required this.photoPaths,
    required this.initialIndex,
  });

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentPage + 1} / ${widget.photoPaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoPaths.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(
                File(widget.photoPaths[index]),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}