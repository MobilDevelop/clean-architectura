import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:dio/dio.dart';

final class ErrorReportInterceptor extends Interceptor {
  const ErrorReportInterceptor(this._reporter);

  final ErrorReporter _reporter;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Failure failure = ErrorMapper.fromDio(err);

    if (failure.isReportable) {
      _reporter.report(ErrorReport(source: err.requestOptions.path, message: '${err.response?.statusCode ?? "-"} · ${failure.message}'));
    }

    handler.next(err);
  }
}
