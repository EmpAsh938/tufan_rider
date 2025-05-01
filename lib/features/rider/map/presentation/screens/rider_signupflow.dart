import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_dropdown.dart';
import 'package:tufan_rider/core/widgets/custom_fileupload.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';

class RiderSignupflow extends StatefulWidget {
  const RiderSignupflow({super.key});

  @override
  State<RiderSignupflow> createState() => _RiderSignupflowState();
}

class _RiderSignupflowState extends State<RiderSignupflow> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController wardPermanentController = TextEditingController();
  final TextEditingController wardTemporaryController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController expiryLicenseController = TextEditingController();
  final TextEditingController issueLicenseController = TextEditingController();
  final TextEditingController vehicleBrandController = TextEditingController();
  final TextEditingController registrationPlateController =
      TextEditingController();

  File? _imageFile;
  LoginResponse? _loginResponse;
  String? selectedBranch; // Changed from 'Choose branch'
  String? selectedPermanentProvince; // This is valid since it's in items
  String? selectedPermanentDistrict; // Changed from 'Choose permanent district'
  String? selectedTemporaryProvince; // Changed from 'Choose temporary province'
  String? selectedTemporaryDistrict; // Changed from 'Choose temporary district'
  String? idType;
  bool agreed = false;
  bool sameAsPermanent = false;

  Future<void> _pickImage() async {
    return;
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
      context.read<UpdateProfileCubit>().uploadProfile(
            File(croppedFile.path),
            _loginResponse!.user.id.toString(),
            _loginResponse!.token,
          );
    }
  }

  void nextPage() {
    animatePageSlide(_currentPage + 1); // For other pages (e.g., profile)

    if (!_formKey.currentState!.validate()) return;

    if (_currentPage == 1) {
      // Send OTP
      // context.read<RegistrationCubit>().sendOtp(phoneController.text);
    } else if (_currentPage == 2) {
      // verify OTP

      // context.read<RegistrationCubit>().verifyOtp(phoneController.text, otp);
    } else if (_currentPage == 3) {
      // handle final registration
      // final registrationRequest = RegistrationRequest(
      //   name: "${firstNameController.text} ${lastNameController.text}",
      //   email: emailController.text,
      //   mobileNo: phoneController.text,
      //   otp: otp,
      //   password: passwordController.text,
      //   // branchName: selectedBranch!,
      // );
      // context
      //     .read<RegistrationCubit>()
      //     .completeRegistration(registrationRequest);
    } else {
      animatePageSlide(_currentPage + 1); // For other pages (e.g., profile)
    }
  }

  void prevPage() {
    // if (_currentPage == 3) {
    animatePageSlide(_currentPage - 1);
    // }
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
        title: Text('Registration Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: AbsorbPointer(
            absorbing: false,
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
                      profileUploadForm(),
                      addressForm(),
                      idVerificationForm(),
                      licenseForm(),
                      vehicleForm(),
                      finalRegistrationForm(),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize:
                      MainAxisSize.min, // Prevent full vertical expansion
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (false) ...[
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neutralColor,
                            ),
                          )
                        ] else ...[
                          if (_currentPage > 0) ...[
                            CustomButton(text: 'Back', onPressed: prevPage),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                          CustomButton(
                              text: _currentPage < 5 ? 'Next' : 'Register',
                              onPressed: nextPage),
                        ]
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Page ${_currentPage + 1} of 6',
                      style: AppTypography.paragraph,
                    ),
                    SizedBox(
                        height:
                            8), // Add spacing to separate the text and progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 6,
                        backgroundColor: AppColors.gray,
                        color: AppColors.primaryColor,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget profileUploadForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage, // The method to pick a new image
          child: Center(
            child: Stack(
              clipBehavior: Clip.none, // Allows the icon to overflow the circle
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.gray.withOpacity(0.3),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_loginResponse?.user.imageName != null &&
                              _loginResponse!.user.imageName!.isNotEmpty)
                          ? NetworkImage(ApiEndpoints.baseUrl +
                              ApiEndpoints.getImage(
                                  _loginResponse!.user.imageName!))
                          : null,
                  child: _imageFile == null &&
                          (_loginResponse?.user.imageName == null ||
                              _loginResponse!.user.imageName!.isEmpty)
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.black54,
                        )
                      : null,
                ),

                // Edit icon button on top of the CircleAvatar
                if (_imageFile != null ||
                    _loginResponse?.user.imageName != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.black54,
                      ),
                      onPressed:
                          _pickImage, // Trigger the image picker when clicked
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: firstNameController,
          hintText: '',
          labelText: 'First Name',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: lastNameController,
          hintText: '',
          labelText: 'Last Name',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: firstNameController,
          hintText: '',
          labelText: 'Phonenumber',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: dobController,
          hintText: '',
          labelText: 'Date of Birth',
          readOnly: true,
          suffixIcon: Icon(
            Icons.date_range_outlined,
            size: 30,
            color: AppColors.primaryBlack.withOpacity(0.3),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            }
          },
        ),
      ],
    );
  }

  Widget addressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Permanent Address",
          style: AppTypography.labelText,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomDropdownField(
          value: selectedPermanentProvince,
          items: ['Province Aa', 'Province Bb', 'Province Cc'],
          labelText: 'Select permanent province',
          hintText: 'Choose Permanent Province',
          onChanged: (value) {
            setState(() {
              selectedPermanentProvince = value;
            });
          },
        ),
        const SizedBox(
          height: 10,
        ),
        CustomDropdownField(
            value: selectedPermanentDistrict,
            items: ['District Aa', 'District Bb', 'District Cc'],
            labelText: 'Select District',
            hintText: 'Choose Permanent District',
            onChanged: (value) {
              setState(() {
                selectedPermanentDistrict = value;
              });
            }),
        const SizedBox(
          height: 10,
        ),
        CustomTextField(
          controller: wardPermanentController,
          hintText: 'Ward No',
          labelText: 'Ward No',
        ),
        const SizedBox(
          height: 10,
        ),
        CheckboxListTile(
          activeColor: AppColors.primaryColor,
          title: Text(
            "Set temporary address same as permanent address",
            style: AppTypography.labelText,
          ),
          contentPadding: EdgeInsets.zero, // Remove default padding
          controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
          value: sameAsPermanent,
          onChanged: (value) {
            setState(() {
              sameAsPermanent = value ?? false;
            });
          },
        ),
        if (!sameAsPermanent) ...[
          Text(
            "Temporary Address",
            style: AppTypography.labelText,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownField(
              value: selectedTemporaryProvince,
              items: ['Province A', 'Province B', 'Province C'],
              labelText: 'Select province',
              hintText: 'Choose Temporary Province',
              onChanged: (value) {
                setState(() {
                  selectedTemporaryProvince = value;
                });
              }),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownField(
              value: selectedTemporaryDistrict,
              items: ['District A', 'District B', 'District C'],
              labelText: 'Select district',
              hintText: 'Choose Temporary District',
              onChanged: (value) {
                setState(() {
                  selectedTemporaryDistrict = value;
                });
              }),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
              controller: wardPermanentController,
              hintText: 'Ward No',
              labelText: 'Ward No'),
        ]
      ],
    );
  }

  Widget idVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownField(
          value: idType,
          labelText: 'Valid ID Type',
          items: ['Citizenship', 'Voter Card'],
          onChanged: (value) {
            setState(() {
              idType = value;
            });
          },
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextField(
          controller: idController,
          hintText: 'ID Number',
          labelText: 'ID Number',
        ),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Upload ID Photo', onTap: () {})
      ],
    );
  }

  Widget licenseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
            controller: licenseController,
            hintText: 'License Number',
            labelText: 'License Number'),
        const SizedBox(
          height: 10,
        ),
        CustomTextField(
            controller: issueLicenseController,
            hintText: 'Issue Date',
            labelText: 'Issue Date'),
        const SizedBox(
          height: 10,
        ),
        CustomTextField(
            controller: expiryLicenseController,
            hintText: 'Expiry Date',
            labelText: 'Expiry Date'),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Upload License Photo', onTap: () {})
      ],
    );
  }

  Widget vehicleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
            controller: vehicleBrandController,
            hintText: 'Vehicle Brand',
            labelText: 'Vehicle Brand'),
        const SizedBox(
          height: 10,
        ),
        CustomTextField(
            controller: registrationPlateController,
            hintText: 'Registration Plate',
            labelText: 'Registration Plate'),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Upload Documents",
          style: AppTypography.labelText,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Vehicle Photo', onTap: () {}),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Bill Book', onTap: () {}),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Vehicle Details', onTap: () {}),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Tax Clearance', onTap: () {}),
        const SizedBox(
          height: 10,
        ),
        CustomFileupload(label: 'Insurance', onTap: () {}),
      ],
    );
  }

  Widget finalRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownField(
            value: selectedBranch,
            items: ['Branch A', 'Branch B', 'Branch C'],
            labelText: 'Select Nearest Branch',
            onChanged: (value) {
              setState(() {
                selectedBranch = value;
              });
            }),
        CheckboxListTile(
          activeColor: AppColors.primaryColor,
          title: Text(
              "I agree to the Terms & Conditions, Privacy Policy and accept above details are true and accurate"),
          contentPadding: EdgeInsets.zero, // Remove default padding
          controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
          value: agreed,
          onChanged: (value) {
            setState(() {
              agreed = value ?? false;
            });
          }, // Set agreement
        ),
      ],
    );
  }
}
