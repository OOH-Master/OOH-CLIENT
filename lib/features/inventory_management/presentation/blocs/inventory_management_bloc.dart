import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../discover/data/dto/dto.dart';
import '../../data/repository/inventory_management_repository.dart';

// Events
abstract class InventoryManagementEvent {}

class LoadMyInventory extends InventoryManagementEvent {}

class CreateInventoryItem extends InventoryManagementEvent {
  final Map<String, dynamic> data;
  CreateInventoryItem(this.data);
}

class UpdateInventoryItem extends InventoryManagementEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateInventoryItem(this.id, this.data);
}

class DeleteInventoryItem extends InventoryManagementEvent {
  final int id;
  DeleteInventoryItem(this.id);
}

class SearchInventory extends InventoryManagementEvent {
  final String query;
  SearchInventory(this.query);
}

class FilterByStatus extends InventoryManagementEvent {
  final String? status;
  FilterByStatus(this.status);
}

class SortInventory extends InventoryManagementEvent {
  final String sortBy;
  SortInventory(this.sortBy);
}

class ToggleSelection extends InventoryManagementEvent {
  final int id;
  ToggleSelection(this.id);
}

class SelectAll extends InventoryManagementEvent {}

class ClearSelection extends InventoryManagementEvent {}

class BulkUpdateStatus extends InventoryManagementEvent {
  final List<int> ids;
  final String status;
  BulkUpdateStatus(this.ids, this.status);
}

// States
abstract class InventoryManagementState {}

class InventoryManagementInitial extends InventoryManagementState {}

class InventoryManagementLoading extends InventoryManagementState {}

class InventoryManagementLoaded extends InventoryManagementState {
  final List<InventoryItemDto> items;
  final List<InventoryItemDto> filteredItems;
  final String searchQuery;
  final String? statusFilter;
  final String sortBy;
  final Set<int> selectedIds;

  InventoryManagementLoaded({
    required this.items,
    List<InventoryItemDto>? filteredItems,
    this.searchQuery = '',
    this.statusFilter,
    this.sortBy = 'name',
    this.selectedIds = const {},
  }) : filteredItems = filteredItems ?? items;

  InventoryManagementLoaded copyWith({
    List<InventoryItemDto>? items,
    List<InventoryItemDto>? filteredItems,
    String? searchQuery,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? sortBy,
    Set<int>? selectedIds,
  }) {
    return InventoryManagementLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortBy: sortBy ?? this.sortBy,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class InventoryFormSuccess extends InventoryManagementState {
  final String message;
  InventoryFormSuccess(this.message);
}

class InventoryManagementError extends InventoryManagementState {
  final String message;
  InventoryManagementError(this.message);
}

// Bloc
class InventoryManagementBloc
    extends Bloc<InventoryManagementEvent, InventoryManagementState> {
  final InventoryManagementRepository _repository;

  InventoryManagementBloc(this._repository) : super(InventoryManagementInitial()) {
    on<LoadMyInventory>(_onLoadMyInventory);
    on<CreateInventoryItem>(_onCreateInventory);
    on<UpdateInventoryItem>(_onUpdateInventory);
    on<DeleteInventoryItem>(_onDeleteInventory);
    on<SearchInventory>(_onSearchInventory);
    on<FilterByStatus>(_onFilterByStatus);
    on<SortInventory>(_onSortInventory);
    on<ToggleSelection>(_onToggleSelection);
    on<SelectAll>(_onSelectAll);
    on<ClearSelection>(_onClearSelection);
    on<BulkUpdateStatus>(_onBulkUpdateStatus);
  }

  Future<void> _onLoadMyInventory(
    LoadMyInventory event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      final items = await _repository.getMyInventory();
      emit(InventoryManagementLoaded(items: items));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onCreateInventory(
    CreateInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      await _repository.createInventory(event.data);
      emit(InventoryFormSuccess('Inventory item created'));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateInventory(
    UpdateInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      await _repository.updateInventory(event.id, event.data);
      emit(InventoryFormSuccess('Inventory item updated'));
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteInventory(
    DeleteInventoryItem event,
    Emitter<InventoryManagementState> emit,
  ) async {
    try {
      await _repository.deleteInventory(event.id);
      emit(InventoryFormSuccess('Inventory item deleted'));
      add(LoadMyInventory());
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  void _onSearchInventory(
    SearchInventory event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.items,
      event.query,
      currentState.statusFilter,
      currentState.sortBy,
    );
    emit(currentState.copyWith(
      searchQuery: event.query,
      filteredItems: filtered,
    ));
  }

  void _onFilterByStatus(
    FilterByStatus event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.items,
      currentState.searchQuery,
      event.status,
      currentState.sortBy,
    );
    emit(currentState.copyWith(
      statusFilter: event.status,
      clearStatusFilter: event.status == null,
      filteredItems: filtered,
    ));
  }

  void _onSortInventory(
    SortInventory event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.items,
      currentState.searchQuery,
      currentState.statusFilter,
      event.sortBy,
    );
    emit(currentState.copyWith(
      sortBy: event.sortBy,
      filteredItems: filtered,
    ));
  }

  void _onToggleSelection(
    ToggleSelection event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;

    final selected = Set<int>.from(currentState.selectedIds);
    if (selected.contains(event.id)) {
      selected.remove(event.id);
    } else {
      selected.add(event.id);
    }
    emit(currentState.copyWith(selectedIds: selected));
  }

  void _onSelectAll(
    SelectAll event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;

    final allIds = currentState.filteredItems.map((i) => i.id).toSet();
    emit(currentState.copyWith(selectedIds: allIds));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<InventoryManagementState> emit,
  ) {
    final currentState = state;
    if (currentState is! InventoryManagementLoaded) return;
    emit(currentState.copyWith(selectedIds: const {}));
  }

  Future<void> _onBulkUpdateStatus(
    BulkUpdateStatus event,
    Emitter<InventoryManagementState> emit,
  ) async {
    // Update each item's status
    try {
      for (final id in event.ids) {
        await _repository.updateInventory(id, {'status': event.status});
      }
      emit(InventoryFormSuccess('Status azuriran za ${event.ids.length} stavki'));
      add(LoadMyInventory());
    } catch (e) {
      emit(InventoryManagementError(e.toString()));
    }
  }

  List<InventoryItemDto> _applyFiltersAndSort(
    List<InventoryItemDto> items,
    String query,
    String? statusFilter,
    String sortBy,
  ) {
    var result = List<InventoryItemDto>.from(items);

    // Filter by search query
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((item) {
        return (item.siteName?.toLowerCase().contains(q) ?? false) ||
            (item.fullAddress?.toLowerCase().contains(q) ?? false) ||
            (item.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Filter by status
    if (statusFilter != null) {
      result = result.where((item) {
        return item.status?.toUpperCase() == statusFilter.toUpperCase();
      }).toList();
    }

    // Sort
    switch (sortBy) {
      case 'name':
        result.sort((a, b) =>
            (a.siteName ?? '').compareTo(b.siteName ?? ''));
      case 'price':
        result.sort((a, b) =>
            (a.pricePerCycle ?? 0).compareTo(b.pricePerCycle ?? 0));
      case 'date':
        // Keep original order (newest first)
        break;
    }

    return result;
  }
}
