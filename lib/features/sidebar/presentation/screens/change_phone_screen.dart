import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  final PageController _pageController = PageController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController phoneController = TextEditingController();

  int _currentPage = 0;

  void nextPage() {
    animatePageSlide(_currentPage + 1);
    if (_currentPage == 0) {
      // context.read<ForgotPasswordCubit>().sendOtp(phoneController.text);
    } else if (_currentPage == 1) {
      // String otp = _otpControllers.map((c) => c.text).join();

      // context.read<ForgotPasswordCubit>().verifyOtp(phoneController.text, otp);
    } else if (_currentPage == 2) {
      // String otp = _otpControllers.map((c) => c.text).join();

      // context
      //     .read<ForgotPasswordCubit>()
      //     .resetPassword(phoneController.text, otp, passwordController.text);
    }
  }

  void animatePageSlide(int currentPage) {
    _pageController.animateToPage(
      currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                    CustomButton(
                        text: _currentPage < 1 ? 'Next' : 'Save',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            nextPage();
                          }
                        }),
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
          const SizedBox(height: 30),
          Text(
            "Verify 6-digit verification code",
            style: AppTypography.labelText,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 40,
                child: KeyboardListener(
                  focusNode: FocusNode(), // Needed for RawKeyboardListener
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _otpControllers[index].text.isEmpty &&
                        index > 0) {
                      _focusNodes[index - 1].requestFocus();
                      _otpControllers[index - 1].clear();
                    }
                  },
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.gray),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                        // _formKey.currentState?.validate();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                  ),
                ),
              );
            }),
          ),
          // const SizedBox(height: 20),
          // CustomButton(text: 'Next', onPressed: nextPage),
        ],
      ),
    );
  }
}
