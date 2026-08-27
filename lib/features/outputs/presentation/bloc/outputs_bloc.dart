import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'outputs_event.dart';
part 'outputs_state.dart';

class OutputsBloc extends Bloc<OutputsEvent, OutputsState> {
  OutputsBloc() : super(OutputsInitial()) {
    on<OutputsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
