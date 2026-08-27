import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EnterError extends StatelessWidget {
  const EnterError({super.key,required this.deviceId,required this.title});

  final String deviceId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
     padding: EdgeInsets.all(ScreenSize.h12),
     margin: EdgeInsets.only(top: ScreenSize.h10),
     alignment: Alignment.center,
     decoration: BoxDecoration(
      color: AppTheme.colors.white,
      border: Border.all(color: AppTheme.colors.red,width: ScreenSize.h2),
      borderRadius: BorderRadius.circular(ScreenSize.r20),
      boxShadow: [
        BoxShadow(
          color: AppTheme.colors.red.withValues(alpha: .15),
          blurRadius: ScreenSize.h6,
          spreadRadius: ScreenSize.h1,
          offset: Offset(ScreenSize.h5, ScreenSize.h4)
        )
      ]
     ),
     child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Text(title,textAlign: TextAlign.center,style: AppTheme.data.textTheme.headlineMedium),
         Gap(ScreenSize.h10),
         Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10,vertical: ScreenSize.h5), 
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            border: Border.all(color: AppTheme.colors.grey,width: ScreenSize.h1),
            borderRadius: BorderRadius.circular(ScreenSize.r12)
          ),
          child: Text(deviceId,textAlign: TextAlign.center ,style: AppTheme.data.textTheme.displayLarge!.copyWith(color: AppTheme.colors.black))),
       ],
     ),
     );
  }
}