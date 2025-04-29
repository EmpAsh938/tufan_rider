import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { passenger, rider }

class ModeCubit extends Cubit<AppMode> {
  static const String _modeKey = 'app_mode';

  ModeCubit() : super(AppMode.passenger) {}

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_modeKey);
    if (saved != null) {
      emit(saved == 'rider' ? AppMode.rider : AppMode.passenger);
    }
  }

  Future<void> toggleMode() async {
    final newMode =
        state == AppMode.passenger ? AppMode.rider : AppMode.passenger;
    emit(newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, newMode.name);
  }

  Future<void> setMode(AppMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }
}
