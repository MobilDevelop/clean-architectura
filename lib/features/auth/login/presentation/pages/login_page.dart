import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_event.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_state.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/features/auth/login/presentation/widgets/enter_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LoginBloc>();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppIcons.loginBack),fit: BoxFit.cover)),
          child: ListView(
            children: [
              BlocSelector<LoginBloc, LoginState, String>(
                selector: (state)=> state.errorMessage,
                builder: (context, message)=>Column(
                  children: [
                    Gap(message.isNotEmpty ? ScreenSize.h20 : ScreenSize.h40),
                    SvgPicture.asset(AppIcons.logo,height: ScreenSize.h55),
                    Gap(message.isNotEmpty ? ScreenSize.h20 : ScreenSize.h80),
                  ],
                ),
              ),
        
              
              Center(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  constraints: BoxConstraints(maxWidth: ScreenSize.h200 + ScreenSize.h200),
                  margin: EdgeInsets.symmetric(horizontal: ScreenSize.h15),
                  padding: EdgeInsets.symmetric(horizontal: ScreenSize.w18,vertical: ScreenSize.h18),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.white,
                    border: Border.all(color: AppTheme.colors.backcolor),
                    borderRadius: BorderRadius.circular(ScreenSize.r20),
                    boxShadow: AppShadow.raised()
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Tizimga kirish",style: AppTheme.data.textTheme.displayLarge!.copyWith(color: AppTheme.colors.blackSoft)),
                          
                      BlocSelector<LoginBloc, LoginState, ({String message, String deviceId})>(
                        selector: (state)=>(message: state.errorMessage, deviceId: state.deviceId),
                        builder: (context, state)=> Visibility(
                          visible: state.message.isNotEmpty,
                          child: EnterError(deviceId: state.deviceId, title: state.message)
                        ),
                      ),
                    
                      Gap(ScreenSize.h20),
                      BlocSelector<LoginBloc, LoginState, String>(
                        selector: (state)=>state.loginError,
                        builder: (context, error)=>TextInputWidget(
                          controller: _loginController,
                          title: "Login", 
                          hint: "Loginni kiriting",
                          onChanged: (value) => _bloc.add(LoginOnChanged(value: value)),
                          errorText: error.isNotEmpty ? error : null,
                        ),
                      ),
                    
                      Gap(ScreenSize.h20),
                      BlocSelector<LoginBloc, LoginState, ({bool showPassword,String error})>(
                        selector: (state)=> (showPassword: state.showPassword,error: state.passwordError),
                        builder: (context, state)=>TextInputWidget(
                          controller: _passwordController,
                          title: "Parol", 
                          hint: "Parolni kiriting",
                          errorText: state.error.isNotEmpty ? state.error : null,
                          isPassword: !state.showPassword,
                          suffixIcon: state.showPassword?AppIcons.eyeClose:AppIcons.eyeOpen,
                          onChanged: (value) => _bloc.add(PasswordOnChanged(value: value)),
                          suffixPress: () => _bloc.add(const LoginPasswordVisibilityToggled()),
                        ),
                      ),
                                  
                      Gap(ScreenSize.h35),
                      BlocSelector<LoginBloc, LoginState, bool>(
                        selector: (state)=> state.isLoading,
                        builder: (context, loading)=>MainButton(
                          text: "Kirish",
                          showLoading: loading,
                          onPressed: () => _bloc.add(LoginSubmitted(username: _loginController.text,password: _passwordController.text)),
                        ),
                      ),
                      Gap(ScreenSize.h10),
                    ],
                  ),
                ),
              ),
        
              Gap(ScreenSize.h20),
              Bounce(
                duration: Duration(milliseconds: AppConstants.duration),
                onTap: () => context.push(Routes.registration.path),
                child: Text("Ro'yxatdan o'tish",
                style: AppTheme.data.textTheme.headlineMedium!.copyWith(color: AppTheme.colors.blue),
                textAlign: TextAlign.center),
              ),
              
              Gap(ScreenSize.h100) 
            ],
          ),
        ),
      );
  }
}