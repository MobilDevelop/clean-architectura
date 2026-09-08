import 'package:equatable/equatable.dart';

/// Sahifalanadigan ro'yxatning bitta sahifasi.
///
/// [isLast] alohida keladi, chunki bo'sh sahifa ham, to'la sahifa ham oxirgi
/// bo'lishi mumkin. Flex'da bu bayroq umuman o'rnatilmagan va ro'yxat oxirida
/// har siljish o'sha so'rovni qayta yuborardi.
final class Paged<T> extends Equatable {
  const Paged({required this.items, required this.isLast});

  const Paged.last(this.items) : isLast = true;

  final List<T> items;
  final bool isLast;

  @override
  List<Object?> get props => [items, isLast];
}
