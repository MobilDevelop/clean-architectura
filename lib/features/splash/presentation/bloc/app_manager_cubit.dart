import 'package:colloborator_v3/core/di/app_startup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'app_manager_state.dart';

class AppManagerCubit extends Cubit<AppManagerState> {
  AppManagerCubit(this._startup) : super(AppManagerLoading());
  
  final AppStartup _startup;

  Future<void> init() async {
    try {
      final version = await _startup.prepare();
      emit(AppManagerInitial(version: version));
    } catch (e, s) {
      debugPrint('App startup failed: $e\n$s');
      emit(AppManagerError("Internet aloqasini tekshirib, ilovani qayta oching."));
  }
  }
}
