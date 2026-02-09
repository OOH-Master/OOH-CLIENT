import 'package:flutter_bloc/flutter_bloc.dart';

class ShellState {
  final int index;
  final bool sidebarExpanded;

  const ShellState({this.index = 0, this.sidebarExpanded = true});

  ShellState copyWith({int? index, bool? sidebarExpanded}) {
    return ShellState(
      index: index ?? this.index,
      sidebarExpanded: sidebarExpanded ?? this.sidebarExpanded,
    );
  }
}

class ShellCubit extends Cubit<ShellState> {
  ShellCubit() : super(const ShellState());

  void setIndex(int index) {
    emit(state.copyWith(index: index));
  }

  void toggleSidebar() {
    emit(state.copyWith(sidebarExpanded: !state.sidebarExpanded));
  }
}
