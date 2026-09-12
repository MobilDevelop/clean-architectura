import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/check_client_usecase.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Yuz tekshiruvi ketayotganda ekran boshqa amalni qabul qilmaydi.
///
/// Nima bo'lgan edi: yuklanish paytida ofertani qayta ochish mumkin edi.
/// Javob kelganda sahifaning `context.pop(...)` i eng ustdagi marshrutni —
/// ya'ni **ochiq turgan oferta oynasini** — yopardi. Tasdiqlangan mijoz shu
/// bilan yo'qolib ketardi va oqim to'xtab qolardi.
final class _SlowRepository implements CustomerRepository {
  final Completer<void> gate = Completer<void>();
  int checks = 0;

  @override
  Future<Result<CustomerInfo>> checkClient(FaceCheckParams params) async {
    checks++;
    await gate.future;

    return Ok<CustomerInfo>(_customer);
  }

  @override
  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams search) async =>
      const Ok<List<CustomerInfo>>(<CustomerInfo>[]);
  @override
  Future<Result<void>> updateCustomer(CustomerUpdateParams params) async => const Ok<void>(null);
  @override
  Future<Result<ScoringInfo>> getScoring(int customerId) async => Err<ScoringInfo>(const UnknownFailure('test'));
}

const CustomerInfo _customer = CustomerInfo(
  id: 1,
  fullName: 'Aliyev Vali',
  inps: '31201000560012',
  passportNumber: 'AB1234567',
  birthDay: '12.03.1990',
  mainAddress: '',
  phones: <PhoneNumber>[],
  passportGiven: '',
  passportExpire: '',
  workplace: WorkplaceInfo(id: 0, name: '', category: WorkplaceCategory(id: 0, name: '')),
  province: Province(id: 0, title: ''),
  region: Region(id: 0, title: ''),
  village: Village(id: 0, title: ''),
  houseNumber: '',
  street: '',
  passportType: true,
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _SlowRepository repo;

  FaceIdBloc build() => FaceIdBloc(
    checkClientUsecase: CheckClientUsecase(repo),
    now: () => DateTime(2026, 9, 9),
  );

  setUp(() => repo = _SlowRepository());

  Future<FaceIdBloc> busy() async {
    final FaceIdBloc bloc = build();

    bloc
      ..add(const OfferAccepted(true))
      ..add(PhotoCaptured(File('face.jpg')));
    await _settle();

    expect(bloc.state.isLoading, isTrue);

    return bloc;
  }

  test('tekshiruv ketayotganda oferta holati o‘zgarmaydi', () async {
    final FaceIdBloc bloc = await busy();
    addTearDown(bloc.close);

    bloc.add(const OfferAccepted(false));
    await _settle();

    expect(bloc.state.isOfferAccepted, isTrue);

    repo.gate.complete();
    await _settle();

    expect(bloc.state.customerInfo, isNotNull);
  });

  test('tekshiruv ketayotganda ikkinchi kamera ochilmaydi', () async {
    final FaceIdBloc bloc = await busy();
    addTearDown(bloc.close);

    bloc.add(const CaptureRequested());
    await _settle();

    expect(bloc.state.cameraOpen, isFalse);
  });

  // Ikkinchi surat birinchisining ustidan tushmasin: `droppable` bo'lmasa
  // ikkita so'rov ketib, javoblar tartibi tasodifiy bo'lardi.
  test('ikkinchi surat so‘rovi tashlanadi', () async {
    final FaceIdBloc bloc = await busy();
    addTearDown(bloc.close);

    bloc.add(PhotoCaptured(File('face2.jpg')));
    await _settle();

    expect(repo.checks, 1);

    repo.gate.complete();
    await _settle();
  });
}
