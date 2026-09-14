import 'package:colloborator_v3/features/contracts/data/models/contract_scoring_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> full({Object? clientId = 12, Object? limit = 5000000}) => <String, dynamic>{
    'client_id': clientId,
    'client_fio': 'ABDULLAYEV BOTIR',
    'status_code': 'passed',
    'limit': limit,
    'free_limit': 4000000,
    'exceeded_limit': 0,
    'co_borrower_limit': 0,
    'asoki_monthly_payment': 100000,
  };

  test('to‘liq yozuv o‘qiladi', () {
    final entity = ContractScoringDto.fromJson(full()).toEntity();

    expect(entity.clientId, 12);
    expect(entity.limits.total, 5000000);
  });

  test('client_id siz yiqiladi', () {
    expect(() => ContractScoringDto.fromJson(full(clientId: null)), throwsFormatException);
  });

  test('limit siz yiqiladi', () {
    expect(() => ContractScoringDto.fromJson(full(limit: null)), throwsFormatException);
  });
}
