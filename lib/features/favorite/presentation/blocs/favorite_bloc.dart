import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../discover/data/dto/dto.dart';
import '../../data/repository/favorite_repository.dart';

// Events
abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

class ToggleFavorite extends FavoriteEvent {
  final int inventoryItemId;
  const ToggleFavorite(this.inventoryItemId);
  @override
  List<Object?> get props => [inventoryItemId];
}

// States
abstract class FavoriteState extends Equatable {
  const FavoriteState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoriteState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoriteState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoriteState {
  final List<InventoryItemDto> items;
  final Set<int> favoritedIds;
  const FavoritesLoaded(this.items, this.favoritedIds);
  @override
  List<Object?> get props => [items, favoritedIds];
}

class FavoritesError extends FavoriteState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _repository;

  FavoriteBloc(this._repository) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoad);
    on<ToggleFavorite>(_onToggle);
  }

  Future<void> _onLoad(LoadFavorites event, Emitter<FavoriteState> emit) async {
    emit(const FavoritesLoading());
    try {
      final items = await _repository.listFavorites();
      final ids = items.map((i) => i.id).toSet();
      emit(FavoritesLoaded(items, ids));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggle(ToggleFavorite event, Emitter<FavoriteState> emit) async {
    try {
      final newState = await _repository.toggleFavorite(event.inventoryItemId);
      final current = state;
      if (current is FavoritesLoaded) {
        final updated = Set<int>.from(current.favoritedIds);
        if (newState) {
          updated.add(event.inventoryItemId);
        } else {
          updated.remove(event.inventoryItemId);
          final filtered = current.items
              .where((i) => i.id != event.inventoryItemId)
              .toList();
          emit(FavoritesLoaded(filtered, updated));
          return;
        }
        emit(FavoritesLoaded(current.items, updated));
      } else {
        // Not loaded — just refresh
        add(const LoadFavorites());
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
