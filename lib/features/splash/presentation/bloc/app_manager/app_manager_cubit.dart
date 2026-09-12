import 'package:colloborator_v3/core/di/app_startup.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'app_manager_state.dart';

class AppManagerCubit extends Cubit<AppManagerState> {
  AppManagerCubit(this._startup) : super(AppManagerLoading());
  
  final AppStartup _startup;

  Future<void> init() async {
    final result = await _startup.prepare();

    switch (result) {
      case Ok(: final value): emit(AppManagerInitial(version: value));
      case Err(: final failure): emit(AppManagerError(failure));
    }
  }
}
