part of 'face_id_bloc.dart';

sealed class FaceIdEvent extends Equatable {
  const FaceIdEvent();

  @override
  List<Object> get props => [];
}

final class SeriesChanged extends FaceIdEvent {
  const SeriesChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class NumberChanged extends FaceIdEvent {
  const NumberChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class BirthdayChanged extends FaceIdEvent {
  const BirthdayChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class OfferAccepted extends FaceIdEvent {
  const OfferAccepted(this.value);

  final bool value;

  @override
  List<Object> get props => [value];
}

final class CaptureRequested extends FaceIdEvent {
  const CaptureRequested();
}

final class CaptureCancelled extends FaceIdEvent {
  const CaptureCancelled();
}

final class PhotoCaptured extends FaceIdEvent {
  const PhotoCaptured(this.image);

  final File image;

  @override
  List<Object> get props => [image.path];
}

final class CheckRetried extends FaceIdEvent {
  const CheckRetried();
}

final class FailureHandled extends FaceIdEvent {
  const FailureHandled();
}
