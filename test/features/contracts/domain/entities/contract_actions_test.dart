import 'package:colloborator_v3/features/contracts/domain/entities/contract_actions.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:flutter_test/flutter_test.dart';

ContractInfo _contract({
  required int statusCode,
  AuthorityEngine engine = AuthorityEngine.legacy,
  bool isReturned = false,
  bool flex = false,
  bool isSentForApproval = false,
  bool canAllow = false,
  bool needsHigher = false,
}) => ContractInfo(
  id: 1,
  clientId: 1,
  clientFio: 'Test',
  passport: '',
  birthDay: '',
  clientSignUrl: '',
  engine: engine,
  statusCode: statusCode,
  createdAt: '',
  sentUserFullname: '',
  sentPartnerFullname: '',
  isFormal: false,
  isReturned: isReturned,
  isCard: false,
  flex: flex,
  isClientFace: false,
  higherPositionConfirmationRequired: needsHigher,
  canUserAllowConfirmation: canAllow,
  isSentForApproval: isSentForApproval,
  showButtonKATM: false,
  hasBenefit: false,
  guarantors: const <GuarantorInfo>[],
  status: ContractStatus.unknown,
);

void main() {
  group('tapOf — status bo‘yicha yo‘naltirish', () {
    test('40 → daromad turi', () => expect(ContractActions.tapOf(40), ContractTap.selectIncome));
    test('24 → SMS', () => expect(ContractActions.tapOf(24), ContractTap.confirmSms));
    test('25 → SMS', () => expect(ContractActions.tapOf(25), ContractTap.confirmSms));
    test('11 → mahsulot', () => expect(ContractActions.tapOf(11), ContractTap.viewProduct));
    test('qolgani → amallar', () => expect(ContractActions.tapOf(8), ContractTap.showActions));
  });

  group('eski dvijok', () {
    test('8-statusda tasdiqlash faol', () {
      expect(ContractActions.of(_contract(statusCode: 8)).canApprove, isTrue);
    });

    test('1-statusda tasdiqlash faol emas', () {
      expect(ContractActions.of(_contract(statusCode: 1)).canApprove, isFalse);
    });

    test('13-status tahrirlash va bekor qilishda hisobga olinadi', () {
      final ContractActions actions = ContractActions.of(_contract(statusCode: 13));

      expect(actions.canEdit, isTrue);
      expect(actions.canCancel, isTrue);
    });

    test('qaytarilgan shartnoma tahrirlanmaydi va bekor qilinmaydi', () {
      final ContractActions actions = ContractActions.of(_contract(statusCode: 8, isReturned: true));

      expect(actions.canEdit, isFalse);
      expect(actions.canCancel, isFalse);
    });

    test('flex shartnomasi tahrirlanmaydi', () {
      expect(ContractActions.of(_contract(statusCode: 8, flex: true)).canEdit, isFalse);
    });

    test('tasdiqlashga yuborilgani tahrirlanmaydi', () {
      expect(ContractActions.of(_contract(statusCode: 8, isSentForApproval: true)).canEdit, isFalse);
    });
  });

  group('eski dvijok — uchta ma‘no', () {
    test('bayroqlar bo‘sh bo‘lsa tasdiqlash', () {
      expect(ContractActions.of(_contract(statusCode: 8)).approve, ApproveAction.proceed);
    });

    test('canUserAllowConfirmation → ruxsat berish', () {
      final ContractActions actions = ContractActions.of(_contract(statusCode: 8, canAllow: true));

      expect(actions.approve, ApproveAction.allow);
      expect(actions.needsConfirmation, isTrue);
    });

    test('higherPositionConfirmationRequired → yuborish', () {
      final ContractActions actions = ContractActions.of(_contract(statusCode: 8, needsHigher: true));

      expect(actions.approve, ApproveAction.escalate);
      expect(actions.needsConfirmation, isTrue);
    });

    test('ikkalasi ham bo‘lsa ruxsat berish ustun', () {
      expect(
        ContractActions.of(_contract(statusCode: 8, canAllow: true, needsHigher: true)).approve,
        ApproveAction.allow,
      );
    });

    test('eski dvijokda vakolat javobi kutilmaydi', () {
      expect(ContractActions.of(_contract(statusCode: 8)).isReady, isTrue);
    });
  });

  group('matritsa', () {
    const ContractAuthority proceed = ContractAuthority(
      message: '',
      canProceed: true,
      canApprove: false,
      canEscalate: false,
      canCancel: true,
    );

    test('vakolat javobi kelmaguncha hech qanday amal yo‘q', () {
      final ContractActions actions = ContractActions.of(_contract(statusCode: 8, engine: AuthorityEngine.matrix));

      expect(actions.isReady, isFalse);
      expect(actions.canApprove, isFalse);
      expect(actions.canCancel, isFalse);
    });

    test('canProceed tasdiqlashni ochadi', () {
      final ContractActions actions = ContractActions.of(
        _contract(statusCode: 8, engine: AuthorityEngine.matrix),
        authority: proceed,
      );

      expect(actions.canApprove, isTrue);
      expect(actions.canCancel, isTrue);
      expect(actions.approve, ApproveAction.proceed);
      expect(actions.needsConfirmation, isFalse);
      expect(actions.warning, isEmpty);
    });

    test('eskalatsiyada tugma boshqa ma’noda bo‘ladi', () {
      final ContractActions actions = ContractActions.of(
        _contract(statusCode: 8, engine: AuthorityEngine.matrix),
        authority: const ContractAuthority(
          message: 'Vakolatingiz yetmaydi',
          canProceed: false,
          canApprove: false,
          canEscalate: true,
          canCancel: false,
        ),
      );

      expect(actions.canApprove, isTrue);
      expect(actions.approve, ApproveAction.escalate);
      expect(actions.warning, 'Vakolatingiz yetmaydi');
    });

    test('canApprove → ruxsat berish', () {
      final ContractActions actions = ContractActions.of(
        _contract(statusCode: 8, engine: AuthorityEngine.matrix),
        authority: const ContractAuthority(
          message: '',
          canProceed: false,
          canApprove: true,
          canEscalate: false,
          canCancel: false,
        ),
      );

      expect(actions.approve, ApproveAction.allow);
      expect(actions.canApprove, isTrue);
      expect(actions.warning, isEmpty);
    });

    test('uchala bayroq ham false bo‘lsa sabab ko‘rsatiladi', () {
      final ContractActions actions = ContractActions.of(
        _contract(statusCode: 8, engine: AuthorityEngine.matrix),
        authority: const ContractAuthority(
          message: 'Ruxsat kutilmoqda',
          canProceed: false,
          canApprove: false,
          canEscalate: false,
          canCancel: false,
        ),
      );

      expect(actions.canApprove, isFalse);
      expect(actions.warning, 'Ruxsat kutilmoqda');
    });

    test('matritsada status bo‘yicha tasdiqlash hisoblanmaydi', () {
      final ContractActions actions = ContractActions.of(
        _contract(statusCode: 1, engine: AuthorityEngine.matrix),
        authority: proceed,
      );

      expect(actions.canApprove, isTrue);
    });
  });
}
