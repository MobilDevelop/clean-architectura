import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/external_checks_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/internal_checks_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/scoring_limit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Bitta ishtirokchining natijasi: nomi, limiti va ikki turdagi tekshiruv.
final class ScoringParticipant extends StatelessWidget {
  const ScoringParticipant({super.key, required this.scoring});

  final ContractScoring scoring;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: ScreenSize.h12),
          padding: EdgeInsets.all(ScreenSize.h12),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(ScreenSize.r20),
            border: AppSurface.border(),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(ScreenSize.h10),
                decoration: BoxDecoration(border: AppSurface.border(), shape: BoxShape.circle),
                child: SvgPicture.asset(AppIcons.person, height: ScreenSize.h20),
              ),

              Gap(ScreenSize.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Ishtirokchi", style: AppTheme.data.textTheme.bodySmall),

                    Gap(ScreenSize.h2),
                    Text(
                      scoring.clientName.isEmpty ? "Ism ko'rsatilmagan" : scoring.clientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ScoringLimitCard(limits: scoring.limits),
        InternalChecksCard(checks: scoring.internal, passed: scoring.passedInternal),
        ExternalChecksCard(checks: scoring.external),
      ],
    );
  }
}
