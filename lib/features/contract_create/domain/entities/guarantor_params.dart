import 'package:equatable/equatable.dart';

/// `POST add_loan_guarantor` kirishi.
final class AddGuarantorParams extends Equatable {
  const AddGuarantorParams({required this.contractId, required this.clientId});

  final int contractId;

  /// Kafil bo'ladigan mijozning id si.
  final int clientId;

  @override
  List<Object?> get props => [contractId, clientId];
}

/// `DELETE delete_loan_guarantor/{id}?loan_id=` kirishi.
///
/// [rowId] — kafil qatorining id si. Flex mijoz id sini yuboradi va bu ikkisi
/// bir xilmi degan savol backendga berilgan; javob kelgunicha server qaytargan
/// id o'zgartirilmasdan qaytariladi.
final class RemoveGuarantorParams extends Equatable {
  const RemoveGuarantorParams({required this.rowId, required this.contractId});

  final int rowId;
  final int contractId;

  @override
  List<Object?> get props => [rowId, contractId];
}
