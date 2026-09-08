import 'package:equatable/equatable.dart';

/// Tovarni o'chirish. Shartnoma id si ham kerak — o'chirishdan keyin unga
/// biriktirilgan maxsus tarif bekor qilinadi.
final class DeleteProductParams extends Equatable {
  const DeleteProductParams({required this.productId, required this.contractId});

  final int productId;
  final int contractId;

  @override
  List<Object?> get props => [productId, contractId];
}
