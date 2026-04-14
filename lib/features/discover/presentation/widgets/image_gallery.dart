import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ImageGallery extends StatefulWidget {
  final List<String> images;
  final String? placeholderLabel;
  final double aspectRatio;
  final bool showThumbnails;

  const ImageGallery({
    super.key,
    required this.images,
    this.placeholderLabel,
    this.aspectRatio = 16 / 9,
    this.showThumbnails = true,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _currentIndex = 0;
  late PageController _pageController;

  List<String> get _validImages =>
      widget.images.where((img) => img.isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _validImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image / carousel
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            children: [
              if (images.isEmpty)
                _buildPlaceholder()
              else if (images.length == 1)
                GestureDetector(
                  onTap: () => _openLightbox(context, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openLightbox(context, index),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      );
                    },
                  ),
                ),
              // Dots indicator
              if (images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      final isActive = index == _currentIndex;
                      return Container(
                        width: isActive ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
        // Thumbnails
        if (widget.showThumbnails && images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.muted),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: AppColors.mutedForeground),
            if (widget.placeholderLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.placeholderLabel!,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    final images = _validImages;
    if (images.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return _LightboxDialog(
          images: images,
          initialIndex: initialIndex,
        );
      },
    );
  }
}

class _LightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _LightboxDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            );
          },
        ),
        // Close button
        Positioned(
          top: 40,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // Page indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
