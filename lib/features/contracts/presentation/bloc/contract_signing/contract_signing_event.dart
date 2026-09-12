import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

sealed class ContractSigningEvent extends Equatable {
  const ContractSigningEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Shartnoma matni so'raldi.
final class ContractFileRequested extends ContractSigningEvent {
  const ContractFileRequested();
}

/// Matn oxirigacha o'qildi.
final class ContractRead extends ContractSigningEvent {
  const ContractRead();
}

/// Ishtirokchi qatori ochildi yoki yopildi.
final class ParticipantToggled extends ContractSigningEvent {
  const ParticipantToggled(this.participantId);

  final int participantId;

  @override
  List<Object?> get props => <Object?>[participantId];
}

/// Yuz surati olindi. Kamerani sahifa ochadi, bloc faqat `File` ni oladi (6.2).
final class FaceCaptured extends ContractSigningEvent {
  const FaceCaptured({required this.participantId, required this.photo});

  final int participantId;
  final File photo;

  @override
  List<Object?> get props => <Object?>[participantId, photo.path];
}

/// Imzo chizildi va yuborilmoqda.
///
/// Izoh shu yerda keladi: u imzo ekranida yozildi va boshqa hech qayerda
/// ishlatilmaydi — bloc'da alohida saqlanishi ekranga chiqmaydigan maydon
/// bo'lib qolardi.
final class SignatureSubmitted extends ContractSigningEvent {
  const SignatureSubmitted({required this.participantId,required this.signature,required this.comment});

  final int participantId;
  final Uint8List signature;
  final String comment;

  @override
  List<Object?> get props => <Object?>[participantId, signature.length, comment];
}

final class FailureHandled extends ContractSigningEvent {
  const FailureHandled();
}

/// Yiqilgan amalni takrorlaydi.
final class Retried extends ContractSigningEvent {
  const Retried();
}
