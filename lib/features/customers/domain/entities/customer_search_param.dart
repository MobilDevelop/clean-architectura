import 'package:equatable/equatable.dart';

/// Qidiruv matni qaysi turdagi ma'lumot ekani.
enum CustomerSearchKind { passport, inps, fullName }

abstract final class CustomerSearchShape {
  static const int passportLetters = 2;
  static const int passportDigits = 7;
  static const int inpsDigits = 14;
  static const int fullNameMinLength = 3;

  static const String letters = r'A-Za-zА-Яа-яЁёЎўҚқҒғҲҳ';
}

final class CustomerSearchParams extends Equatable {
  const CustomerSearchParams._(this.query, this.kind);

  factory CustomerSearchParams(String raw) {
    final query = raw.trim();
    return CustomerSearchParams._(query, _kindOf(query));
  }

  final String query;
  final CustomerSearchKind kind;

  bool get isComplete => switch (kind) {
        CustomerSearchKind.passport => query.length == CustomerSearchShape.passportLetters + CustomerSearchShape.passportDigits,
        CustomerSearchKind.inps => query.length == CustomerSearchShape.inpsDigits,
        CustomerSearchKind.fullName => false,
      };

  /// Shu matn bilan qidirishga ruxsat berilganmi.
  bool get isSearchable => switch (kind) {
        CustomerSearchKind.passport => isComplete,
        CustomerSearchKind.inps => isComplete,
        CustomerSearchKind.fullName =>query.length >= CustomerSearchShape.fullNameMinLength && _fullName.hasMatch(query),
      };

  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _passport = RegExp('^[${CustomerSearchShape.letters}]{${CustomerSearchShape.passportLetters}}\\d+\$');

  static final RegExp _fullName = RegExp("^[${CustomerSearchShape.letters}\\s\\-']+\$");

  static CustomerSearchKind _kindOf(String query) {
    if (_digits.hasMatch(query)) return CustomerSearchKind.inps;
    if (_passport.hasMatch(query)) return CustomerSearchKind.passport;

    return CustomerSearchKind.fullName;
  }

  @override
  List<Object> get props => [query, kind];
}
