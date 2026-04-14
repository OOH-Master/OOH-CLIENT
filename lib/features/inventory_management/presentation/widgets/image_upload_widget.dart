import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

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
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pendingFiles = [];

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
            content: Text('Greska pri odabiru slika: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slike',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.existingImages.isNotEmpty || _pendingFiles.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...widget.existingImages.asMap().entries.map((entry) {
                  return _buildImageThumbnail(
                    child: Image.network(
                      entry.value,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.muted,
                        child: Icon(Icons.broken_image, color: AppColors.mutedForeground),
                      ),
                    ),
                    onRemove: widget.onImageRemoved != null
                        ? () => widget.onImageRemoved!(entry.key)
                        : null,
                  );
                }),
                ..._pendingFiles.asMap().entries.map((entry) {
                  return _buildImageThumbnail(
                    child: FutureBuilder<Widget>(
                      future: _buildLocalImage(entry.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) return snapshot.data!;
                        return Container(
                          width: 120,
                          height: 120,
                          color: AppColors.muted,
                          child: const CircularProgressIndicator(),
                        );
                      },
                    ),
                    onRemove: () {
                      setState(() => _pendingFiles.removeAt(entry.key));
                    },
                  );
                }),
                _buildAddButton(),
              ],
            ),
          )
        else
          _buildEmptyState(),
        if (widget.isUploading) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Otpremanje slika...',
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }

  Widget _buildImageThumbnail({required Widget child, VoidCallback? onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(width: 120, height: 120, child: child),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.mutedForeground),
            const SizedBox(height: 4),
            Text(
              'Dodaj sliku',
              style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.mutedForeground),
            const SizedBox(height: 8),
            Text(
              'Dodajte slike inventara',
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> _buildLocalImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      width: 120,
      height: 120,
    );
  }
}
