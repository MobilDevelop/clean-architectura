// ignore_for_file: deprecated_member_use
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,  
    required this.hint,
    this.controller,
    this.title,
    this.icon,
    this.keyboardType, 
    this.errorText, 
    this.suffixIcon, 
    this.prefix, 
    this.suffixPress, 
    this.titleColor, 
    this.suffixIconColor, 
    this.formatters, 
    this.isPassword, 
    this.autoFocus,
    this.backColor, 
    this.onChanged, 
    this.initial, 
    this.valueLength,
    this.onSubmitted, 
    this.enabled,
    this.iconHeight,
    this.focusNode
    });

  final String? title;
  final Color? titleColor;
  final Color? backColor;
  final String? icon;
  final String hint;
  final String? errorText;
  final String? suffixIcon;
  final Color? suffixIconColor;
  final String? prefix;
  final bool? isPassword;
  final bool? autoFocus;
  final bool? enabled;
  final String? initial;
  final int? valueLength;
  final double? iconHeight;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final TextEditingController? controller;
  final VoidCallback? suffixPress;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            icon !=null?SvgPicture.asset(icon!, height: iconHeight ?? ScreenSize.h10, color: AppTheme.colors.primary):SizedBox.shrink(),
            Gap(ScreenSize.w5),
            title !=null?Text(title!, style: AppTheme.data.textTheme.titleMedium!.copyWith(color: errorText?.isNotEmpty ?? false ? AppTheme.colors.red : titleColor ?? AppTheme.colors.blackSoft,fontWeight: FontWeight.bold)):SizedBox.shrink(),
          ],
        ),
        Gap(ScreenSize.h5),
        TextFormField(
          focusNode: focusNode,
          enabled: enabled ?? true,
          controller: controller,
          initialValue: initial,
          keyboardType: keyboardType ?? TextInputType.text,
          autofocus: autoFocus ?? false,
          style: AppTheme.data.textTheme.titleSmall!.copyWith(color: AppTheme.colors.blackSoft),
          obscureText: isPassword ?? false,
          obscuringCharacter: "●",
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          textDirection: TextDirection.ltr,
          cursorRadius: Radius.circular(ScreenSize.r8),
          cursorColor: AppTheme.colors.primary,
          cursorHeight: ScreenSize.h18,
          cursorOpacityAnimates: true,
          cursorErrorColor: AppTheme.colors.red,
          inputFormatters: formatters,
          // enableInteractiveSelection: false, 

          onFieldSubmitted: (value) => onSubmitted?.call(value),
          onChanged: (value) => onChanged?.call(value),
          
          decoration: InputDecoration(
            hintText: hint,
            fillColor: backColor ?? AppTheme.colors.backcolor,
            errorText: errorText,
            errorStyle: AppTheme.data.textTheme.bodySmall!.copyWith(color: AppTheme.colors.red),
            hintStyle: AppTheme.data.textTheme.titleSmall!.copyWith(color: AppTheme.colors.grey,fontWeight: FontWeight.w400),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefix: prefix != null ? Text("$prefix ",style: AppTheme.data.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w400)) : null,
            suffixIcon: suffixIcon!=null?IconButton(
              icon: SvgPicture.asset(suffixIcon!, height: ScreenSize.h20, color: suffixIconColor),
              onPressed: suffixPress,
            ):null,
            contentPadding: EdgeInsets.symmetric(horizontal: ScreenSize.h10),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
            ),
            
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              borderSide: BorderSide(color: AppTheme.colors.stroke)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              borderSide: BorderSide(color: AppTheme.colors.primary)
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              borderSide: BorderSide(color: AppTheme.colors.red)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              borderSide: BorderSide(color: AppTheme.colors.red)
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              borderSide: BorderSide(color: AppTheme.colors.grey1)
            ),
          ),
        ),
      ],
    );
  }
}

  // onChanged: (value){
  //           if(hint == "Mijoz qidirish"){
  //             if(PassportFormatter.isSearchableDocument(value) == 'psr' && value.length >= 9 || PassportFormatter.isSearchableDocument(value) == 'inps' && value.length >= 14 || PassportFormatter.isSearchableDocument(value) == 'fio' && value.length >= 3){
  //               onChanged?.call(value);
  //              }
  //           }else if(hint == "+998" && value.length == 17){
  //               onChanged?.call(value);
  //               FocusManager.instance.primaryFocus?.unfocus();
  //           }else{
  //             onChanged?.call(value);
  //           }
  //         },