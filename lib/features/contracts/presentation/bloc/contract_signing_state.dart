import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:equatable/equatable.dart';

/// Ayni paytda ketayotgan yozuv. Bittadan ortiq bo'lmaydi: ekranda bir vaqtda
/// bitta ishtirokchi bilan ishlanadi.
enum SigningWrite { none, face, signature }

final class ContractSigningState extends Equatable {
  const ContractSigningState({
    required this.signing,
    required this.contractFile,
    required this.isFileLoading,
    required this.isRead,
    required this.expandedId,
    required this.write,
    required this.busyParticipantId,
    required this.isFinished,
    this.failure,
  });

  ContractSigningState.initial(this.signing)
    : contractFile = '',
      isFileLoading = false,
      isRead = false,
      expandedId = signing.participants.isEmpty ? 0 : signing.participants.first.id,
      write = SigningWrite.none,
      busyParticipantId = 0,
      isFinished = false,
      failure = null;

  final ContractSigning signing;

  /// Shartnoma matni (HTML). Bo'sh — hali o'qilmagan.
  final String contractFile;
  final bool isFileLoading;

  /// Matn oxirigacha o'qildi.
  final bool isRead;

  /// Ochiq turgan ishtirokchi. `0` — hammasi yopiq.
  final int expandedId;

  final SigningWrite write;

  /// Qaysi ishtirokchi uchun yozuv ketyapti. `0` — yozuv yo'q.
  final int busyParticipantId;

  /// Shartnoma to'liq imzolandi — sahifa yopiladi.
  final bool isFinished;

  final Failure? failure;

  bool get isBusy => write != SigningWrite.none;

  bool get hasFile => contractFile.isNotEmpty;

  /// Imzo qabul qilinishi uchun shartnoma matni o'qilgan bo'lishi kerak.
  ///
  /// Nega barcha ishtirokchiga birdek: matn bitta, uni bir marta o'qish
  /// yetarli. Flex ham shunday.
  /// Yuzni tasdiqlash uchun shartnoma matni o'qilgan bo'lishi kerak.
  ///
  /// Nega aynan shu qadam: yuz so'rovi bilan birga `accepted_oferta: true`
  /// ketadi, ya'ni rozilik aynan shu yerda beriladi. Matn bitta va u hamma
  /// ishtirokchi uchun bir marta o'qiladi.
  bool canConfirmFace(SigningParticipant participant) =>
      isRead && !participant.isFaceChecked && !isBusy;

  /// Imzolash uchun matnni **qayta** o'qish talab qilinmaydi: rozilik yuz
  /// tasdig'ida berilgan, undan keyin faqat imzoning o'zi qoladi.
  bool canSign(SigningParticipant participant) => participant.canSign && !isBusy;

  ContractSigningState copyWith({
    ContractSigning? signing,
    String? contractFile,
    bool? isFileLoading,
    bool? isRead,
    int? expandedId,
    SigningWrite? write,
    int? busyParticipantId,
    bool? isFinished,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractSigningState(
    signing: signing ?? this.signing,
    contractFile: contractFile ?? this.contractFile,
    isFileLoading: isFileLoading ?? this.isFileLoading,
    isRead: isRead ?? this.isRead,
    expandedId: expandedId ?? this.expandedId,
    write: write ?? this.write,
    busyParticipantId: busyParticipantId ?? this.busyParticipantId,
    isFinished: isFinished ?? this.isFinished,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[signing,contractFile,isFileLoading,isRead,expandedId,write,busyParticipantId,isFinished,failure];
}
