import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final PageController _pageController = PageController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(
          top: 80,
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  buildPhoneScreen(),
                  buildVerificationCodeScreen(),
                  buildPasswordScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Prevent full vertical expansion
                children: [
                  CustomButton(
                      text: _currentPage < 2 ? 'Next' : 'Save',
                      onPressed: nextPage),
                  SizedBox(height: 8),
                  Text(
                    'Page ${_currentPage + 1} of 3',
                    style: AppTypography.paragraph,
                  ),
                  SizedBox(
                      height:
                          8), // Add spacing to separate the text and progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
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
    );
  }

  Widget buildPhoneScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/tufan.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Reset Password',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: phoneController,
            hintText: 'Phone Number',
            labelText: 'Phone Number',
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
          Image.asset(
            'assets/images/tufan.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Reset Password',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Text(
            "Verify 6-digit verification code",
            style: AppTypography.labelText,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 20),
          // CustomButton(text: 'Next', onPressed: nextPage),
        ],
      ),
    );
  }

  Widget buildPasswordScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/tufan.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Reset Password',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: passwordController,
            hintText: 'Set your password',
            labelText: 'Set your password',
            obscureText: true,
            suffixIcon: Image.asset('assets/icons/hide-eye-crossbar.png'),
            suffixIconColor: AppColors.gray,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: passwordController,
            hintText: 'Re-enter your password',
            labelText: 'Re-enter your password',
            obscureText: true,
            suffixIcon: Image.asset('assets/icons/hide-eye-crossbar.png'),
            suffixIconColor: AppColors.gray,
          ),

          // const SizedBox(height: 20),
          // CustomButton(text: 'Save', onPressed: () {}),
        ],
      ),
    );
  }
}
