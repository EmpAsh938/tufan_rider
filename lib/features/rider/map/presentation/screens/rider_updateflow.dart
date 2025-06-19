import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_dropdown.dart';
import 'package:tufan_rider/core/widgets/custom_fileupload.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_state.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_state.dart';
import 'package:tufan_rider/features/rider/map/models/create_rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_response.dart';
import 'package:tufan_rider/features/rider/map/models/update_vehicle_model.dart';
import 'package:tufan_rider/features/rider/map/models/vehicle_response.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_state.dart';

class RiderUpdateflow extends StatefulWidget {
  const RiderUpdateflow({super.key});

  @override
  State<RiderUpdateflow> createState() => _RiderUpdateflowState();
}

enum UploadType {
  selfieUpload,
  profileUpload,
  licenseUpload,
  nationalIdUpload,
  citizenshipFrontUpload,
  citizenshipBackUpload,
  vehiclePictureUpload,
  billbookFrontUpload,
  billbookBackUpload,
}

class _RiderUpdateflowState extends State<RiderUpdateflow> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  // final TextEditingController wardPermanentController = TextEditingController();
  // final TextEditingController wardTemporaryController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController citizenshipController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController vehicleDateController = TextEditingController();
  final TextEditingController vehicleBrandController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController expiryLicenseController = TextEditingController();
  final TextEditingController issueLicenseController = TextEditingController();
  final TextEditingController registrationPlateController =
      TextEditingController();

  File? _imageFile;
  File? _licenseImageFile;
  File? _nationaIdImageFile;
  File? _selfieWithIdFile;
  File? _citizenshipFrontImageFile;
  File? _citizenshipBackImageFile;
  File? _vehiclePhotoFile;
  File? _billbookFrontFile;
  File? _billbookBackFile;
  LoginResponse? _loginResponse;
  RiderResponse? _riderResponse;
  VehicleResponseModel? _vehicleResponseModel;
  String? selectedBranch; // Changed from 'Choose branch'
  String? selectedPermanentProvince; // This is valid since it's in items
  String? selectedPermanentDistrict; // Changed from 'Choose permanent district'
  String? selectedTemporaryProvince; // Changed from 'Choose temporary province'
  String? selectedTemporaryDistrict; // Changed from 'Choose temporary district'
  String? vehicleType;
  String? idType;
  bool agreed = false;
  bool sameAsPermanent = false;

  int pages = 6;
  int maxUserDocUpload = 5;
  int maxVehicleDocUpload = 3;
  int currentUserUpload = 0;
  int currentVehicleDocUpload = 0;

  Future<void> _pickImage(UploadType uploadType) async {
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
      switch (uploadType) {
        case UploadType.profileUpload:
          setState(() => _imageFile = File(croppedFile.path));
          context.read<UpdateProfileCubit>().uploadProfile(
                File(croppedFile.path),
                _loginResponse!.user.id.toString(),
                _loginResponse!.token,
              );
          break;
        case UploadType.selfieUpload:
          setState(() => _selfieWithIdFile = File(croppedFile.path));
          final riderResponse = context.read<CreateRiderCubit>().riderResponse;

          if (riderResponse == null) {
            CustomToast.show(
              'Rider not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateRiderCubit>().uploadRiderDocuments(
                File(croppedFile.path),
                riderResponse.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
                'selfie',
              );
          break;
        case UploadType.licenseUpload:
          setState(() => _licenseImageFile = File(croppedFile.path));
          final riderResponse = context.read<CreateRiderCubit>().riderResponse;

          if (riderResponse == null) {
            CustomToast.show(
              'Rider not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateRiderCubit>().uploadRiderDocuments(
                File(croppedFile.path),
                riderResponse.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
                'license',
              );
          break;
        case UploadType.nationalIdUpload:
          setState(() => _nationaIdImageFile = File(croppedFile.path));
          final riderResponse = context.read<CreateRiderCubit>().riderResponse;

          if (riderResponse == null) {
            CustomToast.show(
              'Rider not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateRiderCubit>().uploadRiderDocuments(
                File(croppedFile.path),
                riderResponse.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
                'nid',
              );
          break;
        case UploadType.citizenshipFrontUpload:
          setState(() => _citizenshipFrontImageFile = File(croppedFile.path));
          final riderResponse = context.read<CreateRiderCubit>().riderResponse;

          if (riderResponse == null) {
            CustomToast.show(
              'Rider not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateRiderCubit>().uploadRiderDocuments(
                File(croppedFile.path),
                riderResponse.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
                'citizen_back',
              );
          break;
        case UploadType.citizenshipBackUpload:
          setState(() => _citizenshipBackImageFile = File(croppedFile.path));
          final riderResponse = context.read<CreateRiderCubit>().riderResponse;

          if (riderResponse == null) {
            CustomToast.show(
              'Rider not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateRiderCubit>().uploadRiderDocuments(
                File(croppedFile.path),
                riderResponse.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
                'citizen_front',
              );
          break;
        case UploadType.vehiclePictureUpload:
          setState(() => _vehiclePhotoFile = File(croppedFile.path));
          final vehicleResponseModel =
              context.read<CreateVehicleCubit>().vehicleResponseModel;

          if (vehicleResponseModel == null) {
            CustomToast.show(
              'Vehicle not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateVehicleCubit>().uploadVehicleDocuments(
                File(croppedFile.path),
                vehicleResponseModel.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
              );
          break;
        case UploadType.billbookFrontUpload:
          setState(() => _billbookFrontFile = File(croppedFile.path));
          final vehicleResponseModel =
              context.read<CreateVehicleCubit>().vehicleResponseModel;

          if (vehicleResponseModel == null) {
            CustomToast.show(
              'Vehicle not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateVehicleCubit>().uploadBillbookFront(
                File(croppedFile.path),
                vehicleResponseModel.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
              );
          break;
        case UploadType.billbookBackUpload:
          setState(() => _billbookBackFile = File(croppedFile.path));
          final vehicleResponseModel =
              context.read<CreateVehicleCubit>().vehicleResponseModel;

          if (vehicleResponseModel == null) {
            CustomToast.show(
              'Vehicle not found',
              context: context,
              toastType: ToastType.error,
            );
            return;
          }
          context.read<CreateVehicleCubit>().uploadBillbookBack(
                File(croppedFile.path),
                vehicleResponseModel.id.toString(),
                (vehicleType == null || vehicleType == '2 Wheeler') ? '1' : '2',
                _loginResponse!.token,
              );
          break;
      }
    }
  }

  void nextPage() {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPage == 0) {
      _saveProfile();
    } else if (_currentPage == 1) {
      _updateRider();
      // Send OTP
      // context.read<RegistrationCubit>().sendOtp(phoneController.text);
    } else if (_currentPage == 3) {
      _updateVehicle();
    } else if (_currentPage >= 5) {
      if (agreed) {
        CustomToast.show(
          'Rider update completed successfully',
          context: context,
          toastType: ToastType.success,
        );
        Navigator.pop(context);
      } else {
        CustomToast.show(
          'Please accept the terms & conditions to proceed',
          context: context,
          toastType: ToastType.error,
        );
      }
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
    if (!_pageController.hasClients) {
      return;
    }
    _pageController.animateToPage(
      currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _saveProfile() {
    if (_loginResponse == null) return;

    final userId = _loginResponse!.user.id;
    final token = _loginResponse!.token;

    final fullName =
        "${firstNameController.text} ${lastNameController.text}".trim();

    context.read<UpdateProfileCubit>().updateProfile(
          userId.toString(),
          token,
          fullName,
          _loginResponse!.user.email ?? '',
          _loginResponse!.user.mobileNo,
          '',
        );
  }

  void _updateRider() {
    if (_loginResponse == null || _riderResponse == null) return;

    if (_riderResponse == null) return;

    final token = _loginResponse!.token;

    final riderModel = CreateRiderModel(
      driverLicense: licenseController.text,
      dateOfBirth: dobController.text,
      nidNo: nationalIdController.text,
      citizenNo: citizenshipController.text,
    );

    context.read<CreateRiderCubit>().updateRider(
          _riderResponse!.id.toString(),
          token,
          riderModel,
        );
  }

  void _updateVehicle() {
    if (_loginResponse == null || _vehicleResponseModel == null) return;

    // final userId = _loginResponse!.user.id;
    final token = _loginResponse!.token;

    final vehicleModel = UpdateVehicleModel(
      categoryId: vehicleType == '2 Wheeler' ? 1 : 2,
      vehicleType: vehicleType ?? '4 Wheeler',
      vehicleBrand: vehicleBrandController.text,
      vehicleNumber: registrationPlateController.text,
      productionYear: vehicleDateController.text,
    );

    context.read<CreateVehicleCubit>().updateVehicle(
          _vehicleResponseModel!.id.toString(),
          token,
          vehicleModel,
        );
  }

  void fetchUser() {
    final authCubit = context.read<AuthCubit>();
    final loginResponse = authCubit.loginResponse;
    setState(() {
      _loginResponse = authCubit.loginResponse;

      if (loginResponse != null) {
        final name = loginResponse.user.name.split(' ');
        firstNameController.text = name[0];
        lastNameController.text = name[name.length - 1];
      }
    });
  }

  void fetchRider() {
    final createRiderCubit = context.read<CreateRiderCubit>();
    final riderResponse = createRiderCubit.riderResponse;
    setState(() {
      _riderResponse = riderResponse;

      if (riderResponse != null) {
        dobController.text = riderResponse.dateOfBirth;
        licenseController.text = riderResponse.driverLicense;
        nationalIdController.text = riderResponse.nidNo;
        citizenshipController.text = riderResponse.citizenNo;
      }
    });
  }

  void fetchVehicle() {
    final createVehicleCubit = context.read<CreateVehicleCubit>();
    final vehicleResponseModel = createVehicleCubit.vehicleResponseModel;
    setState(() {
      _vehicleResponseModel = vehicleResponseModel;

      if (vehicleResponseModel != null) {
        vehicleBrandController.text = vehicleResponseModel.vehicleBrand;
        registrationPlateController.text = vehicleResponseModel.vehicleNumber;
        vehicleDateController.text = vehicleResponseModel.productionYear;
        vehicleType = vehicleResponseModel.vehicleType;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchRider();
    fetchVehicle();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    dobController.dispose();
    vehicleDateController.dispose();
    vehicleBrandController.dispose();
    idController.dispose();
    licenseController.dispose();
    expiryLicenseController.dispose();
    issueLicenseController.dispose();
    registrationPlateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Rider Update Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MultiBlocListener(
          listeners: [
            BlocListener<UpdateProfileCubit, UpdateProfileState>(
              listener: (context, state) {
                if (state is UpdateProfileSuccess) {
                  CustomToast.show(
                    'Profile updated successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  animatePageSlide(_currentPage + 1);
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
            ),
            BlocListener<CreateRiderCubit, CreateRiderState>(
              listener: (context, state) {
                if (state is CreateRiderStateSuccess) {
                  CustomToast.show(
                    'Rider updated successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  animatePageSlide(_currentPage + 1);
                } else if (state is CreateRiderStateFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                } else if (state is CreateRiderUploadedSuccess) {
                  CustomToast.show(
                    'Document Uploaded successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  currentUserUpload++;
                  if (currentUserUpload == maxUserDocUpload) {
                    animatePageSlide(_currentPage + 1);
                  }
                } else if (state is CreateRiderUploadedFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                }
              },
            ),
            BlocListener<CreateVehicleCubit, CreateVehicleState>(
              listener: (context, state) {
                if (state is CreateVehicleSuccess) {
                  CustomToast.show(
                    'Vehicle updated successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  animatePageSlide(_currentPage + 1);
                } else if (state is CreateVehicleFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                } else if (state is CreateVehiclePhotoUploadSuccess) {
                  CustomToast.show(
                    'Vehicle Photo Uploaded successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  currentVehicleDocUpload++;
                  if (currentVehicleDocUpload == maxVehicleDocUpload) {
                    animatePageSlide(_currentPage + 1);
                  }
                } else if (state is CreateVehiclePhotoUploadFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                } else if (state is CreateVehicleBillbookFrontUploadSuccess) {
                  CustomToast.show(
                    'Billbook Front Uploaded successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  currentVehicleDocUpload++;
                  if (currentVehicleDocUpload == maxVehicleDocUpload) {
                    animatePageSlide(_currentPage + 1);
                  }
                } else if (state is CreateVehicleBillbookFrontUploadFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                } else if (state is CreateVehicleBillbookBackUploadSuccess) {
                  CustomToast.show(
                    'Billbook Back Uploaded successfully',
                    context: context,
                    toastType: ToastType.success,
                  );
                  currentVehicleDocUpload++;
                  if (currentVehicleDocUpload == maxVehicleDocUpload) {
                    animatePageSlide(_currentPage + 1);
                  }
                } else if (state is CreateVehicleBillbookBackUploadFailure) {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
              builder: (context, profileState) {
            return BlocBuilder<CreateVehicleCubit, CreateVehicleState>(
                builder: (context, vehicleState) {
              return BlocBuilder<CreateRiderCubit, CreateRiderState>(
                builder: (context, riderState) {
                  final isLoading = profileState is UpdateProfileLoading ||
                      profileState is UpdateProfileUploadLoading ||
                      riderState is CreateRiderStateLoading ||
                      vehicleState is CreateVehicleLoading;

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
                                profileUploadForm(),
                                licenseForm(),
                                userDocumentsUpload(),
                                vehicleForm(),
                                vehicleDocumentsUpload(),
                                finalRegistrationForm(),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize
                                .min, // Prevent full vertical expansion
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoading) ...[
                                    Center(
                                        child: CircularProgressIndicator(
                                      color: AppColors.neutralColor,
                                    ))
                                  ] else ...[
                                    // if (_currentPage > 0) ...[
                                    //   CustomButton(
                                    //       text: 'Back', onPressed: prevPage),
                                    //   SizedBox(
                                    //     width: 10,
                                    //   ),
                                    // ],
                                    if (_currentPage != 2)
                                      CustomButton(
                                          text: _currentPage < pages - 1
                                              ? 'Next'
                                              : 'Finish',
                                          onPressed: nextPage),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Page ${_currentPage + 1} of $pages',
                                style: AppTypography.paragraph,
                              ),
                              SizedBox(
                                  height:
                                      8), // Add spacing to separate the text and progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_currentPage + 1) / pages,
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
                  );
                },
              );
            });
          }),
        ),
      ),
    ));
  }

  Widget profileUploadForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickImage(
              UploadType.profileUpload), // The method to pick a new image
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
                        onPressed: () {
                          _pickImage(UploadType
                              .profileUpload); // The method to pick a new image
                        }),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: firstNameController,
          hintText: 'First Name',
          labelText: 'First Name',
          validator: FormValidator.validateFirstName,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: lastNameController,
          hintText: 'Last Name',
          labelText: 'Last Name',
          validator: FormValidator.validateLastName,
        ),
        const SizedBox(height: 20),
        // CustomTextField(
        //   controller: firstNameController,
        //   hintText: '',
        //   labelText: 'Phonenumber',
        // ),
        // const SizedBox(height: 20),
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
          validator: FormValidator.validateDob,
        ),
      ],
    );
  }

  // Widget addressForm() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Permanent Address",
  //         style: AppTypography.labelText,
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       CustomDropdownField(
  //         value: selectedPermanentProvince,
  //         items: ['Province Aa', 'Province Bb', 'Province Cc'],
  //         labelText: 'Select permanent province',
  //         hintText: 'Choose Permanent Province',
  //         onChanged: (value) {
  //           setState(() {
  //             selectedPermanentProvince = value;
  //           });
  //         },
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       CustomDropdownField(
  //           value: selectedPermanentDistrict,
  //           items: ['District Aa', 'District Bb', 'District Cc'],
  //           labelText: 'Select District',
  //           hintText: 'Choose Permanent District',
  //           onChanged: (value) {
  //             setState(() {
  //               selectedPermanentDistrict = value;
  //             });
  //           }),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       CustomTextField(
  //         controller: wardPermanentController,
  //         hintText: 'Ward No',
  //         labelText: 'Ward No',
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       CheckboxListTile(
  //         activeColor: AppColors.primaryColor,
  //         title: Text(
  //           "Set temporary address same as permanent address",
  //           style: AppTypography.labelText,
  //         ),
  //         contentPadding: EdgeInsets.zero, // Remove default padding
  //         controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
  //         value: sameAsPermanent,
  //         onChanged: (value) {
  //           setState(() {
  //             sameAsPermanent = value ?? false;
  //           });
  //         },
  //       ),
  //       if (!sameAsPermanent) ...[
  //         Text(
  //           "Temporary Address",
  //           style: AppTypography.labelText,
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         CustomDropdownField(
  //             value: selectedTemporaryProvince,
  //             items: ['Province A', 'Province B', 'Province C'],
  //             labelText: 'Select province',
  //             hintText: 'Choose Temporary Province',
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedTemporaryProvince = value;
  //               });
  //             }),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         CustomDropdownField(
  //             value: selectedTemporaryDistrict,
  //             items: ['District A', 'District B', 'District C'],
  //             labelText: 'Select district',
  //             hintText: 'Choose Temporary District',
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedTemporaryDistrict = value;
  //               });
  //             }),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         CustomTextField(
  //             controller: wardPermanentController,
  //             hintText: 'Ward No',
  //             labelText: 'Ward No'),
  //       ]
  //     ],
  //   );
  // }

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Select Vehicle Type",
          //   style: AppTypography.labelText,
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // CustomDropdownField(
          //     value: vehicleType,
          //     items: ['2 Wheeler', '4 Wheeler'],
          //     labelText: 'Select Vehicle Type',
          //     validator: FormValidator.validateDropdown,
          //     onChanged: (value) {
          //       setState(() {
          //         vehicleType = value;
          //       });
          //     }),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: licenseController,
            hintText: 'License Number',
            labelText: 'License Number',
            validator: FormValidator.validateLicense,
          ),

          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: nationalIdController,
            hintText: 'National ID',
            labelText: 'National ID',
            validator: FormValidator.validateNationalId,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: citizenshipController,
            hintText: 'Citizenship Number',
            labelText: 'Citizenship Number',
            validator: FormValidator.validateCitizenship,
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          // CustomTextField(
          //     controller: issueLicenseController,
          //     hintText: 'Issue Date',
          //     labelText: 'Issue Date'),
          // const SizedBox(
          //   height: 10,
          // ),
          // CustomTextField(
          //     controller: expiryLicenseController,
          //     hintText: 'Expiry Date',
          //     labelText: 'Expiry Date'),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget userDocumentsUpload() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload Documents",
            style: AppTypography.labelText,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomFileupload(
            label: 'Upload Selfie with Document',
            networkImageUrl: _riderResponse != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getImage(_riderResponse!.selfieWithIdCard)
                : null,
            pickedFile: _selfieWithIdFile,
            onTap: () => _pickImage(UploadType.selfieUpload),
          ),
          CustomFileupload(
            label: 'Upload License Photo',
            networkImageUrl: _riderResponse != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getImage(_riderResponse!.licenseImage)
                : null,
            pickedFile: _licenseImageFile,
            onTap: () => _pickImage(UploadType.licenseUpload),
          ),
          const SizedBox(
            height: 10,
          ),
          // CustomFileupload(
          //   label: 'Upload National ID Photo',
          //   pickedFile: _nationaIdImageFile,
          //   onTap: () => _pickImage(UploadType.nationalIdUpload),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          CustomFileupload(
            label: 'Upload Citizenship Front',
            networkImageUrl: _riderResponse != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getImage(_riderResponse!.citizenFront)
                : null,
            pickedFile: _citizenshipFrontImageFile,
            onTap: () => _pickImage(UploadType.citizenshipFrontUpload),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomFileupload(
            label: 'Upload Citizenship Back',
            networkImageUrl: _riderResponse != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getImage(_riderResponse!.citizenBack)
                : null,
            pickedFile: _citizenshipBackImageFile,
            onTap: () => _pickImage(UploadType.citizenshipBackUpload),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: CustomButton(
                text: 'Continue',
                onPressed: () {
                  animatePageSlide(_currentPage + 1);
                }),
          ),
        ],
      ),
    );
  }

  Widget vehicleForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Select Vehicle Type",
          //   style: AppTypography.labelText,
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // CustomDropdownField(
          //     value: vehicleType,
          //     items: ['2 Wheeler', '4 Wheeler'],
          //     labelText: 'Select Vehicle Type',
          //     validator: FormValidator.validateDropdown,
          //     onChanged: (value) {
          //       setState(() {
          //         vehicleType = value;
          //       });
          //     }),
          // const SizedBox(
          //   height: 10,
          // ),
          CustomTextField(
            controller: vehicleBrandController,
            hintText: 'Vehicle Brand',
            labelText: 'Vehicle Brand',
            validator: FormValidator.validateName,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: registrationPlateController,
            hintText: 'Registration Plate/Vehicle Number',
            labelText: 'Registration Plate/Vehicle Number',
            validator: FormValidator.validateName,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: vehicleDateController,
            hintText: '',
            labelText: 'Vehicle Date',
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
                vehicleDateController.text =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
            validator: FormValidator.validateDob,
          ),
          SizedBox(
            height: 10,
          ),

          // const SizedBox(
          //   height: 10,
          // ),
          // CustomFileupload(label: 'Tax Clearance', onTap: () {}),
          // const SizedBox(
          //   height: 10,
          // ),
          // CustomFileupload(label: 'Insurance', onTap: () {}),
        ],
      ),
    );
  }

  Widget vehicleDocumentsUpload() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload Documents",
            style: AppTypography.labelText,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomFileupload(
            label: 'Vehicle Photo',
            networkImageUrl: _vehicleResponseModel != null &&
                    _vehicleResponseModel!.vechicleImg != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getVehicelImage(
                        _vehicleResponseModel!.vechicleImg ?? '')
                : null,
            pickedFile: _vehiclePhotoFile,
            onTap: () => _pickImage(UploadType
                .vehiclePictureUpload), // The method to pick a new image
          ),
          const SizedBox(
            height: 10,
          ),
          CustomFileupload(
            label: 'Bill Book Front',
            networkImageUrl: _vehicleResponseModel != null &&
                    _vehicleResponseModel!.billBook1 != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getVehicelImage(
                        _vehicleResponseModel!.billBook1 ?? '')
                : null,
            pickedFile: _billbookFrontFile,
            onTap: () => _pickImage(UploadType.billbookFrontUpload),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomFileupload(
            label: 'Bill Book Back',
            networkImageUrl: _vehicleResponseModel != null &&
                    _vehicleResponseModel!.billBook2 != null
                ? ApiEndpoints.baseUrl +
                    ApiEndpoints.getVehicelImage(
                        _vehicleResponseModel!.billBook2 ?? '')
                : null,
            pickedFile: _billbookBackFile,
            onTap: () => _pickImage(UploadType.billbookBackUpload),
          ),
        ],
      ),
    );
  }

  Widget finalRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CustomDropdownField(
        //     value: selectedBranch,
        //     items: ['Branch A', 'Branch B', 'Branch C'],
        //     labelText: 'Select Nearest Branch',
        //     onChanged: (value) {
        //       setState(() {
        //         selectedBranch = value;
        //       });
        //     }),
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
