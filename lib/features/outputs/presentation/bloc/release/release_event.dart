part of 'release_bloc.dart';

sealed class ReleaseEvent extends Equatable {
  const ReleaseEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Oyna ochildi — avval iCloud talablari tekshiriladi.
final class ReleaseStarted extends ReleaseEvent {
  const ReleaseStarted();
}

/// Tovarlar surati olindi.
final class PhotoTaken extends ReleaseEvent {
  const PhotoTaken(this.photo);

  final File photo;

  @override
  List<Object?> get props => <Object?>[photo.path];
}

/// Kamera ochilmadi. Sababi ekranda ko'rinadi (5.8).
final class CameraRefused extends ReleaseEvent {
  const CameraRefused(this.issue);

  final CameraIssue issue;

  @override
  List<Object?> get props => <Object?>[issue];
}

final class CodeChanged extends ReleaseEvent {
  const CodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

final class ReleaseSubmitted extends ReleaseEvent {
  const ReleaseSubmitted();
}

final class FailureHandled extends ReleaseEvent {
  const FailureHandled();
}

final class Retried extends ReleaseEvent {
  const Retried();
}
