import 'dart:io';

import 'package:equatable/equatable.dart';

/// Serverga yuboriladigan so'rov. Tekshiruv `FaceCheckForm` da bo'lib bo'lgan —
/// bu yerga faqat to'g'ri ma'lumot yetib keladi.
final class FaceCheckParams extends Equatable {
  const FaceCheckParams({required this.passport, required this.birthday, required this.image});

  final String passport;

  /// `dd.MM.yyyy` — backend aynan shu formatni kutadi.
  final String birthday;

  final File image;

  @override
  List<Object?> get props => [passport, birthday, image.path];
}
