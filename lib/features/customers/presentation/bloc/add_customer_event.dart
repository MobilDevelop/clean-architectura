part of 'add_customer_bloc.dart';

sealed class AddCustomerEvent extends Equatable {
  const AddCustomerEvent();

  @override
  List<Object> get props => [];
}

/// Ekran ochilishi: viloyatlar yuklanadi, mavjud tanlovlar tiklanadi.
final class AddCustomerStarted extends AddCustomerEvent {
  const AddCustomerStarted();
}

final class ProvinceSelected extends AddCustomerEvent {
  const ProvinceSelected(this.value);

  final Province value;

  @override
  List<Object> get props => [value];
}

final class RegionSelected extends AddCustomerEvent {
  const RegionSelected(this.value);

  final Region value;

  @override
  List<Object> get props => [value];
}

final class VillageSelected extends AddCustomerEvent {
  const VillageSelected(this.value);

  final Village value;

  @override
  List<Object> get props => [value];
}

final class WorkplaceSelected extends AddCustomerEvent {
  const WorkplaceSelected(this.value);

  final WorkplaceInfo value;

  @override
  List<Object> get props => [value];
}

final class WorkplaceQueryChanged extends AddCustomerEvent {
  const WorkplaceQueryChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class StreetChanged extends AddCustomerEvent {
  const StreetChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class HouseChanged extends AddCustomerEvent {
  const HouseChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class MainPhoneChanged extends AddCustomerEvent {
  const MainPhoneChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class RelativePhoneChanged extends AddCustomerEvent {
  const RelativePhoneChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class RelativeKindSelected extends AddCustomerEvent {
  const RelativeKindSelected(this.value);

  final RelativeKind value;

  @override
  List<Object> get props => [value];
}

final class FriendPhoneChanged extends AddCustomerEvent {
  const FriendPhoneChanged(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class FormSubmitted extends AddCustomerEvent {
  const FormSubmitted();
}

final class FailureHandled extends AddCustomerEvent {
  const FailureHandled();
}
