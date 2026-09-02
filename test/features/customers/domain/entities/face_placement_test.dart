import 'package:colloborator_v3/features/customers/domain/entities/face_placement.dart';
import 'package:flutter_test/flutter_test.dart';

FaceGeometry _face({
  double centerX = .5,
  double centerY = .5,
  double width = .8,
  double yaw = 0,
  double roll = 0,
  double pitch = 0,
  double? eyesOpen,
}) => FaceGeometry(
  centerX: centerX,
  centerY: centerY,
  width: width,
  yaw: yaw,
  roll: roll,
  pitch: pitch,
  eyesOpen: eyesOpen,
);

void main() {
  group('FacePlacementRule', () {
    test('yuz yo‘q', () => expect(FacePlacementRule.of(const <FaceGeometry>[]), FacePlacement.noFace));

    test('ikkita yuz', () {
      expect(FacePlacementRule.of(<FaceGeometry>[_face(), _face()]), FacePlacement.manyFaces);
    });

    test('markazda va to‘g‘ri', () => expect(FacePlacementRule.of(<FaceGeometry>[_face()]), FacePlacement.ready));

    test('uzoq', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(width: .5)]), FacePlacement.tooFar));
    test('yaqin', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(width: .99)]), FacePlacement.tooClose));

    // Ekran koordinatalarida: markazdan chapda turgan odam o'ngga siljishi kerak.
    test('chapda', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(centerX: .2)]), FacePlacement.moveRight));
    test('o‘ngda', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(centerX: .8)]), FacePlacement.moveLeft));
    test('tepada', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(centerY: .2)]), FacePlacement.moveDown));
    test('pastda', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(centerY: .8)]), FacePlacement.moveUp));

    test('yon burilgan', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(yaw: 30)]), FacePlacement.turnHead));
    test('qiyshaygan', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(roll: -30)]), FacePlacement.tiltHead));
    test('tepaga qaragan', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(pitch: 40)]), FacePlacement.lowerHead));
    test('pastga qaragan', () => expect(FacePlacementRule.of(<FaceGeometry>[_face(pitch: -40)]), FacePlacement.raiseHead));

    test('ko‘z yumilgan', () {
      expect(FacePlacementRule.of(<FaceGeometry>[_face(eyesOpen: .1)]), FacePlacement.eyesClosed);
    });

    test('ko‘z holati noma’lum bo‘lsa to‘smaydi', () {
      expect(FacePlacementRule.of(<FaceGeometry>[_face()]), FacePlacement.ready);
    });

    test('masofa markazdan oldin tekshiriladi', () {
      expect(FacePlacementRule.of(<FaceGeometry>[_face(width: .5, centerX: .9)]), FacePlacement.tooFar);
    });
  });

  group('FaceHold', () {
    final DateTime start = DateTime(2026, 9, 2, 12);

    test('bitta kadr yetarli emas', () {
      final FaceHold hold = FaceHold(duration: const Duration(seconds: 1));
      expect(hold.add(FacePlacement.ready, start), isFalse);
    });

    test('vaqt to‘lganda tayyor', () {
      final FaceHold hold = FaceHold(duration: const Duration(seconds: 1));
      hold.add(FacePlacement.ready, start);
      expect(hold.add(FacePlacement.ready, start.add(const Duration(milliseconds: 1000))), isTrue);
    });

    test('yuz qimirlasa hisob boshidan boshlanadi', () {
      final FaceHold hold = FaceHold(duration: const Duration(seconds: 1));
      hold.add(FacePlacement.ready, start);
      hold.add(FacePlacement.tooFar, start.add(const Duration(milliseconds: 900)));
      expect(hold.add(FacePlacement.ready, start.add(const Duration(milliseconds: 1100))), isFalse);
    });

    test('reset hisobni to‘xtatadi', () {
      final FaceHold hold = FaceHold(duration: const Duration(seconds: 1));
      hold.add(FacePlacement.ready, start);
      hold.reset();
      expect(hold.add(FacePlacement.ready, start.add(const Duration(seconds: 2))), isFalse);
    });
  });
}
