import 'dart:io';

import 'package:equatable/equatable.dart';

/// Bo'limga biriktirilgan hujjat.
///
/// Ikki holatda bo'ladi: serverdan kelgan (kaliti bor, mahalliy fayli yo'q)
/// yoki endi tanlangan (mahalliy fayli bor, kaliti hali yo'q). Yuklash faqat
/// ikkinchisiga kerak — birinchisi qayta yuklanmaydi.
final class UnderwriterFile extends Equatable {
  const UnderwriterFile({required this.key, required this.name, this.local});

  /// Serverdan kelgan hujjat.
  const UnderwriterFile.stored(this.key) : name = '', local = null;

  /// S3 kaliti. Bo'sh — hali yuklanmagan.
  final String key;

  /// Ko'rsatish uchun nom. Serverdan kelganida bo'sh bo'ladi.
  final String name;

  /// Mahalliy fayl. Serverdan kelgan hujjatda `null`.
  final File? local;

  bool get isUploaded => key.isNotEmpty;

  UnderwriterFile withKey(String value) => UnderwriterFile(key: value, name: name, local: local);

  @override
  List<Object?> get props => [key, name, local?.path];
}
