import 'package:colloborator_v3/core/utils/camera_issue.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

CameraIssue _of(String code) => CameraIssues.of(PlatformException(code: code));

void main() {
  // Android va iOS ikki xil kod to'plamini beradi. Ro'yxat aynan
  // `image_picker_android` va `image_picker_ios` manbalaridan olingan —
  // bittasi qamrab olinmasa, foydalanuvchi noto'g'ri sabab ko'radi.
  group('Android kodlari', () {
    test('ruxsat yo‘q', () => expect(_of('camera_access_denied'), CameraIssue.denied));
    test('kamera yo‘q', () => expect(_of('no_available_camera'), CameraIssue.unavailable));
    test('band', () => expect(_of('already_active'), CameraIssue.busy));
  });

  group('iOS kodlari', () {
    test('ruxsat yo‘q', () => expect(_of('camera_access_denied'), CameraIssue.denied));
    test('galereyaga ruxsat yo‘q', () => expect(_of('photo_access_denied'), CameraIssue.denied));

    // iOS `already_active` emas, `multiple_request` yuboradi. U qamrab
    // olinmaganda «Kamerani ochib bo'lmadi» degan noto'g'ri xabar chiqardi.
    test('oldingi so‘rov tugamagan', () => expect(_of('multiple_request'), CameraIssue.busy));
  });

  test('noma’lum kod', () => expect(_of('something_else'), CameraIssue.unknown));

  // Har bir sababning matni bo'lishi shart: matnsiz sabab ekranda hech nima
  // ko'rsatmaydi va bosish jimgina yo'qoladi (5.8).
  test('har bir sababda matn bor', () {
    for (final CameraIssue issue in CameraIssue.values) {
      final String? text = CameraIssueText.of(issue);

      if (issue == CameraIssue.none) {
        expect(text, isNull);
        continue;
      }

      expect(text, isNotNull, reason: '$issue uchun matn yo‘q');
      expect(text?.isNotEmpty, isTrue);
    }
  });
}
