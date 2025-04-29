import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_state.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool _isEditing = false;
  File? _imageFile;
  LoginResponse? _loginResponse;

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
      context.read<UpdateProfileCubit>().uploadProfile(
            File(croppedFile.path),
            _loginResponse!.user.id.toString(),
            _loginResponse!.token,
          );
    }
  }

  @override
  void initState() {
    super.initState();
    final loginResponse = context.read<AuthCubit>().loginResponse;
    _loginResponse = loginResponse;
    if (loginResponse != null) {
      final name = loginResponse.user.name.split(' ');
      firstNameController.text = name[0];
      lastNameController.text = name.length == 1 ? '' : name[name.length - 1];
      emailController.text = loginResponse.user.email;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final authCubit = context.read<AuthCubit>();
    final loginResponse = authCubit.loginResponse;

    if (loginResponse == null) return;

    final userId = loginResponse.user.id;
    final token = loginResponse.token;

    final fullName =
        "${firstNameController.text} ${lastNameController.text}".trim();
    final email = emailController.text.trim();

    // Call updateProfile
    context.read<UpdateProfileCubit>().updateProfile(
          userId.toString(),
          token,
          fullName,
          email,
          loginResponse.user.mobileNo,
          '',
        );

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title: 'Personal Information',
      child: BlocListener<UpdateProfileCubit, UpdateProfileState>(
        listener: (context, state) {
          if (state is UpdateProfileSuccess) {
            CustomToast.show(
              'Profile updated successfully',
              context: context,
              toastType: ToastType.success,
            );
            setState(() {
              _isEditing = false;
            });
          } else if (state is UpdateProfileUploadSuccess) {
            CustomToast.show(
              'Profile pic uploaded successfully',
              context: context,
              toastType: ToastType.success,
            );
          } else if (state is UpdateProfileUploadFailure) {
            CustomToast.show(
              state.message,
              context: context,
              toastType: ToastType.error,
            );
          } else if (state is UpdateProfileFailure) {
            CustomToast.show(
              state.message,
              context: context,
              toastType: ToastType.error,
            );
          }
        },
        child: BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
          builder: (context, state) {
            final isLoading = state is UpdateProfileLoading ||
                state is UpdateProfileUploadLoading;

            if (isLoading) {
              return Center(
                  child: CircularProgressIndicator(
                color: AppColors.neutralColor,
              ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage, // The method to pick a new image
                  child: Center(
                    child: Stack(
                      clipBehavior:
                          Clip.none, // Allows the icon to overflow the circle
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.gray.withOpacity(0.3),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_loginResponse?.user.imageName != null &&
                                      _loginResponse!
                                          .user.imageName!.isNotEmpty)
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
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: lastNameController,
                  hintText: '',
                  labelText: 'Last Name',
                  enabled: _isEditing,
                ),
                const SizedBox(height: 20),
                // CustomTextField(
                //   controller: emailController,
                //   hintText: '',
                //   labelText: 'Email',
                //   enabled: _isEditing,
                // ),
                // SizedBox(
                //   height: 50,
                // ),
                if (!_isEditing)
                  CustomButton(
                    text: 'Edit',
                    backgroundColor: AppColors.neutralColor,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                if (_isEditing)
                  CustomButton(
                    text: state is UpdateProfileLoading ? 'Saving...' : 'Save',
                    onPressed: _saveProfile,
                    // isLoading: state is UpdateProfileLoading, // if your button supports loading
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
