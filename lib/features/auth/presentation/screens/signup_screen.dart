import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 3) {
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
    return SafeArea(
      child: Scaffold(
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
                    buildProfileScreen(),
                    buildPhoneEmailScreen(),
                    buildVerificationCodeScreen(),
                    buildPasswordBranchScreen(),
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
                        text: _currentPage < 3 ? 'Next' : 'Save',
                        onPressed: nextPage),
                    SizedBox(height: 8),
                    Text(
                      'Page ${_currentPage + 1} of 4',
                      style: AppTypography.paragraph,
                    ),
                    SizedBox(
                        height:
                            8), // Add spacing to separate the text and progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 4,
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
      ),
    );
  }

  Widget buildProfileScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Image.asset(
            Assets.images.tufan.path,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Signup',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.gray,
              child: Icon(
                Icons.camera_alt,
                size: 40,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: firstNameController,
            hintText: 'First Name',
            labelText: 'First Name',
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: lastNameController,
            hintText: 'Last Name',
            labelText: 'Last Name',
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: addressController,
            hintText: 'Address',
            labelText: 'Address',
          ),
          // const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildPhoneEmailScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Image.asset(
            Assets.images.tufan.path,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Signup',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: phoneController,
            hintText: 'Phone Number',
            labelText: 'Phone Number',
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: emailController,
            hintText: 'Email Address',
            labelText: 'Email Address',
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
            Assets.images.tufan.path,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Signup',
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

  Widget buildPasswordBranchScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Image.asset(
            Assets.images.tufan.path,
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Signup',
            style: AppTypography.paragraph,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CustomTextField(
            controller: passwordController,
            hintText: 'Set your password',
            labelText: 'Set your password',
            obscureText: true,
            suffixIcon: Image.asset(Assets.icons.hideEyeCrossbar.path),
            suffixIconColor: AppColors.gray,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: passwordController,
            hintText: 'Re-enter your password',
            labelText: 'Re-enter your password',
            obscureText: true,
            suffixIcon: Image.asset(Assets.icons.hideEyeCrossbar.path),
            suffixIconColor: AppColors.gray,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Text(
              "Select your nearest branch",
              style: AppTypography.labelText,
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.gray,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            items: ["Branch 1", "Branch 2", "Branch 3"].map((branch) {
              return DropdownMenuItem(
                value: branch,
                child: Text(branch),
              );
            }).toList(),
            onChanged: (value) {},
          ),
          // const SizedBox(height: 20),
          // CustomButton(text: 'Save', onPressed: () {}),
        ],
      ),
    );
  }
}
