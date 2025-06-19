import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  final PageController _pageController = PageController();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int _currentPage = 0;

  void backPage() {
    if (_currentPage > 0) {
      animatePageSlide(_currentPage - 1);
    }
  }

  void nextPage() {
    if (_currentPage == 1) {
      updateProfile();
    } else {
      animatePageSlide(_currentPage + 1);
    }
  }

  void animatePageSlide(int currentPage) {
    _pageController.animateToPage(
      currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> updateProfile() async {
    try {
      final authCubit = context.read<AuthCubit>();
      final updateProfileCubit = context.read<UpdateProfileCubit>();
      final loginResponse = authCubit.loginResponse;
      if (loginResponse == null) return;
      await updateProfileCubit.updateProfile(
        loginResponse.user.id.toString(),
        loginResponse.token,
        loginResponse.user.name,
        loginResponse.user.email ?? '',
        phoneController.text,
        passwordController.text,
      );

      CustomToast.show(
        'Phonenumber changed successfully',
        context: context,
        toastType: ToastType.success,
      );
      locator.get<AuthCubit>().logout();
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
    } catch (e) {
      CustomToast.show(
        e.toString(),
        context: context,
        toastType: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Change Phone'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  buildPhoneScreen(),
                  buildVerificationCodeScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Prevent full vertical expansion
                children: [
                  if (false) ...[
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neutralColor,
                      ),
                    )
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'Back',
                          onPressed: backPage,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomButton(
                            text: _currentPage < 1 ? 'Next' : 'Save',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                nextPage();
                              }
                            }),
                      ],
                    ),
                  ],
                  SizedBox(height: 8),
                  Text(
                    'Page ${_currentPage + 1} of 2',
                    style: AppTypography.paragraph,
                  ),
                  SizedBox(
                      height:
                          8), // Add spacing to separate the text and progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 2,
                      backgroundColor: AppColors.gray,
                      color: AppColors.primaryColor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget buildPhoneScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Image.asset(
          //   Assets.images.tufan.path,
          //   height: 80,
          //   fit: BoxFit.contain,
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Change Phonenumber',
          //   style: AppTypography.paragraph,
          //   textAlign: TextAlign.center,
          // ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: phoneController,
            hintText: 'Phone Number',
            labelText: 'Phone Number',
            validator: FormValidator.validatePhone,
            onChanged: (_) => _formKey.currentState?.validate(),
          ),
          // const SizedBox(height: 20),
          // CustomButton(text: 'Next', onPressed: nextPage),
        ],
      ),
    );
  }

  Widget buildVerificationCodeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Image.asset(
          //   Assets.images.tufan.path,
          //   height: 80,
          //   fit: BoxFit.contain,
          // ),
          // const SizedBox(height: 8),
          // Text(
          //   'Change Phonenumber',
          //   style: AppTypography.paragraph,
          //   textAlign: TextAlign.center,
          // ),

          CustomTextField(
            controller: passwordController,
            hintText: 'Enter your password',
            labelText: 'Enter your password',
            obscureText: true,
            suffixIconColor: AppColors.gray,
            validator: FormValidator.validatePassword,
            isPasswordField: true,
            onChanged: (_) => _formKey.currentState?.validate(),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: confirmPasswordController,
            hintText: 'Confirm your password',
            labelText: 'Confirm your password',
            obscureText: true,
            suffixIconColor: AppColors.gray,
            validator: (value) => FormValidator.validateConfirmPassword(
              value,
              passwordController.text,
            ),
            isPasswordField: true,
            onChanged: (_) => _formKey.currentState?.validate(),
          ),
        ],
      ),
    );
  }
}
