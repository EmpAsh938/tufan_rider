import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/registration_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/registration_state.dart';
import 'package:tufan_rider/features/auth/models/otp_response.dart';
import 'package:tufan_rider/features/auth/models/registration_request.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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

  File? _imageFile;

  OtpResponse? _otpResponse;

  String? selectedBranch;

  Future<void> _pickImage() async {
    // Request permissions
    // final status = await Permission.photos.request();
    // if (!status.isGranted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Permission denied')),
    //   );
    //   return;
    // }

    // Pick image
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    // Crop image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
          resetButtonHidden: false,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        )
      ],
    );

    if (croppedFile != null) {
      setState(() => _imageFile = File(croppedFile.path));
    }
  }

  void nextPage() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPage == 1) {
      // Send OTP
      context.read<RegistrationCubit>().sendOtp(phoneController.text);
      animatePageSlide(_currentPage + 1);
    } else if (_currentPage == 2) {
      // Validate OTP
      String otp = _otpControllers.map((c) => c.text).join();

      if (_otpResponse == null) {
        CustomToast.show(
          'Retry sending OTP',
          context: context,
          toastType: ToastType.info,
        );
        animatePageSlide(_currentPage - 1); // Go back to phone input page
      } else if (otp == _otpResponse!.otp) {
        CustomToast.show(
          'Verified Successfully',
          context: context,
          toastType: ToastType.success,
        );
        animatePageSlide(_currentPage + 1); // Go to next page
      } else {
        CustomToast.show(
          'Invalid OTP',
          context: context,
          toastType: ToastType.error,
        );
      }
    } else if (_currentPage == 3) {
      // handle final registration
      final registrationRequest = RegistrationRequest(
        name: "${firstNameController.text} ${lastNameController.text}",
        email: emailController.text,
        mobileNo: phoneController.text,
        otp: _otpResponse!.otp,
        password: passwordController.text,
        branchName: selectedBranch!,
      );
      context
          .read<RegistrationCubit>()
          .completeRegistration(registrationRequest);
    } else {
      animatePageSlide(_currentPage + 1); // For other pages (e.g., profile)
    }
  }

  void prevPage() {
    if (_currentPage == 1) {
      animatePageSlide(_currentPage - 1);
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
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: const EdgeInsets.only(
            top: 80,
          ),
          child: BlocConsumer<RegistrationCubit, RegistrationState>(
              listener: (context, state) {
            // Listen for specific state changes and show dialogs or error messages
            if (state is OtpSendFailure) {
              CustomToast.show(
                state.message,
                context: context,
                toastType: ToastType.error,
              );
            } else if (state is ProfileUploadFailure) {
              CustomToast.show(
                state.message,
                context: context,
                toastType: ToastType.error,
              );
            } else if (state is RegistrationFailure) {
              CustomToast.show(
                state.message,
                context: context,
                toastType: ToastType.error,
              );
            }

            if (state is OtpSent) {
              _otpResponse = state.otpResponse;
              CustomToast.show(
                'OTP sent successfully',
                context: context,
                toastType: ToastType.success,
              );
              animatePageSlide(_currentPage + 1);
            }

            // Handle other state changes, like success or OTP sent
            if (state is RegistrationCompleted) {
              context
                  .read<RegistrationCubit>()
                  .uploadProfile(_imageFile!, state.user.id.toString());
            }

            if (state is ProfileUploaded) {
              // Navigate to the next screen or show a success dialog
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          }, builder: (context, state) {
            final isLoading = state is RegistrationLoading;

            return Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: isLoading,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoading) ...[
                                Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.neutralColor,
                                  ),
                                )
                              ] else ...[
                                if (_currentPage > 0) ...[
                                  CustomButton(
                                      text: 'Back', onPressed: prevPage),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                                CustomButton(
                                    text:
                                        _currentPage < 3 ? 'Next' : 'Register',
                                    onPressed: nextPage),
                              ]
                            ],
                          ),
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
            );
          }),
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
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null
                  ? const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: firstNameController,
            hintText: 'First Name',
            labelText: 'First Name',
            validator: FormValidator.validateFirstName,
            onChanged: (_) => _formKey.currentState
                ?.validate(), // 👈 Trigger validation on change
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: lastNameController,
            hintText: 'Last Name',
            labelText: 'Last Name',
            validator: FormValidator.validateLastName,
            onChanged: (_) => _formKey.currentState
                ?.validate(), // 👈 Trigger validation on change
          ),
          // const SizedBox(height: 10),
          // CustomTextField(
          //   controller: addressController,
          //   hintText: 'Address',
          //   labelText: 'Address',
          // ),
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
            validator: FormValidator.validatePhone,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: emailController,
            hintText: 'Email Address',
            labelText: 'Email Address',
            validator: FormValidator.validateEmail,
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
                        _formKey.currentState?.validate();
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
            validator: FormValidator.validatePassword,
            isPasswordField: true,
            onChanged: (_) => _formKey.currentState?.validate(),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: confirmPasswordController,
            hintText: 'Re-enter your password',
            labelText: 'Re-enter your password',
            obscureText: true,
            suffixIcon: Image.asset(Assets.icons.hideEyeCrossbar.path),
            suffixIconColor: AppColors.gray,
            isPasswordField: true,
            onChanged: (_) => _formKey.currentState?.validate(),
            validator: (value) => FormValidator.validateConfirmPassword(
              value,
              passwordController.text,
            ),
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
            dropdownColor: AppColors.backgroundColor,
            value: selectedBranch,
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
            onChanged: (value) {
              selectedBranch = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a branch';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
