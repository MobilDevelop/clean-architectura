import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/domain/usecase/underwriter_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'underwriter_event.dart';
part 'underwriter_state.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { load, references, models, submit }

/// Anderrayter: daromadni tasdiqlovchi hujjatlar.
///
/// Beshala bo'lim bitta yozuvda emas, har biri o'z server yozuvi. Shuning
/// uchun saqlash ham bo'lim bo'yicha ketadi va har biri o'z `editId` siga ega.
final class UnderwriterBloc extends Bloc<UnderwriterEvent, UnderwriterState> {
  UnderwriterBloc({
    required UnderwriterArgs args,
    required this._load,
    required this._getReferences,
    required this._getModels,
    required this._upload,
    required this._save,
    required this._today,
  }) : super(UnderwriterState.initial(args)) {
    on<UnderwriterRequested>(_requested, transformer: droppable());
    on<SectionSelected>(_sectionSelected);
    on<FileAdded>(_fileAdded);
    on<FileRemoved>(_fileRemoved);
    on<SalaryAmountChanged>(_salaryChanged);
    on<PensionAmountChanged>(_pensionChanged);
    on<PositionSelected>(_positionSelected);
    on<CarBrandSelected>(_brandSelected, transformer: restartable());
    on<CarModelSelected>(_modelSelected);
    on<CarYearSelected>(_yearSelected);
    on<SectionSubmitted>(_submitted, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final LoadUnderwriterUsecase _load;
  final LoadReferencesUsecase _getReferences;
  final GetCarModelsUsecase _getModels;
  final UploadDocumentUsecase _upload;
  final SaveUnderwriterUsecase _save;

  /// Bugungi sana tashqaridan: ish haqi oylari va avtomobil yillari shunga
  /// bog'liq, va test bugun o'tib ertaga yiqilmasligi kerak (9.4).
  final DateTime Function() _today;

  /// Oxirgi muvaffaqiyatsiz amal. «Qayta urinish» aynan shuni takrorlaydi —
  /// aks holda ma'lumotnoma xatosidan keyin tugma serverga **yozib**
  /// yuborardi (foydalanuvchi so'ramagan `POST`).
  _Attempt _attempt = _Attempt.load;

  /// `_fetchModels` uchun: qaysi brendning markalari so'ralgan edi.
  int _modelsBrandId = 0;

  Future<void> _requested(UnderwriterRequested event, Emitter<UnderwriterState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<UnderwriterData> loaded = await _load(state.args.contractId);
    if (emit.isDone) return;

    switch (loaded) {
      case Ok(: final UnderwriterData value):
        emit(state.copyWith(data: value.withForm(value.salary.ensureRows(_today()))));
      // Yuklash yiqilsa saqlashga ruxsat berilmaydi: `editId` nolda qolib,
      // mavjud yozuv ustidan ikkinchisi yaratilib ketardi.
      case Err(: final Failure failure):
        _attempt = _Attempt.load;
        emit(state.copyWith(isLoading: false, failure: failure));
        return;
    }

    await _loadReferences(emit);
    if (emit.isDone) return;

    emit(state.copyWith(isLoading: false));
  }

  /// Ma'lumotnomalar. Ketma-ketlik usecase ichida (3.8).
  Future<void> _loadReferences(Emitter<UnderwriterState> emit) async {
    final Result<UnderwriterReferences> result = await _getReferences(
      ReferencesQuery(
        needsPositions: state.sections.contains(UnderwriterKind.military),
        brandId: state.data?.car.brand.id ?? 0,
      ),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final UnderwriterReferences value):
        emit(state.copyWith(positions: value.positions, brands: value.brands, models: value.models));
      case Err(: final Failure failure):
        _attempt = _Attempt.references;
        emit(state.copyWith(failure: failure));
    }
  }

  Future<void> _fetchModels(int brandId, Emitter<UnderwriterState> emit) async {
    _modelsBrandId = brandId;
    emit(state.copyWith(isModelsLoading: true));

    final Result<List<UnderwriterOption>> result = await _getModels(brandId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<UnderwriterOption> value):
        emit(state.copyWith(isModelsLoading: false, models: value));
      case Err(: final Failure failure):
        _attempt = _Attempt.models;
        emit(state.copyWith(isModelsLoading: false, failure: failure));
    }
  }

