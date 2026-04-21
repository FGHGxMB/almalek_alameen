// lib/logic/main_layout/main_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial(currentIndex: 0));

  void changeTab(int index) {
    emit(MainInitial(currentIndex: index));
  }
}