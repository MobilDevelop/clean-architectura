
final class ParseIssue {
  const ParseIssue({required this.model, required this.reason, this.index, this.trace});

  final String model;
  final String reason;
  final StackTrace? trace;
  final int? index;

  /// Bir xil muammolarni guruhlash uchun kalit.
  /// Xabar beruvchi shu bo'yicha takrorlarni filtrlaydi — toshqin bo'lmasligi uchun.
  String get signature => '$model|$reason';

  @override
  String toString() => 'ParseIssue($model${index == null ? '' : '[$index]'}: $reason)';
}

typedef ParseIssueReporter = void Function(ParseIssue issue);

abstract final class JsonParser {
  static ParseIssueReporter? reporter;

  static List<T> list<T>(Object? raw, {required T Function(Map<String, dynamic> json) fromJson}) {
    if (raw is! List) {
      if (raw != null) _report(ParseIssue(model: '$T', reason: "ro'yxat emas: ${raw.runtimeType}"));
      return <T>[];
    }

    final result = <T>[];

    for (int i = 0; i < raw.length; i++) {
      final item = raw[i];

      if (item is! Map) {
        _report(ParseIssue(model: '$T', reason: 'element obyekt emas: ${item.runtimeType}', index: i));
        continue;
      }

      try {
        // Map<Object?, Object?> ham kelishi mumkin (masalan platform channel'dan)
        result.add(fromJson(Map<String, dynamic>.from(item)));
      } catch (e, s) {
        _report(ParseIssue(model: '$T', reason: e.toString(), trace: s, index: i));
      }
    }

    return result;
  }

  /// Bitta obyektni parse qiladi. Buzuq bo'lsa `null` qaytadi va xabar beriladi.
  static T? object<T>(Object? raw, {required T Function(Map<String, dynamic> json) fromJson}) {
    if (raw is! Map) {
      if (raw != null) _report(ParseIssue(model: '$T', reason: 'obyekt emas: ${raw.runtimeType}'));
      return null;
    }

    try {
      return fromJson(Map<String, dynamic>.from(raw));
    } catch (e,s) {
      _report(ParseIssue(model: '$T',reason: e.runtimeType.toString(),trace: s,));
      return null;
    }
  }

  static void _report(ParseIssue issue) {
    final report = reporter;
    if (report == null) return;

    report(issue);
  }
}