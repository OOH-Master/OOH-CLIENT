import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

/// Fotografije površine: postojeće sa servera, izabrane koje se upravo šalju i
/// polje za dodavanje novih.
class ImageUploadWidget extends StatefulWidget {
  final List<String> existingImages;
  final ValueChanged<List<XFile>> onImagesAdded;
  final ValueChanged<int>? onImageRemoved;
  final bool isUploading;

  const ImageUploadWidget({
    super.key,
    this.existingImages = const [],
    required this.onImagesAdded,
    this.onImageRemoved,
    this.isUploading = false,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  static const double _tileW = 132;
  static const double _tileH = 96;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pendingFiles = [];
  final Map<XFile, Future<Widget>> _previews = {};

  @override
  void didUpdateWidget(covariant ImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kada slanje završi, poslate slike stižu kao postojeće; lokalni pregled se
    // briše da se iste slike ne bi prikazale dva puta.
    if (oldWidget.isUploading &&
        !widget.isUploading &&
        _pendingFiles.isNotEmpty) {
      _pendingFiles.clear();
      _previews.clear();
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() => _pendingFiles.addAll(images));
        widget.onImagesAdded(images);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri izboru fotografija: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = widget.existingImages.isNotEmpty || _pendingFiles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasAny)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in widget.existingImages.asMap().entries)
                _Thumb(
                  width: _tileW,
                  height: _tileH,
                  onRemove: widget.onImageRemoved != null
                      ? () => widget.onImageRemoved!(entry.key)
                      : null,
                  child: Image.network(
                    entry.value,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppColors.surfaceSunken,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: AppColors.mutedForeground),
                      ),
                    ),
                  ),
                ),
              for (final entry in _pendingFiles.asMap().entries)
                _Thumb(
                  width: _tileW,
                  height: _tileH,
                  uploading: widget.isUploading,
                  onRemove: widget.isUploading
                      ? null
                      : () => setState(() => _pendingFiles.removeAt(entry.key)),
                  child: FutureBuilder<Widget>(
                    future: _previews.putIfAbsent(
                        entry.value, () => _buildLocalImage(entry.value)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) return snapshot.data!;
                      return const ColoredBox(color: AppColors.surfaceSunken);
                    },
                  ),
                ),
              _AddTile(
                width: _tileW,
                height: _tileH,
                onTap: widget.isUploading ? null : _pickImages,
              ),
            ],
          )
        else
          _EmptyDrop(onTap: _pickImages),
        if (widget.isUploading) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(minHeight: 3),
          ),
          const SizedBox(height: 6),
          Text(
            'Fotografije se šalju…',
            style: AppTypography.caption
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }

  Future<Widget> _buildLocalImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return Image.memory(bytes, fit: BoxFit.cover);
  }
}

class _Thumb extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final VoidCallback? onRemove;
  final bool uploading;

  const _Thumb({
    required this.width,
    required this.height,
    required this.child,
    this.onRemove,
    this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: child,
          ),
          if (uploading)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ColoredBox(
                color: AppColors.ink.withValues(alpha: 0.35),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: 6,
              right: 6,
              child: Tooltip(
                message: 'Ukloni fotografiju',
                child: Material(
                  color: AppColors.ink.withValues(alpha: 0.72),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.close_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _AddTile({required this.width, required this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSunken,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.input),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined,
                  size: 26, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                'Dodaj',
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDrop extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyDrop({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSunken,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.input),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined,
                  size: 24, color: AppColors.mutedForeground),
              const SizedBox(height: 8),
              Text('Dodajte fotografije površine',
                  style: AppTypography.labelLarge),
              const SizedBox(height: 2),
              Text(
                'JPEG, PNG ili WebP, do 10 MB po fotografiji',
                style: AppTypography.caption
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
