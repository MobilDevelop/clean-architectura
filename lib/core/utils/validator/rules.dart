typedef Rule<T> = T? Function(String value);

Rule<T> notEmpty<T>(T issue) => (value) => value.trim().isEmpty ? issue : null;

T? firstError<T>(String value, List<Rule<T>> rules) {
  for (final rule in rules) {
    final issue = rule(value);
    if (issue != null) return issue;
  }
  return null;
}