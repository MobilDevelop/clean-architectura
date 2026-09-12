import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_file_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/download_contract_file_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/contract_details/contract_details_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_repository.dart';

/// Shartnoma faylini ulashish.
///
/// Ulashish oynasi UI ta'siri, shuning uchun bloc uni ochmaydi (6.2): u faqat
/// faylni tayyorlaydi va holatga qo'yadi, oynani sahifa ochadi va darhol
/// `FileShared` bilan tozalaydi — aks holda ekran qayta qurilganda oyna
/// ikkinchi marta ochilardi.
final class _FakeFileRepository implements ContractFileRepository {
  int calls = 0;
  String? lastUrl;
  Result<File> result = Ok<File>(File('shartnoma.pdf'));

  @override
  Future<Result<File>> download(String url) async {
    calls++;
    lastUrl = url;

    return result;
  }
}

ContractDetails _details({String fileUrl = 'https://s3/shartnoma_55.pdf?sig=1'}) => ContractDetails(
  id: 55,
  statusCode: 11,
  clientName: 'Aliyev Vali',
  termMonths: 12,
  paymentDay: 15,
  isFormal: true,
  hasCarIncome: false,
  fileUrl: fileUrl,
  products: const <ContractProduct>[],
  guarantors: const <ContractGuarantor>[],
  card: const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
  tariff: const AppliedTariff(id: 0, name: '', isActive: false),
  benefit: null,
  mibFailReason: '',
  katmFailReason: '',
  workplaceCategoryId: 0,
);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  late FakeContractCreateRepository repo;
  late _FakeFileRepository files;

  ContractDetailsBloc build() => ContractDetailsBloc(
    contractId: 55,
    getDetails: GetContractDetailsUsecase(repo),
    downloadFile: DownloadContractFileUsecase(files),
  );

  setUp(() {
    repo = FakeContractCreateRepository();
    files = _FakeFileRepository();
  });

  test('fayl yuklab olinadi va ulashishga tayyorlanadi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());

    final ContractDetailsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const DetailsRequested());
    await _settle();

    bloc.add(const FileShareRequested());
    await _settle();

    expect(files.lastUrl, 'https://s3/shartnoma_55.pdf?sig=1');
    expect(bloc.state.shareFile, isNotNull);
    expect(bloc.state.isFileLoading, isFalse);
  });

  test('ulashilgach fayl holatdan tozalanadi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());

    final ContractDetailsBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const DetailsRequested())
      ..add(const FileShareRequested());
    await _settle();

    bloc.add(const FileShared());
    await _settle();

    expect(bloc.state.shareFile, isNull);
  });

  // Havolasiz shartnomada tugma umuman chizilmaydi, lekin qoida bloc'da ham
  // turishi kerak: ikkinchi kirish yo'li paydo bo'lsa bo'sh havola ketmasin.
  test('havola bo‘sh bo‘lsa so‘rov ketmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details(fileUrl: ''));

    final ContractDetailsBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const DetailsRequested())
      ..add(const FileShareRequested());
    await _settle();

    expect(files.calls, 0);
    expect(bloc.state.shareFile, isNull);
  });

  test('yuklash yiqilsa xato ko‘rinadi, fayl qo‘yilmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());
    files.result = const Err<File>(NetworkFailure('aloqa yo‘q'));

    final ContractDetailsBloc bloc = build();
    addTearDown(bloc.close);

    bloc
      ..add(const DetailsRequested())
      ..add(const FileShareRequested());
    await _settle();

    expect(bloc.state.shareFile, isNull);
    expect(bloc.state.failure, isA<NetworkFailure>());
    expect(bloc.state.isFileLoading, isFalse);
  });
}
