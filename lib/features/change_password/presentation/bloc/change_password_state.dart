part of 'change_password_bloc.dart';

/// Kiritishga to'sqinlik qilayotgan kamchilik. `mismatch` faqat shu ekranga
/// tegishli — backend takrorlangan parolni bilmaydi (7.2).
enum PasswordFieldIssue { none, tooShort, mismatch }

final class ChangePasswordState extends Equatable {
  const ChangePasswordState({required this.isSubmitting, required this.issue, this.failure});

  const ChangePasswordState.initial() : isSubmitting = false, issue = PasswordFieldIssue.none, failure = null;

  final bool isSubmitting;
  final PasswordFieldIssue issue;
  final Failure? failure;

  ChangePasswordState copyWith({
    bool? isSubmitting,
    PasswordFieldIssue? issue,
    Failure? failure,
    bool clearFailure = false,
  }) => ChangePasswordState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    issue: issue ?? this.issue,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[isSubmitting, issue, failure];
}
