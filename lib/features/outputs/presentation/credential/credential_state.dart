part of 'credential_bloc.dart';

final class CredentialState extends Equatable {
  const CredentialState({
    required this.device,
    required this.clientName,
    required this.credential,
    required this.issue,
    required this.isSaving,
    required this.isSaved,
    this.failure,
  });

  CredentialState.initial({
    required this.device,
    required this.clientName,
    required int contractId,
  }) : credential = IcloudCredential(
         contractId: contractId,
         contractProductId: device.contractProductId,
         // Serverdagi raqamlar formaga tayyor holda tushadi: ular yorliqdan
         // o'qilgan va qo'lda qayta yozilmaydi.
         imei: device.imei,
         imei2: device.imei2,
       ),
       issue = IcloudIssue.none,
       isSaving = false,
       isSaved = false,
       failure = null;

  final IcloudDevice device;

  /// Qurilma qaysi mijozniki — forma tepasida ko'rinadi.
  final String clientName;

  final IcloudCredential credential;

  /// Faqat saqlashga urinilgandan keyin to'ldiriladi (7.5).
  final IcloudIssue issue;

  final bool isSaving;
  final bool isSaved;
  final Failure? failure;

  CredentialState copyWith({
    IcloudCredential? credential,
    IcloudIssue? issue,
    bool? isSaving,
    bool? isSaved,
    Failure? failure,
    bool clearFailure = false,
  }) => CredentialState(
    device: device,
    clientName: clientName,
    credential: credential ?? this.credential,
    issue: issue ?? this.issue,
    isSaving: isSaving ?? this.isSaving,
    isSaved: isSaved ?? this.isSaved,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[device, clientName, credential, issue, isSaving, isSaved, failure];
}
