import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/bloc/registration_bloc.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/widgets/select_partner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late RegistrationBloc _bloc;

  @override
  void initState() {
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _bloc = context.read<RegistrationBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listenWhen: (previous, current) => current.errorMessage.isNotEmpty || current.isRegistered,
      listener: (context, state) {
        if(state.errorMessage.isNotEmpty){
          unawaited(CustomAnimatedToast.showError(state.errorMessage));
          _bloc.add(const ErrorShown());
        }else if(state.isRegistered){
          unawaited(CustomAnimatedToast.showSuccess(state.successMessage.isEmpty ? "Ariza yuborildi" : state.successMessage));
          _bloc.add(const SuccessShown());
        }
        
      },
      child: Scaffold(
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: ScreenSize.h10),
                    children: [
                      Gap(ScreenSize.h5),
                      Text(
                        "Roʻyxatdan oʻtish uchun maʼlumotlarni toʻldiring",
                        textAlign: TextAlign.center,
                        style: AppTheme.data.textTheme.titleSmall,
                      ),
    
                      Gap(ScreenSize.h10),
                      BlocSelector<RegistrationBloc, RegistrationState, String>(
                        selector: (state)=> state.selectedPartner?.title ?? "Taminotchi tanlang",
                        builder: (context, title) {
                          return SelectPartner(
                            hint: title,
                            title: "Taminotchi tanlang",
                            onChange: (){},
                            //onChange: () => showPartnerSelect(context, bloc),
                          );
                        },
                      ),
    
                      // Gap(ScreenSize.h12),
                      // DropDown(
                      //   title: "Filialni tanlang",
                      //   items: state.organizations,
                      //   selectItems: state.selectOrganization,
                      //   onChanged: (selected)=>bloc.add(Selected(selected: selected,type: 1))
                      // ),
                      
                      Gap(ScreenSize.h12),
                      TextInputWidget(
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        backColor: AppTheme.colors.white,
                        icon: AppIcons.star,
                        title: "To'liq ismi",
                        hint: "To'liq ism kiriting",
                        titleColor: AppTheme.colors.blackSoft,
                      ),
    
                      Gap(ScreenSize.h12),
                      TextInputWidget(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        backColor: AppTheme.colors.white,
                        formatters: [PhoneFormatter()],
                        icon: AppIcons.star,
                        title: "Telefon raqami",
                        hint: "+998",
                        titleColor: AppTheme.colors.blackSoft,
                      ),
    
                      Gap(ScreenSize.h12),
                      TextInputWidget(
                        controller: _loginController,
                        keyboardType: TextInputType.text,
                        backColor: AppTheme.colors.white,
                        icon: AppIcons.star,
                        title: "Login",
                        hint: "Loginni kiriting",
                        titleColor: AppTheme.colors.blackSoft,
                      ),
    
                      Gap(ScreenSize.h12),
                      TextInputWidget(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        backColor: AppTheme.colors.white,
                        icon: AppIcons.star,
                        title: "Parol",
                        hint: "Parolni kiriting",
                        titleColor: AppTheme.colors.blackSoft,
                      ),
    
                      Gap(ScreenSize.h50),
                      BlocSelector<RegistrationBloc, RegistrationState, bool>(
                        selector: (state) => state.isLoading,
                        builder: (context, isLoading) => MainButton(
                          text: "Tasdiqlash",
                          showLoading: isLoading,
                          onPressed: ()=>getIt<RegistrationBloc>().add(RegistrationSendData(
                            fullname: _fullNameController.text,
                            login: _loginController.text,
                            password: _passwordController.text,
                            phone: _phoneController.text,  
                          ))
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
