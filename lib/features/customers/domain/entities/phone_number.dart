import 'package:equatable/equatable.dart';

final class PhoneNumber extends Equatable{

  const PhoneNumber({required this.id,required this.phone,required this.isMain, required this.comment});

  final int id;
  final String phone;
  final bool isMain;
  final String comment;

  @override
  List<Object?> get props => [id,phone,isMain,comment];

}