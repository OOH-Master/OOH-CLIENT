import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Velika fotografija površine sa sličicama ispod (kada ih ima više) i
/// pregledom preko celog ekrana. Bez fotografije crta tamnu "noćnu" podlogu.
class ImageGallery extends StatefulWidget {
  final List<String> images;
  final String? placeholderLabel;
  final double aspectRatio;
  final bool showThumbnails;
  final double radius;
  final bool digital;

  /// Oznaka preko fotografije (tip površine).
  final Widget? topLeft;

  const ImageGallery({
    super.key,
    required this.images,
    this.placeholderLabel,
    this.aspectRatio = 16 / 9,
    this.showThumbnails = true,
    this.radius = 20,
    this.digital = false,
    this.topLeft,
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

  Widget _photo(String? url) => LayoutBuilder(
        builder: (context, box) => UnitThumb(
          imageUrl: url,
          width: box.maxWidth,
          height: box.maxHeight,
          radius: 0,
          digital: widget.digital,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final images = _validImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (images.isEmpty)
                  _buildPlaceholder()
                else if (images.length == 1)
                  GestureDetector(
                    onTap: () => _openLightbox(context, 0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.zoomIn,
                      child: _photo(images.first),
                    ),
                  )
                else
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _openLightbox(context, index),
                      child: _photo(images[index]),
                    ),
                  ),
                if (widget.topLeft != null)
                  Positioned(top: 14, left: 14, child: widget.topLeft!),
                if (images.length > 1)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _CounterPill(
                        text: '${_currentIndex + 1} / ${images.length}'),
                  ),
              ],
            ),
          ),
        ),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: UnitThumb(
                      imageUrl: images[index],
                      width: 76,
                      height: 48,
                      radius: 9,
                      digital: widget.digital,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _photo(null),
        if (widget.placeholderLabel != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Text(
              widget.placeholderLabel!,
              textAlign: TextAlign.center,
              style:
                  AppTypography.labelMedium.copyWith(color: AppColors.inkMuted),
            ),
          ),
      ],
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    final images = _validImages;
    if (images.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: const Color(0xE60F1226),
      builder: (context) {
        return _LightboxDialog(
          images: images,
          initialIndex: initialIndex,
        );
      },
    );
  }
}

class _CounterPill extends StatelessWidget {
  final String text;

  const _CounterPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
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
            final src = UnitThumb.resolve(widget.images[index]);
            return InteractiveViewer(
              child: Center(
                child: src == null
                    ? const Icon(Icons.broken_image_outlined,
                        size: 64, color: Colors.white54)
                    : Image.network(
                        src,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
              ),
            );
          },
        ),
        Positioned(
          top: 32,
          right: 16,
          child: IconButton(
            tooltip: 'Zatvori',
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: _CounterPill(
                  text: '${_currentIndex + 1} / ${widget.images.length}'),
            ),
          ),
      ],
    );
  }
}
