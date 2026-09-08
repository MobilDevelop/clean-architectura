part of 'product_picker_bloc.dart';

final class ProductPickerState extends Equatable {
  const ProductPickerState({required this.draft, required this.issue, required this.isReady});

  const ProductPickerState.initial()
    : draft = const ProductDraft(),
      issue = ProductDraftIssue.none,
      isReady = false;

  final ProductDraft draft;
  final ProductDraftIssue issue;

  /// Forma to'liq — sahifa natijani qaytaradi.
  final bool isReady;

  ProductPickerState copyWith({ProductDraft? draft, ProductDraftIssue? issue, bool? isReady}) => ProductPickerState(
    draft: draft ?? this.draft,
    issue: issue ?? this.issue,
    isReady: isReady ?? this.isReady,
  );

  @override
  List<Object?> get props => [draft, issue, isReady];
}
