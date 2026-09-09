import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/offer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Ma'lum mijozni yuz bo'yicha tasdiqlash.
///
/// `FaceIdPage` dan farqi: u **notanish odamni** pasport bo'yicha topadi,
/// bu esa **allaqachon ma'lum mijozning** o'zi ekanini tekshiradi. Shuning
/// uchun bu yerda pasport formasi yo'q — u to'ldirilgan holda ko'rsatilsa,
/// operator uni bekorga bosib o'tardi.
///
/// Oqim flex'dagidek: ekran ochilishi bilan oferta chiqadi, rozilikdan keyin
/// kamera. Flex'da esa kim tekshirilayotgani hech qayerda ko'rinmasdi.
final class ClientVerifyPage extends StatefulWidget {
  const ClientVerifyPage({super.key, required this.customer, required this.reason});

  final CustomerInfo customer;

  /// Nima uchun tekshirilyapti — "Shartnoma tuzish" yoki "Kafil qo'shish".
  final String reason;

  @override
  State<ClientVerifyPage> createState() => _ClientVerifyPageState();
}

final class _ClientVerifyPageState extends State<ClientVerifyPage> {
  late final FaceIdBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<FaceIdBloc>();

    // Pasport mijozning kartochkasidan olinadi — operator uni kiritmaydi.
    final String passport = widget.customer.passportNumber;
    final bool isFull = passport.length > 2;

    _bloc
      ..add(SeriesChanged(isFull ? passport.substring(0, 2) : ''))
      ..add(NumberChanged(isFull ? passport.substring(2) : ''))
      ..add(BirthdayChanged(_birthday(widget.customer.birthDay)));

    // Oferta ekran ochilishi bilan chiqadi: katakcha ko'rinishida u
    // o'qilmasdan belgilanib ketardi.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_openOffer()));
  }

  /// `2004-04-17` yoki `17.04.2004` → `dd.MM.yyyy`.
  String _birthday(String raw) {
    final DateTime? date = DateTime.tryParse(raw);
    if (date == null) return raw.contains('.') ? raw : '';

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return "$day.$month.${date.year}";
  }

  Future<void> _openOffer() => showOfferSheet(
    context: context,
    onAccepted: () => _bloc.add(const OfferAccepted(true)),
  );

  Future<void> _openCamera() async {
    final File? photo = await context.push<File>(Routes.faceCamera.path);
    if (!mounted) return;

    if (photo != null) {
      _bloc.add(PhotoCaptured(photo));
      return;
    }

    // Kameradan orqaga qaytish — butun tekshiruvdan voz kechish, chunki bu
    // ekranda kameradan boshqa qiladigan ish yo'q. Uni qoldirish
    // foydalanuvchini bir xil tugmani ikki marta bosishga majbur qilardi.
    _bloc.add(const CaptureCancelled());
    context.pop();
  }

  /// Ofertadan keyin kamera o'zi ochiladi — flex'dagi zanjir shu.
  void _continue(FaceIdState state) => state.isOfferAccepted
      ? _bloc.add(const CaptureRequested())
      : unawaited(_openOffer());

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<FaceIdBloc, FaceIdState>>[
        BlocListener<FaceIdBloc, FaceIdState>(
          listenWhen: (FaceIdState previous, FaceIdState current) =>
              current.isOfferAccepted && !previous.isOfferAccepted,
          listener: (BuildContext context, FaceIdState state) => _bloc.add(const CaptureRequested()),
        ),

        BlocListener<FaceIdBloc, FaceIdState>(
          listenWhen: (FaceIdState previous, FaceIdState current) => current.cameraOpen,
          listener: (BuildContext context, FaceIdState state) => unawaited(_openCamera()),
        ),

        BlocListener<FaceIdBloc, FaceIdState>(
          listenWhen: (FaceIdState previous, FaceIdState current) =>
              current.customerInfo != previous.customerInfo,
          listener: _onChecked,
        ),
      ],
      child: BlocBuilder<FaceIdBloc, FaceIdState>(
        builder: (BuildContext context, FaceIdState state) => FailureView(
          failure: state.failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const CheckRetried()),
          bottomInset: ScreenSize.h90,
          child: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            body: Stack(
              children: <Widget>[
                const BackgroundWash(),
                Positioned.fill(child: _content(state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Server boshqa mijozni qaytarsa — bu boshqa odam.
  void _onChecked(BuildContext context, FaceIdState state) {
    final CustomerInfo? verified = state.customerInfo;
    if (verified == null) return;

    if (verified.id != widget.customer.id) {
      unawaited(CustomAnimatedToast.showError("Yuz tekshiruvi bu mijozga mos kelmadi"));
      return;
    }

    context.pop(verified);
  }

  Widget _content(FaceIdState state) => Column(
    children: <Widget>[
      PageHeader(
        title: "Mijozni tasdiqlash",
        topInset: MediaQuery.paddingOf(context).top,
        backPress: () => context.pop(),
      ),

      Expanded(
        child: ListView(
          padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h16, ScreenSize.h16, ScreenSize.h24),
          children: <Widget>[
            _clientCard(),
            Gap(ScreenSize.h14),
            _offerRow(state.isOfferAccepted),
            Gap(ScreenSize.h14),
            Text(
              "${widget.reason} uchun mijozning yuzi tekshiriladi. Kamera ochilgach, yuzni ramka ichida ushlab turing — surat o'zi olinadi.",
              style: AppTheme.data.textTheme.bodySmall,
            ),
          ],
        ),
      ),

      SafeArea(
        top: false,
        child: MainButton(
          text: state.isOfferAccepted ? "Yuzni tekshirish" : "Oferta shartlarini o'qish",
          margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
          showLoading: state.isLoading,
          onPressed: () => _continue(state),
        ),
      ),
    ],
  );

  Widget _clientCard() {
    final String name = widget.customer.fullName;
    final String initial = name.isEmpty ? "?" : name.characters.first.toUpperCase();

    return Container(
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenSize.h44,
            height: ScreenSize.h44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
            ),
          ),

          Gap(ScreenSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name.isEmpty ? "Mijoz" : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),
                if (widget.customer.passportNumber.isNotEmpty)
                  Text(widget.customer.passportNumber, style: AppTheme.data.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerRow(bool isAccepted) => InkWell(
    onTap: () => unawaited(_openOffer()),
    borderRadius: BorderRadius.circular(ScreenSize.r16),
    child: Container(
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: isAccepted ? AppTheme.colors.primary.withValues(alpha: .07) : AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        border: isAccepted
            ? Border.all(color: AppTheme.colors.primary.withValues(alpha: .4))
            : AppSurface.border(),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isAccepted ? Icons.check_circle_rounded : Icons.description_outlined,
            size: ScreenSize.h20,
            color: isAccepted ? AppTheme.colors.primary : AppTheme.colors.grey,
          ),
          Gap(ScreenSize.w10),
          Expanded(
            child: Text(
              isAccepted ? "Ommaviy oferta qabul qilindi" : "Ommaviy oferta shartlari",
              style: AppTheme.data.textTheme.titleSmall?.copyWith(
                color: isAccepted ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
              ),
            ),
          ),
          if (!isAccepted)
            Icon(Icons.chevron_right, size: ScreenSize.h20, color: AppTheme.colors.grey),
        ],
      ),
    ),
  );
}
