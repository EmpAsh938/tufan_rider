import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Image.asset('assets/icons/flag_nepal.png'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                labelText: 'Enter your password',
                obscureText: true,
                suffixIcon: Image.asset('assets/icons/hide-eye-crossbar.png'),
                suffixIconColor: AppColors.gray,
              ),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.pushNamed(context, '/map');
                      })),
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
                      }))
            ],
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
    return Image.asset('assets/images/tufan.png');
  }
}
