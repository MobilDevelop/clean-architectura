final class ErrorReport {
  const ErrorReport({required this.source, required this.message, this.trace});

  final String source;
  final String message;
  final StackTrace? trace;

  /// Takrorlarni filtrlash uchun kalit.
  String get signature => '$source|$message';
}

abstract interface class ErrorReporter {
  void report(ErrorReport report);
}