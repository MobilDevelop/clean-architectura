part of 'outputs_bloc.dart';

sealed class OutputsState extends Equatable {
  const OutputsState();
  
  @override
  List<Object> get props => [];
}

final class OutputsInitial extends OutputsState {}
