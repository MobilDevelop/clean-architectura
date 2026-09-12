part of 'product_picker_bloc.dart';

final class ProductPickerState extends Equatable {
  const ProductPickerState({
    required this.draft,
    required this.issue,
    required this.isReady,
    required this.isScanning,
    required this.cameraIssue,
    this.failure,
  });

  const ProductPickerState.initial()
    : draft = const ProductDraft(),
      issue = ProductDraftIssue.none,
      isReady = false,
      isScanning = false,
      cameraIssue = CameraIssue.none,
      failure = null;

  final ProductDraft draft;
  final ProductDraftIssue issue;

  /// Forma to'liq — sahifa natijani qaytaradi.
  final bool isReady;

  /// Rasmdan IMEI o'qilyapti.
  final bool isScanning;

  /// Kamera ochilmagan bo'lsa — sababi. Server xatosi emas, shuning uchun
  /// `failure` dan alohida maydonda va alohida joyda ko'rsatiladi (7.5).
  final CameraIssue cameraIssue;

  final Failure? failure;

  ProductPickerState copyWith({
    ProductDraft? draft,
    ProductDraftIssue? issue,
    bool? isReady,
    bool? isScanning,
    CameraIssue? cameraIssue,
    Failure? failure,
    bool clearFailure = false,
  }) => ProductPickerState(
    draft: draft ?? this.draft,
    issue: issue ?? this.issue,
    isReady: isReady ?? this.isReady,
    isScanning: isScanning ?? this.isScanning,
    cameraIssue: cameraIssue ?? this.cameraIssue,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [draft, issue, isReady, isScanning, cameraIssue, failure];
}
