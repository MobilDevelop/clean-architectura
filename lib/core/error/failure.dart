enum FailureGroup { session, connection, input, internal }

sealed class Failure {
  const Failure(this.message);

  final String message;

  FailureGroup get group => switch (this) {
    UnauthorizedFailure() => FailureGroup.session,
    NetworkFailure() || TimeoutFailure() => FailureGroup.connection,
    ClientFailure() => FailureGroup.input,
    ServerFailure() || ParseFailure() || UnknownFailure() => FailureGroup.internal,
  };
  bool get isReportable => switch (this) {
    ParseFailure() || UnknownFailure() || ServerFailure() => true,
    NetworkFailure() || TimeoutFailure() || UnauthorizedFailure() || ClientFailure() => false,
  };
}

/// Internet yo'q, DNS topilmadi, ulanish uzildi
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// So'rov vaqti tugadi
final class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

/// Token yaroqsiz yoki muddati tugagan (401)
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Backend biznes qoidasini buzganimizni aytdi (401 dan boshqa 4xx)
final class ClientFailure extends Failure {
  const ClientFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Server yiqildi (5xx)
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Javob kutilgan shaklda emas — bu bizning xatomiz, backendniki emas
final class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

/// Boshqa hech qaysi toifaga tushmadi
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}