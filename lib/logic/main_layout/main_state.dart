// lib/logic/main_layout/main_state.dart

abstract class MainState {}

class MainInitial extends MainState {
  final int currentIndex;
  MainInitial({this.currentIndex = 0});
}