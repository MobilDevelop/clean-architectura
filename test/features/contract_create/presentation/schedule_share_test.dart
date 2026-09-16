import 'dart:io';

import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/payment_schedule_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/payment_schedule_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/payment_schedule/payment_schedule_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements PaymentScheduleRepository {
  Result<PaymentSchedule> result = const Ok<PaymentSchedule>(PaymentSchedule(<ScheduleRow>[]));

  @override
  Future<Result<PaymentSchedule>> getSchedule(ScheduleQuery query) async => result;
}

const ScheduleQuery _query = ScheduleQuery(
  contractId: 36555548,
  termMonths: 6,
  paymentDay: 15,
  isInformal: false,
);

PaymentSchedule _schedule(int count) => PaymentSchedule(<ScheduleRow>[
  for (int i = 1; i <= count; i++)
    ScheduleRow(number: i, date: DateTime(2026, i, 15), amount: 1500000),
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late _FakeRepository repository;

  PaymentScheduleBloc build() => PaymentScheduleBloc(
    query: _query,
    clientName: 'Abdurahmonov Abdulaziz',
    getSchedule: GetScheduleUsecase(repository),
    now: () => DateTime(2026, 9, 16),
  );

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 400));

  setUp(() {
    repository = _FakeRepository();
    temp = Directory.systemTemp.createTempSync('schedule_pdf');

    // `path_provider` da test uchun tayyor amalga oshirish yo'q — vaqtinchalik
    // papkani o'zimiz beramiz.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async => call.method == 'getTemporaryDirectory' ? temp.path : null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    temp.deleteSync(recursive: true);
  });

  test('jadval PDF faylga aylanadi', () async {
    repository.result = Ok<PaymentSchedule>(_schedule(6));

    final PaymentScheduleBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const ScheduleRequested())
      ..add(const ScheduleShareRequested());
    await settle();

    final File? file = bloc.state.shareFile;

    expect(file, isNotNull);
    expect(file!.existsSync(), isTrue);
    expect(bloc.state.isSharing, isFalse);
    expect(bloc.state.failure, isNull);

    // PDF ekani va bo'sh emasligi: shrift nomi adashsa yoki jadval
    // qurilmasa shu yerda ko'rinadi.
    final List<int> bytes = file.readAsBytesSync();

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    // Bo'sh hujjat ~1 KB. Shrift va jadval joylangani shundan ko'rinadi.
    expect(bytes.length, greaterThan(4000));
  });

  /// Ulashilgandan keyin fayl holatdan olinadi, aks holda ekran qayta
  /// qurilganda oyna ikkinchi marta ochilardi.
  test('ulashilgach fayl holatdan olinadi', () async {
    repository.result = Ok<PaymentSchedule>(_schedule(3));

    final PaymentScheduleBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const ScheduleRequested())
      ..add(const ScheduleShareRequested());
    await settle();

    expect(bloc.state.shareFile, isNotNull);

    bloc.add(const ScheduleFileShared());
    await settle();

    expect(bloc.state.shareFile, isNull);
  });

  test('bo‘sh jadval ulashilmaydi', () async {
    final PaymentScheduleBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const ScheduleRequested())
      ..add(const ScheduleShareRequested());
    await settle();

    expect(bloc.state.canShare, isFalse);
    expect(bloc.state.shareFile, isNull);
    expect(bloc.state.isSharing, isFalse);
  });
}