  void _sectionSelected(SectionSelected event, Emitter<UnderwriterState> emit) =>
      emit(state.copyWith(current: event.kind, issue: UnderwriterIssue.none, fileIssue: FileIssue.none));

  void _fileAdded(FileAdded event, Emitter<UnderwriterState> emit) {
    final UnderwriterForm? form = state.form;
    if (form == null) return;

    final FileIssue issue = UnderwriterFileRule.check(
      count: form.files.length,
      bytes: event.bytes,
      extension: event.extension,
    );

    if (issue != FileIssue.none) {
      emit(state.copyWith(fileIssue: issue));
      return;
    }

    _replace(
      emit,
      form.withFiles(<UnderwriterFile>[
        ...form.files,
        UnderwriterFile(key: '', name: event.file.uri.pathSegments.last, local: event.file),
      ]),
      fileIssue: FileIssue.none,
    );
  }

  /// Serverda o'chirish so'rovi yo'q: hujjat ro'yxatdan chiqadi va keyingi
  /// saqlashda `file_urls` dan ham tushib qoladi.
  void _fileRemoved(FileRemoved event, Emitter<UnderwriterState> emit) {
    final UnderwriterForm? form = state.form;
    if (form == null || event.index >= form.files.length) return;

    _replace(
      emit,
      form.withFiles(<UnderwriterFile>[...form.files]..removeAt(event.index)),
      fileIssue: FileIssue.none,
    );
  }

  void _salaryChanged(SalaryAmountChanged event, Emitter<UnderwriterState> emit) =>
      _edit(emit, (UnderwriterData d) => d.salary.withRow(event.index, event.amount));

  void _pensionChanged(PensionAmountChanged event, Emitter<UnderwriterState> emit) =>
      _edit(emit, (UnderwriterData d) => d.pension.copyWith(amount: event.amount));

  void _positionSelected(PositionSelected event, Emitter<UnderwriterState> emit) =>
      _edit(emit, (UnderwriterData d) => d.military.copyWith(position: event.position));

  Future<void> _brandSelected(CarBrandSelected event, Emitter<UnderwriterState> emit) async {
    // Brend o'zgarsa marka bekor qilinadi — u eski brendga tegishli edi.
    _edit(emit, (UnderwriterData d) => d.car.withBrand(event.brand), models: const <UnderwriterOption>[]);

    await _fetchModels(event.brand.id, emit);
  }

  void _modelSelected(CarModelSelected event, Emitter<UnderwriterState> emit) =>
      _edit(emit, (UnderwriterData d) => d.car.copyWith(model: event.model));

  void _yearSelected(CarYearSelected event, Emitter<UnderwriterState> emit) =>
      _edit(emit, (UnderwriterData d) => d.car.copyWith(year: event.year));

