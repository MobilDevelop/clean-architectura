import 'package:colloborator_v3/features/customers/domain/entities/face_placement.dart';

/// Kameradagi yo'riqnoma matni. Domain matn yaratmaydi (3.9).
abstract final class FacePlacementText {
  static String of(FacePlacement placement) => switch (placement) {
    FacePlacement.noFace => "Yuzingizni doira ichiga joylashtiring",
    FacePlacement.manyFaces => "Kadrda bitta odam qolsin",
    FacePlacement.tooFar => "Kameraga yaqinlashing",
    FacePlacement.tooClose => "Kameradan uzoqlashing",
    FacePlacement.moveLeft => "Chapga siljing",
    FacePlacement.moveRight => "O'ngga siljing",
    FacePlacement.moveUp => "Yuqoriga siljing",
    FacePlacement.moveDown => "Pastga siljing",
    FacePlacement.turnHead => "To'g'ri oldinga qarang",
    FacePlacement.tiltHead => "Boshingizni to'g'ri tuting",
    FacePlacement.eyesClosed => "Ko'zingizni oching",
    FacePlacement.raiseHead => "Boshingizni ko'taring",
    FacePlacement.lowerHead => "Boshingizni pastroq tuting",
    FacePlacement.ready => "Qimirlamay turing",
  };
}
