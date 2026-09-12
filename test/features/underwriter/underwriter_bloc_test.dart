import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/domain/usecase/underwriter_usecases.dart';
import 'package:colloborator_v3/features/underwriter/presentation/bloc/underwriter/underwriter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_underwriter_repository.dart';

const UnderwriterArgs _args = UnderwriterArgs(
  contractId: 5,
  clientId: 42,
  workplaceCategoryId: 1,
  isFormal: true,
  hasCard: false,
);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

void main() {
  late FakeUnderwriterRepository repo;

  UnderwriterBloc build() => UnderwriterBloc(
    args: _args,
    load: LoadUnderwriterUsecase(repo),
    getReferences: LoadReferencesUsecase(repo),
    getModels: GetCarModelsUsecase(repo),
    upload: UploadDocumentUsecase(repo),
    save: SaveUnderwriterUsecase(repo),
    today: () => DateTime(2026, 9, 8),
  );

  setUp(() => repo = FakeUnderwriterRepository());

  test('yuklashda yiqilgan hujjat ro‘yxatda qoladi', () async {
    repo
      ..loadResult = Ok<UnderwriterData>(
        emptyData(
          salaryFiles: <UnderwriterFile>[
            UnderwriterFile(key: '', name: 'sprav.pdf', local: File('sprav.pdf')),
          ],
        ),
      )
      ..uploadResult = const Err<String>(NetworkFailure('aloqa yo`q'));

    final UnderwriterBloc bloc = build()..add(const UnderwriterRequested());
    await _settle();

    bloc.add(const SectionSubmitted());
    await _settle();

    expect(bloc.state.failure, isA<NetworkFailure>());
    expect(bloc.state.form?.files.length, 1, reason: 'hujjat jimgina yo‘qolmasligi kerak');
    expect(repo.saveCalls, 0);

    await bloc.close();
  });

  test('«Qayta urinish» yiqilgan yuklashni takrorlaydi, saqlashni emas', () async {
    repo
      ..loadResult = Ok<UnderwriterData>(
        emptyData(
          salaryFiles: <UnderwriterFile>[
            UnderwriterFile(key: '', name: 'sprav.pdf', local: File('sprav.pdf')),
          ],
        ),
      )
      ..uploadResult = const Err<String>(NetworkFailure('aloqa yo`q'));

    final UnderwriterBloc bloc = build()..add(const UnderwriterRequested());
    await _settle();

    bloc.add(const SectionSubmitted());
    await _settle();

    repo.uploadResult = const Ok<String>('s3/kalit.pdf');
    bloc.add(const Retried());
    await _settle();

    expect(repo.uploadCalls, 2);
    expect(repo.saveCalls, 1);

    await bloc.close();
  });

  test('ma‘lumotnoma yiqilsa «Qayta urinish» serverga yozmaydi', () async {
    repo.brandsResult = const Err<List<UnderwriterOption>>(NetworkFailure('aloqa yo`q'));

    final UnderwriterBloc bloc = build()..add(const UnderwriterRequested());
    await _settle();

    expect(bloc.state.isReady, isTrue);
    expect(bloc.state.failure, isA<NetworkFailure>());

    repo.brandsResult = const Ok<List<UnderwriterOption>>(<UnderwriterOption>[
      UnderwriterOption(id: 1, name: 'Chevrolet'),
    ]);
    bloc.add(const Retried());
    await _settle();

    expect(repo.saveCalls, 0, reason: 'so‘ralmagan POST ketmasligi kerak');
    expect(repo.brandCalls, 2);
    expect(bloc.state.brands.length, 1);

    await bloc.close();
  });

  test('saqlandi, lekin qayta o‘qish yiqildi — ikkinchi POST ketmaydi', () async {
    final UnderwriterBloc bloc = build()..add(const UnderwriterRequested());
    await _settle();

    repo
      ..loadResult = const Err<UnderwriterData>(NetworkFailure('aloqa yo`q'))
      ..uploadResult = const Ok<String>('s3/kalit.pdf');

    bloc.add(FileAdded(file: File('a.pdf'), bytes: 1000, extension: 'pdf'));
    await _settle();
    bloc.add(const SectionSubmitted());
    await _settle();

    expect(repo.saveCalls, 1);
    expect(bloc.state.savedCount, 1, reason: 'yozuv serverda bor');
    expect(bloc.state.failure, isA<NetworkFailure>());

    bloc.add(const Retried());
    await _settle();

    expect(repo.saveCalls, 1, reason: 'takroriy POST serverda ikkinchi yozuv qoldirardi');
    expect(repo.loadCalls, 3);

    await bloc.close();
  });
}
