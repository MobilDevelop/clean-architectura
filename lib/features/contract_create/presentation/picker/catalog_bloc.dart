import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

/// Bitta ma'lumotnoma ro'yxati: yetkazib beruvchi, toifa, brend yoki tovar.
///
/// Nega umumiy: to'rttasi ham bir xil ishlaydi — qidiruv, sahifalash, xato.
/// Farqi faqat qaysi so'rov yuborilishida, u [_load] orqali beriladi.
final class CatalogBloc<T> extends Bloc<CatalogEvent, CatalogState<T>> {
  CatalogBloc({required this._load}) : super(CatalogState<T>.initial()) {
    // Qidiruvda oldingi so'rov bekor qilinadi, sahifada esa navbat saqlanadi.
    on<CatalogSearched>(_searched, transformer: restartable());
    on<CatalogNextPage>(_nextPage, transformer: droppable());
  }

  final Future<Result<Paged<T>>> Function(CatalogQuery) _load;

  static const Duration _typingPause = Duration(milliseconds: 350);

  Future<void> _searched(CatalogSearched event, Emitter<CatalogState<T>> emit) async {
    // Birinchi yuklashda kutilmaydi, yozganda kutiladi.
    if (event.debounce) {
      await Future<void>.delayed(_typingPause);
      if (emit.isDone) return;
    }

    emit(
      state.copyWith(
        search: event.query,
        isLoading: true,
        items: const <Never>[],
        page: 1,
        clearFailure: true,
      ),
    );

    await _fetch(CatalogQuery(search: event.query, page: 1), emit, reset: true);
  }

  Future<void> _nextPage(CatalogNextPage event, Emitter<CatalogState<T>> emit) async {
    if (state.isLast || state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearFailure: true));

    await _fetch(CatalogQuery(search: state.search, page: state.page + 1), emit, reset: false);
  }

  Future<void> _fetch(CatalogQuery query, Emitter<CatalogState<T>> emit, {required bool reset}) async {
    final Result<Paged<T>> result = await _load(query);
    if (emit.isDone) return;

    switch (result) {
      case Ok(:final Paged<T> value):
        emit(
          state.copyWith(
            isLoading: false,
            isLast: value.isLast,
            page: query.page,
            items: reset ? value.items : <T>[...state.items, ...value.items],
          ),
        );
      case Err(:final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }
}