  /// Bo'limni saqlaydi: avval yuklanmagan hujjatlar, keyin yozuvning o'zi.
  Future<void> _submitted(SectionSubmitted event, Emitter<UnderwriterState> emit) async {
    final UnderwriterData? data = state.data;
    final UnderwriterForm? form = state.form;

    if (data == null || form == null || state.isBusy) return;

    final UnderwriterIssue issue = form.issue;
    if (issue != UnderwriterIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    emit(state.copyWith(write: UnderwriterWrite.uploading, issue: UnderwriterIssue.none, clearFailure: true));

    final List<UnderwriterFile> uploaded = <UnderwriterFile>[];

    for (int i = 0; i < form.files.length; i++) {
      final UnderwriterFile file = form.files[i];

      if (file.isUploaded) {
        uploaded.add(file);
        continue;
      }

      // Na kaliti, na mahalliy fayli bor — bu holat yuz bermaydi, lekin
      // qatorni tashlab yuborish indekslarni siljitardi.
      final File? local = file.local;
      if (local == null) {
        uploaded.add(file);
        continue;
      }

      final Result<String> result = await _upload(local);
      if (emit.isDone) return;

      switch (result) {
        case Ok(: final String value):
          uploaded.add(file.withKey(value));
        // Yuklangan kalitlar saqlanadi, **yiqilgani esa ro'yxatda qoladi** —
        // «Qayta urinish» aynan shu fayldan davom etadi. Uni tashlab yuborish
        // foydalanuvchining hujjatini jimgina yo'q qilardi (5.8).
        case Err(: final Failure failure):
          _attempt = _Attempt.submit;
          _replace(emit, form.withFiles(<UnderwriterFile>[...uploaded, ...form.files.skip(i)]));
          emit(state.copyWith(write: UnderwriterWrite.none, failure: failure));
          return;
      }
    }

    _replace(emit, form.withFiles(uploaded), write: UnderwriterWrite.saving);

    final UnderwriterForm ready = state.form ?? form;
    final Result<SaveOutcome> saved = await _save(
      SaveUnderwriterParams(args: state.args, form: ready),
    );
    if (emit.isDone) return;

    switch (saved) {
      case Ok(: final SaveOutcome value):
        final UnderwriterData? data = value.data;
        UnderwriterData? refreshed;

        if (data != null) refreshed = data.withForm(data.salary.ensureRows(_today()));

        // Yozuv serverda bor. Qayta o'qish yiqilgan bo'lsa ham takroriy
        // `POST` yuborilmaydi — «Qayta urinish» endi o'qishni takrorlaydi.
        // `data: null` eskisini o'chirmaydi (`copyWith` da `??`), ya'ni ekran
        // avvalgi holatida qoladi.
        _attempt = _Attempt.load;

        emit(
          state.copyWith(
            write: UnderwriterWrite.none,
            data: refreshed,
            savedCount: state.savedCount + 1,
            failure: value.reloadFailure,
            clearFailure: value.reloadFailure == null,
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.submit;
        emit(state.copyWith(write: UnderwriterWrite.none, failure: failure));
    }
  }

  /// Ochiq bo'limni tahrirlaydi.
  ///
  /// Beshta handler bir xil `null` tekshiruvini takrorlamasligi uchun.
  void _edit(
    Emitter<UnderwriterState> emit,
    UnderwriterForm Function(UnderwriterData data) build, {
    List<UnderwriterOption>? models,
  }) {
    final UnderwriterData? data = state.data;
    if (data == null) return;

    _replace(emit, build(data), models: models);
  }

  /// Bo'limni state'ga qaytaradi.
  void _replace(
    Emitter<UnderwriterState> emit,
    UnderwriterForm form, {
    UnderwriterWrite? write,
    FileIssue? fileIssue,
    List<UnderwriterOption>? models,
  }) {
    final UnderwriterData? data = state.data;
    if (data == null) return;

    emit(
      state.copyWith(
        data: data.withForm(form),
        write: write,
        fileIssue: fileIssue,
        models: models,
        issue: UnderwriterIssue.none,
      ),
    );
  }

  void _failureHandled(FailureHandled event, Emitter<UnderwriterState> emit) =>
      emit(state.copyWith(clearFailure: true));

  /// Aynan yiqilgan amalni takrorlaydi.
  ///
  /// Ilgari u faqat `isReady` ga qarardi: ma'lumotnoma yoki qayta o'qish
  /// yiqilganda `data` bor bo'lgani uchun tugma **saqlashni** bajarardi —
  /// foydalanuvchi so'ramagan yozuv ketardi, ro'yxat esa bo'sh qolaverardi.
  Future<void> _retried(Retried event, Emitter<UnderwriterState> emit) async {
    emit(state.copyWith(clearFailure: true));

    if (!state.isReady) {
      add(const UnderwriterRequested());
      return;
    }

    switch (_attempt) {
      case _Attempt.load:
        add(const UnderwriterRequested());
      case _Attempt.references:
        await _loadReferences(emit);
      case _Attempt.models:
        await _fetchModels(_modelsBrandId, emit);
      case _Attempt.submit:
        add(const SectionSubmitted());
    }
  }
}
