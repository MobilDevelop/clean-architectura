import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/circle_icon_button.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_placement.dart';
import 'package:colloborator_v3/features/customers/presentation/camera/face_camera_controller.dart';
import 'package:colloborator_v3/features/customers/presentation/camera/face_scanner.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/camera_start_text.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/capture_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/face_placement_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/face_camera_view.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/face_guidance_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Har nechanchi kadr tekshiriladi. Har birini tekshirish batareyani yeydi va
/// tanib olishni tezlashtirmaydi.
const int _frameStep = 2;

/// Yuzni avtomatik suratga oladi: foydalanuvchi masofani o'zi tanlasa, bazida
/// juda uzoq, bazida juda yaqin rasm chiqadi.
final class FaceCameraPage extends StatefulWidget {
  const FaceCameraPage({super.key});

  @override
  State<FaceCameraPage> createState() => _FaceCameraPageState();
}

final class _FaceCameraPageState extends State<FaceCameraPage> with WidgetsBindingObserver {
  final FaceCameraController _camera = FaceCameraController();
  final FaceScanner _scanner = FaceScanner();
  final FaceHold _hold = FaceHold();

  CameraStartIssue _startIssue = CameraStartIssue.none;
  FacePlacement _placement = FacePlacement.noFace;
  bool _isStarting = true;
  bool _isCapturing = false;
  CaptureIssue _captureIssue = CaptureIssue.none;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_scanner.close());
    unawaited(_camera.dispose());
    super.dispose();
  }

  /// Ilova fonga o'tganda kamera bo'shatiladi — aks holda tizim uni tortib
  /// oladi va qaytganda oqim uzilgan holda qoladi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camera.isReady) return;

    if (state == AppLifecycleState.inactive) {
      unawaited(_camera.stopStream());
    } else if (state == AppLifecycleState.resumed && !_isCapturing) {
      _hold.reset();
      unawaited(_camera.startStream(_onFrame));
    }
  }

  Future<void> _start() async {
    final CameraStartIssue issue = await _camera.start();
    if (!mounted) return;

    setState(() {
      _startIssue = issue;
      _isStarting = false;
    });

    if (issue == CameraStartIssue.none) await _camera.startStream(_onFrame);
  }

  void _onFrame(CameraImage image) {
    if (_isCapturing || _scanner.isBusy || _captureIssue != CaptureIssue.none) return;

    _frame++;
    if (_frame % _frameStep != 0) return;

    unawaited(_scan(image));
  }

  Future<void> _scan(CameraImage image) async {
    final CameraDescription? camera = _camera.camera;
    final CameraController? controller = _camera.controller;
    if (camera == null || controller == null) return;

    final List<FaceGeometry>? faces = await _scanner.scan(
      image: image,
      camera: camera,
      orientation: controller.value.deviceOrientation,
    );

    if (faces == null || !mounted || _isCapturing) return;

    final FacePlacement placement = FacePlacementRule.of(faces);
    if (placement != _placement) setState(() => _placement = placement);

    if (_hold.add(placement, DateTime.now())) await _capture();
  }

  Future<void> _capture() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    final ({File? photo, CaptureIssue issue}) result = await _camera.capture();
    if (!mounted) return;

    final File? photo = result.photo;
    if (photo != null) {
      context.pop(photo);
      return;
    }

    // Jimgina qayta urinish sikliga tushmaymiz: sabab ekranga chiqadi va
    // takrorlashni foydalanuvchi o'zi tanlaydi (5.8).
    _hold.reset();
    setState(() {
      _isCapturing = false;
      _captureIssue = result.issue;
    });
  }

  Future<void> _retryCapture() async {
    _hold.reset();
    setState(() => _captureIssue = CaptureIssue.none);
    await _camera.startStream(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    final CameraStartIssue issue = _startIssue;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenSize.h56,
                child: Row(
                  children: <Widget>[
                    CircleIconButton(icon: AppIcons.close, onTap: context.pop),

                    Gap(ScreenSize.w12),
                    Expanded(
                      child: Text(
                        "Yuzni tekshirish",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: issue == CameraStartIssue.none
                      // Doira bo'sh joyning qisqa tomoniga qarab o'lchanadi —
                      // past ekranda ham sig'adi, kengida ham kichrayib qolmaydi.
                      ? LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints limits) => FaceCameraView(
                            controller: _camera.controller,
                            isReady: _placement == FacePlacement.ready,
                            size:
                                (limits.maxWidth < limits.maxHeight ? limits.maxWidth : limits.maxHeight) -
                                ScreenSize.h16,
                          ),
                        )
                      : Text(
                          CameraStartText.of(issue),
                          textAlign: TextAlign.center,
                          style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                        ),
                ),
              ),

              if (issue == CameraStartIssue.none) ...<Widget>[
                if (_captureIssue == CaptureIssue.none)
                  FaceGuidanceBar(
                    message: _isStarting ? "Kamera tayyorlanmoqda" : FacePlacementText.of(_placement),
                    isReady: _placement == FacePlacement.ready,
                  )
                else ...<Widget>[
                  FaceGuidanceBar(message: CaptureIssueText.of(_captureIssue), isReady: false),

                  Gap(ScreenSize.h12),
                  MainButton(text: "Qayta urinish", onPressed: () => unawaited(_retryCapture())),
                ],
              ],

              Gap(ScreenSize.h20),
            ],
          ),
        ),
      ),
    );
  }
}
