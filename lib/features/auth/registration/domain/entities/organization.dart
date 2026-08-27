import 'package:equatable/equatable.dart';

final class Organization extends Equatable {
  const Organization({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object> get props => [id, title];
}