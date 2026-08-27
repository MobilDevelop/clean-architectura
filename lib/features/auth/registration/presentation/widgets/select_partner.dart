import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class SelectPartner extends StatelessWidget {
  const SelectPartner({super.key, required this.title, required this.hint, required this.onChange});

  final String title;
  final String hint;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(AppIcons.star, height: ScreenSize.h10,colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn)),
            Gap(ScreenSize.w5), 
            Text(title, style: AppTheme.data.textTheme.headlineLarge!.copyWith(color: AppTheme.colors.black)),
          ],
        ),
                              
        Gap(ScreenSize.w5),
        Container(
          height: ScreenSize.h40,
          width: double.infinity,
          padding: EdgeInsets.only(right: ScreenSize.h2,left: ScreenSize.h5),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(ScreenSize.r25),
            border: Border.all(color: AppTheme.colors.stroke)
          ),
          child: Row(
            children: [

              Gap(ScreenSize.h5),
              Expanded(child: Text(hint,
              maxLines: 1,overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.titleMedium!.copyWith(color: AppTheme.colors.black))),

              Gap(ScreenSize.h5),
              Bounce(
                duration: Duration(milliseconds: AppConstants.duration),
                onTap: onChange,
                child: Container(
                  height: ScreenSize.h35,
                  margin: EdgeInsets.only(right: ScreenSize.h2,top: ScreenSize.h3,bottom: ScreenSize.h3),
                  padding: EdgeInsets.symmetric(horizontal: ScreenSize.h15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.blue,
                    borderRadius: BorderRadius.circular(ScreenSize.r30)
                  ),
                  child: Text("Tanlash",style: AppTheme.data.textTheme.headlineMedium!.copyWith(color: AppTheme.colors.white)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}