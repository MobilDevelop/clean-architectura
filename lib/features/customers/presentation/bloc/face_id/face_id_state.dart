part of 'face_id_bloc.dart';

final class FaceIdState extends Equatable {
  const FaceIdState({
    required this.form,
    required this.issue,
    required this.isLoading,
    required this.cameraOpen,
    required this.isOfferAccepted,
    this.image,
    this.failure,
    this.customerInfo,
  });

  const FaceIdState.initial()
    : form = const FaceCheckForm(),
      issue = FaceCheckIssue.none,
      isLoading = false,
      cameraOpen = false,
      isOfferAccepted = false,
      image = null,
      failure = null,
      customerInfo = null;

  final FaceCheckForm form;
  final FaceCheckIssue issue;
  final bool isLoading;

  /// Kamera ochilishi kerakligi. Bloc navigatsiya qilmaydi (6.2) — sahifa shu
  /// maydonni kuzatadi.
  final bool cameraOpen;

  /// Ommaviy oferta tasdiqlangani. Tasdiqlanmaguncha rasm olinmaydi.
  final bool isOfferAccepted;

  /// Oxirgi olingan rasm — aloqa uzilganda "Qayta urinish" shuni qayta yuboradi.
  final File? image;

  final Failure? failure;
  final CustomerInfo? customerInfo;

  FaceIdState copyWith({
    FaceCheckForm? form,
    FaceCheckIssue? issue,
    bool? isLoading,
    bool? cameraOpen,
    bool? isOfferAccepted,
    File? image,
    Failure? failure,
    CustomerInfo? customerInfo,
    bool clearFailure = false,
    bool clearCustomer = false,
  }) => FaceIdState(
    form: form ?? this.form,
    issue: issue ?? this.issue,
    isLoading: isLoading ?? this.isLoading,
    cameraOpen: cameraOpen ?? this.cameraOpen,
    isOfferAccepted: isOfferAccepted ?? this.isOfferAccepted,
    image: image ?? this.image,
    failure: clearFailure ? null : failure ?? this.failure,
    customerInfo: clearCustomer ? null : customerInfo ?? this.customerInfo,
  );

  @override
  List<Object?> get props => [form, issue, isLoading, cameraOpen, isOfferAccepted, image?.path, failure, customerInfo];
}
