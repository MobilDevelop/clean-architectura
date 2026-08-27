part of 'invoices_bloc.dart';

sealed class InvoicesState extends Equatable {
  const InvoicesState();
  
  @override
  List<Object> get props => [];
}

final class InvoicesInitial extends InvoicesState {}
