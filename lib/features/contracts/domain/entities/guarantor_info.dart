import 'package:equatable/equatable.dart';

final class GuarantorInfo extends Equatable{
  final int id;
  final String name;
  final String inps;
  final String passport;
  final String birthday;
  final String phone;
  final String signUrl;
  final bool isFaceCheck;

  bool get isSigned => signUrl.isNotEmpty;

  const GuarantorInfo({required this.id,required this.name,required this.inps,required this.passport,required this.birthday,required this.phone,required this.isFaceCheck,required this.signUrl});

  @override
  List<Object?> get props => [id,name,inps,passport,birthday,phone,signUrl,isFaceCheck];
}