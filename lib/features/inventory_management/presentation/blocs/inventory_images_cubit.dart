import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/dto/inventory_image_dto.dart';
import '../../data/repository/inventory_management_repository.dart';

class InventoryImagesState {
  final List<InventoryImageDto> images;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  const InventoryImagesState({
    this.images = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.error,
  });

  InventoryImagesState copyWith({
    List<InventoryImageDto>? images,
    bool? isLoading,
    bool? isUploading,
    String? error,
    bool clearError = false,
  }) {
    return InventoryImagesState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class InventoryImagesCubit extends Cubit<InventoryImagesState> {
  final InventoryManagementRepository _repository;
  final int inventoryItemId;

  InventoryImagesCubit(this._repository, this.inventoryItemId)
      : super(const InventoryImagesState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final images = await _repository.listImages(inventoryItemId);
      emit(state.copyWith(images: images, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> uploadImages(List<XFile> files) async {
    emit(state.copyWith(isUploading: true, clearError: true));
    final uploaded = <InventoryImageDto>[...state.images];
    for (final file in files) {
      try {
        final img = await _repository.uploadImage(inventoryItemId, file);
        uploaded.add(img);
      } catch (e) {
        // Emit partial success — already-uploaded images are preserved
        emit(state.copyWith(images: uploaded, isUploading: false, error: e.toString()));
        return;
      }
    }
    emit(state.copyWith(images: uploaded, isUploading: false));
  }

  Future<void> deleteImage(int imageId) async {
    emit(state.copyWith(clearError: true));
    try {
      await _repository.deleteImage(imageId);
      emit(state.copyWith(
        images: state.images.where((i) => i.id != imageId).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
