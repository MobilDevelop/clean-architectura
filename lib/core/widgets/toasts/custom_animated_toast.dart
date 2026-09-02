import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum ToastType { success, error, info }

final class CustomAnimatedToast {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static String? _lastMessage;

  static final navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get key => navigatorKey;

  static Future<void> show({
    required ToastType type,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) async {
    if (_isShowing && _lastMessage == message) return;

    if (_isShowing) await _closeImmediately();

    _isShowing = true;
    _lastMessage = message;

    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      _onDialogClosed();
      return;
    }

    OverlayState? overlayState;
    try {
      // ignore: use_build_context_synchronously
      overlayState = Overlay.of(ctx);
    } catch (_) {
      // Nega jim: kontekstda overlay topilmasligi kutilgan holat (masalan
      // dialog yopilayotgan payt). Zaxira yo'l pastda — navigator overlay'i.
      final fallback = navigatorKey.currentState?.overlay;
      if (fallback == null) {
        _onDialogClosed();
        return;
      }

      overlayState = fallback;
    }

    final key = GlobalKey<_CustomAnimatedToastWidgetState>();
    final entry = OverlayEntry(
      builder: (c) => _CustomAnimatedToastWidget(key: key,type: type,message: message,duration: duration),
    );

    _overlayEntry = entry;
    overlayState.insert(entry);
  }

  static Future<void> showFromRoutes({required ToastType type,required String message,Duration duration = const Duration(seconds: 2)}) async {
    return show(type: type, message: message, duration: duration);
  }

  static Future<void> showSuccess(String message) async => show(type: ToastType.success, message: message);

  static Future<void> showError(String message) async =>show(type: ToastType.error, message: message);

  static Future<void> showInfo(String message) async => show(type: ToastType.info, message: message);

  static Future<void> _closeImmediately() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
    _lastMessage = null;
  }

  static void _onDialogClosed() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
    _lastMessage = null;
  }
}

final class _CustomAnimatedToastWidget extends StatefulWidget {
  final ToastType type;
  final String message;
  final Duration duration;

  const _CustomAnimatedToastWidget({super.key,required this.type,required this.message,required this.duration});

  @override
  State<_CustomAnimatedToastWidget> createState() => _CustomAnimatedToastWidgetState();
}

final class _CustomAnimatedToastWidgetState extends State<_CustomAnimatedToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _expandController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  bool _showText = false;
  bool _isClosing = false;

  Future<void> dismiss({bool immediate = false}) async {
    if (_isClosing || !mounted) return;
    _isClosing = true;

    if (immediate) {
      CustomAnimatedToast._onDialogClosed();
      return;
    }

    await _expandController.reverse();
    if (mounted) {
      setState(() => _showText = false);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (mounted) {
      await _slideController.reverse();
    }
    CustomAnimatedToast._onDialogClosed();
  }

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300), 
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Expand animation - yumshoqroq
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250), 
      vsync: this,
    );
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic
    ));

    _slideController.forward().then((_) async {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => _showText = true);
      await _expandController.forward();
      if (!mounted) return;
      Future.delayed(widget.duration, () async {
        await dismiss();
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case ToastType.success: return AppTheme.colors.primary;
      case ToastType.error: return AppTheme.colors.red;
      case ToastType.info: return AppTheme.colors.secondary;
    }
  }

  String _getIcon() {
    switch (widget.type) {
      case ToastType.success: return AppIcons.success;
      case ToastType.error: return AppIcons.error;
      case ToastType.info: return AppIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Notch/Dynamic Island balandligi qurilmaga qarab farq qiladi —
    // qattiq raqam o'rniga tizim bergan xavfsiz maydon olinadi.
    final topPadding = MediaQuery.of(context).viewPadding.top + ScreenSize.h10;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation, 
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.w10),
              child: Material(
                color: Colors.transparent,
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - ScreenSize.w40,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: ScreenSize.w5,vertical: ScreenSize.h8),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.white,
                      borderRadius: BorderRadius.circular(ScreenSize.r20),
                      border: Border.all(color: _getColor(), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colors.black.withValues(alpha: .01),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _showText ? ScreenSize.w5 : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: _showText ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Container(
                              padding: EdgeInsets.all(ScreenSize.h6),
                              decoration: BoxDecoration(
                                color: _getColor().withValues(alpha: .1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset( _getIcon(),colorFilter: ColorFilter.mode(_getColor(),BlendMode.srcIn),height: ScreenSize.h20,width: ScreenSize.h20),
                            ),
                          ),
                          // Animated text - yumshoqroq
                          if (_showText)
                            AnimatedBuilder(
                              animation: _expandAnimation,
                              builder: (context, child) {
                                return SizeTransition(
                                  sizeFactor: _expandAnimation,
                                  axis: Axis.horizontal,
                                  child: FadeTransition(
                                    opacity: _expandAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: ScreenSize.w8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: screenWidth - ScreenSize.w140),
                                  child: Text(widget.message, style: AppTheme.data.textTheme.titleLarge?.copyWith(color: _getColor(),fontWeight: FontWeight.w500),maxLines: 3,overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}