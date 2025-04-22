import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imepay_merchant_sdk/start_sdk.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/utils/random_id_generator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/auth_state.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final merchantCode = 'DEMOIMEP';
  final merchantName = 'IME Pay Demo';
  final merchantUrl =
      'https://stg.imepay.com.np:7979/api/sdk/recordTransaction';
  final amount = '100';
  final module = 'DEMOIMEP';
  final user = 'demoimepay';
  final password = 'IMEPay@123';
  final deliveryUrl = 'http://172.20.22.11:1717/api/sdk/deliveryService';
  final buildType = BuildType.STAGE;

  void _initiatePayment(BuildContext context) async {
    final refId = generateRandomId();

    try {
      var result = await StartSdk.callSdk(
        context,
        merchantCode: merchantCode,
        merchantName: merchantName,
        merchantUrl: merchantUrl,
        amount: amount,
        refId: refId,
        module: module,
        user: user,
        password: password,
        deliveryUrl: deliveryUrl,
        buildType: buildType,
      );

      print(result.toString());
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child:
                BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
              if (state is AuthSuccess) {
                CustomToast.show(
                  'Login Success',
                  context: context,
                  toastType: ToastType.success,
                );
                phoneController.clear();
                passwordController.clear();
                Navigator.pushReplacementNamed(context, AppRoutes.map);
              } else if (state is AuthFailure) {
                CustomToast.show(
                  state.message,
                  context: context,
                  toastType: ToastType.error,
                );
              }
            }, builder: (context, state) {
              final isLoading = state is AuthLoading;
              return AbsorbPointer(
                absorbing: isLoading,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      const LogoWidget(),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: phoneController,
                        hintText: '98XXXXXXXX',
                        labelText: 'Enter your mobile number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        prefixIcon: Image.asset(Assets.icons.flagNepal.path),
                        validator: FormValidator.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        labelText: 'Enter your password',
                        obscureText: true,
                        suffixIconColor: AppColors.gray,
                        validator: FormValidator.validatePassword,
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: const CircularProgressIndicator(
                                    color: AppColors.neutralColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : CustomButton(
                                text: 'Login',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().login(
                                          phoneController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                  }
                                },
                                // Add loading indicator if you have one
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset');
                        },
                        child: Text(
                          'Forgotten Password?',
                          style: AppTypography.paragraph,
                        ),
                      ),
                      Divider(
                        color: AppColors.gray,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                              text: 'Register here',
                              backgroundColor: AppColors.neutralColor,
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              })),
                      const SizedBox(height: 8),
                      // SizedBox(
                      //     width: double.infinity,
                      //     child: CustomButton(
                      //       text: 'Payment',
                      //       backgroundColor: AppColors.primaryRed,
                      //       onPressed: () => _initiatePayment(context),
                      //       // Navigator.pushNamed(context, '/signup');
                      //     ))
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.images.tufan.path);
  }
}
