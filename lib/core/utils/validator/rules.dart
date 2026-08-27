typedef Rule = String? Function(String value);

Rule notEmpty(String message) => (value) => value.trim().isEmpty ? message : null;
Rule minLength(int length, String message) => (value) => value.trim().length < length ? message : null;

String? firstError(String value, List<Rule> rules) {
  for (final rule in rules) {
    final error = rule(value);
    if (error != null) return error;
  }
  return null;
}