import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/cards/section_card.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/presentation/bloc/underwriter/underwriter_bloc.dart';
import 'package:colloborator_v3/features/underwriter/presentation/styles/underwriter_text.dart';
import 'package:colloborator_v3/features/underwriter/presentation/widgets/document_list.dart';
import 'package:colloborator_v3/features/underwriter/presentation/widgets/section_fields.dart';
import 'package:colloborator_v3/features/underwriter/presentation/widgets/section_tabs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Anderrayter: daromadni tasdiqlovchi hujjatlar.
///
/// Har bo'lim alohida saqlanadi — server ham ularni alohida yozuv sifatida
/// saqlaydi. Shuning uchun pastdagi tugma butun ekranni emas, **ochiq turgan
/// bo'limni** yuboradi.
final class UnderwriterPage extends StatelessWidget {
  const UnderwriterPage({super.key});

  /// Fayl tanlash — UI ta'siri, shuning uchun bloc ichida emas (6.2).
  Future<void> _pickFile(BuildContext context) async {
    final UnderwriterBloc bloc = context.read<UnderwriterBloc>();

    final PlatformFile? picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: UnderwriterFileRule.extensions.toList(),
    );

    final String? path = picked?.path;
    if (path == null) return;

    final File file = File(path);

    bloc.add(
      FileAdded(file: file, bytes: await file.length(), extension: path.split('.').last),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UnderwriterBloc, UnderwriterState>(
      listenWhen: (UnderwriterState previous, UnderwriterState current) =>
          current.savedCount != previous.savedCount,
      listener: (BuildContext context, UnderwriterState state) =>
          unawaited(CustomAnimatedToast.showSuccess("Hujjatlar saqlandi")),
      builder: (BuildContext context, UnderwriterState state) {
        final UnderwriterBloc bloc = context.read<UnderwriterBloc>();

        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const Retried()),
          bottomInset: ScreenSize.h80,
          child: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: <Widget>[
                const BackgroundWash(),
                Positioned.fill(child: _content(context, state, bloc)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, UnderwriterState state, UnderwriterBloc bloc) => Column(
    children: <Widget>[
      PageHeader(
        title: "Anderrayter hujjatlari",
        topInset: MediaQuery.paddingOf(context).top,
        backPress: () => context.pop(state.savedCount > 0),
      ),

      if (state.isLoading && !state.isReady)
        Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)))
      else if (!state.isReady)
        // Yuklanmagan holatda saqlashga ruxsat berilmaydi: `editId` nolda
        // qolib, mavjud yozuv ustidan ikkinchisi yaratilib ketardi.
        //
        // Tugma shu yerda kerak: `FailureView` «Qayta urinish» ni faqat
        // aloqa xatosida ko'rsatadi, server yoki shakl xatosida esa ekran
        // matn bilan qolib, uriniladigan joy qolmasdi (5.8).
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(ScreenSize.h24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Ma'lumotni yuklab bo'lmadi",
                    textAlign: TextAlign.center,
                    style: AppTheme.data.textTheme.bodySmall,
                  ),

                  Gap(ScreenSize.h12),
                  MainButton(
                    text: "Qayta urinish",
                    showLoading: state.isLoading,
                    margin: EdgeInsets.symmetric(horizontal: ScreenSize.h40),
                    onPressed: () => bloc.add(const Retried()),
                  ),
                ],
              ),
            ),
          ),
        )
      else ...<Widget>[
        Gap(ScreenSize.h10),
        SectionTabs(
          sections: state.sections,
          current: state.current,
          isLocked: state.isBusy,
          onSelected: (UnderwriterKind kind) => bloc.add(SectionSelected(kind)),
        ),

        Expanded(child: _body(context, state, bloc)),

        SafeArea(
          top: false,
          child: MainButton(
            text: "Tasdiqlash",
            margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
            showLoading: state.isBusy,
            // Tugma o'chirilmaydi: to'ldirilmagan bo'lsa nima yetishmayotgani
            // ko'rsatiladi (5.8).
            onPressed: () => bloc.add(const SectionSubmitted()),
          ),
        ),
      ],
    ],
  );

  Widget _body(BuildContext context, UnderwriterState state, UnderwriterBloc bloc) {
    final UnderwriterForm form = state.form ?? const StudentForm.empty();
    final String? issue = UnderwriterText.issue(state.issue);

    return ListView(
      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h14, ScreenSize.h16, ScreenSize.h24),
      children: <Widget>[
        if (form is! StudentForm)
          SectionCard(
            title: UnderwriterText.title(state.current),
            icon: UnderwriterText.icon(state.current),
            accent: UnderwriterText.color(state.current),
            isDivided: false,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
                child: SectionFields(state: state, form: form),
              ),
            ],
          ),

        SectionCard(
          title: "Hujjatlar",
          icon: Icons.folder_outlined,
          accent: AppTheme.colors.grey,
          isDivided: false,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
              child: DocumentList(
                files: form.files,
                isFull: form.isFull,
                addTitle: "${UnderwriterText.documentTitle(state.current)} yuklash",
                errorText: UnderwriterText.file(state.fileIssue) ?? issue,
                addPress: () => unawaited(_pickFile(context)),
                removePress: (int index) => bloc.add(FileRemoved(index)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
