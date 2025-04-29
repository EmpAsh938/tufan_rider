import 'package:flutter_bloc/flutter_bloc.dart';

enum AppMode { passenger, rider }

class ModeCubit extends Cubit<AppMode> {
  ModeCubit() : super(AppMode.passenger);

  void toggleMode() {
    emit(state == AppMode.passenger ? AppMode.rider : AppMode.passenger);
  }

  void setMode(AppMode mode) {
    emit(mode);
  }
}
