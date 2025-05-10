import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/form_validator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/cubit/emergency_cubit.dart';
import 'package:tufan_rider/features/map/cubit/emergency_state.dart';
import 'package:tufan_rider/features/map/models/emergency_contact_model.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';
import 'package:tufan_rider/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  LoginResponse? _loginResponse;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void fetchContactLists() {
    final loginResponse = context.read<AuthCubit>().loginResponse;
    if (loginResponse != null) {
      _loginResponse = loginResponse;
      final userId = loginResponse.user.id.toString();
      final token = loginResponse.token;
      context.read<EmergencyCubit>().getEmergencyContactsForUser(userId, token);
    }
  }

  void showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        bool isLoading = false; // Track loading state

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Emergency Contact',
                          style: AppTypography.labelText.copyWith(
                            color: AppColors.primaryBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextField(
                                controller: nameController,
                                hintText: 'Enter full name',
                                labelText: 'Name',
                                keyboardType: TextInputType.name,
                                validator: FormValidator.validateName,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: mobileController,
                                hintText: 'Enter mobile number',
                                labelText: 'Mobile Number',
                                keyboardType: TextInputType.phone,
                                validator: FormValidator.validatePhone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  onPressed: isLoading
                                      ? () {}
                                      : () => Navigator.pop(context),
                                  backgroundColor: AppColors.backgroundColor,
                                  textColor:
                                      AppColors.primaryBlack.withOpacity(0.6),
                                  text: 'Cancel',
                                  isOutlined: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  onPressed: isLoading
                                      ? () {}
                                      : () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            setState(() => isLoading = true);

                                            final name =
                                                nameController.text.trim();
                                            final mobile =
                                                mobileController.text.trim();

                                            if (_loginResponse != null) {
                                              try {
                                                final userId = _loginResponse!
                                                    .user.id
                                                    .toString();
                                                final token =
                                                    _loginResponse!.token;

                                                final isAdded = await context
                                                    .read<EmergencyCubit>()
                                                    .addEmergencyContact(
                                                      userId,
                                                      name,
                                                      mobile,
                                                      token,
                                                    );

                                                if (isAdded) {
                                                  Navigator.pop(context);
                                                  CustomToast.show(
                                                    'Contact added successfully',
                                                    context: context,
                                                    toastType:
                                                        ToastType.success,
                                                  );
                                                } else {
                                                  CustomToast.show(
                                                    'Failed to add contact',
                                                    context: context,
                                                    toastType: ToastType.error,
                                                  );
                                                }
                                              } catch (e) {
                                                CustomToast.show(
                                                  'An error occurred',
                                                  context: context,
                                                  toastType: ToastType.error,
                                                );
                                              } finally {
                                                if (mounted) {
                                                  setState(
                                                      () => isLoading = false);
                                                }
                                              }
                                            }
                                          }
                                        },
                                  text: 'Add',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchContactLists();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    mobileController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title: 'Emergency',
      child: BlocBuilder<EmergencyCubit, EmergencyState>(
        builder: (context, state) {
          final isLoading = state is EmergencyLoading;
          final emergencyContactLists =
              context.read<EmergencyCubit>().emergencyContactLists;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Options Section
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEmergencyOption(
                        Assets.icons.contact.path,
                        'Emergency Contact Lists',
                      ),
                      const SizedBox(width: 24),
                      _buildEmergencyOption(
                        Assets.icons.alert.path,
                        'Emergency Alert',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Descriptions
                _buildDescriptionCard(
                  icon: Assets.icons.warning.path,
                  text:
                      'On pressing emergency contact lists, the contacts you have added will get notified about your situation.',
                ),
                const SizedBox(height: 16),
                _buildDescriptionCard(
                  icon: Assets.icons.warning.path,
                  text:
                      'On pressing emergency Alert, your call will be redirected to Nepal Police.',
                ),
                const SizedBox(height: 24),

                // Contacts List Header
                Text(
                  'Emergency Contact Lists',
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Contacts List
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : emergencyContactLists.isEmpty
                        ? _buildEmptyState()
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: emergencyContactLists.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final contact = emergencyContactLists[index];
                                return _buildContactItem(contact);
                              },
                            ),
                          ),
                const SizedBox(height: 24),

                // Add Contact Button
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Add Contact',
                    onPressed: () => showEmergencyDialog(context),
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.primaryWhite,
                    height: 48,
                    width: 160,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyOption(String imagePath, String title) {
    return GestureDetector(
      onTap: () {
        if (title == 'Emergency Alert') {
          _makeEmergencyCall(context);
        }
        // For 'Emergency Contact Lists', you can add other functionality if needed
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: AppTypography.labelText.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard({required String icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
            color: AppColors.primaryRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.labelText.copyWith(
                color: AppColors.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            Assets.icons.contact.path,
            width: 80,
            height: 80,
            color: AppColors.gray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No emergency contacts added',
            style: AppTypography.labelText.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(EmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Contact Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: AppTypography.labelText.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.mobile,
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryBlack.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => _showDeleteConfirmationDialog(context, contact),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.primaryRed,
              size: 24,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Deletion',
                style: AppTypography.labelText.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete ${contact.name} (${contact.mobile}) from emergency contacts?',
                style: AppTypography.labelText,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: AppTypography.labelText.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    backgroundColor: AppColors.primaryRed,
                    onPressed: () {
                      Navigator.pop(context);
                      final token = _loginResponse?.token;
                      if (token != null) {
                        context.read<EmergencyCubit>().deleteEmergencyContact(
                              contact.econtactId.toString(),
                              token,
                            );
                      }
                    },
                    text: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to your widget class
  void _makeEmergencyCall(BuildContext context) async {
    const policeNumber = '100'; // Nepal Police emergency number

    // Show confirmation dialog
    final shouldCall = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Emergency Call',
              style: AppTypography.labelText.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'This will call Nepal Police immediately. Proceed?',
              style: AppTypography.labelText,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryBlack.withOpacity(0.6),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Call',
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldCall) {
      try {
        // Use url_launcher package to make the call
        final Uri url = Uri(scheme: 'tel', path: policeNumber);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          CustomToast.show(
            'Could not launch phone app',
            context: context,
            toastType: ToastType.error,
          );
        }
      } catch (e) {
        CustomToast.show('Error making call',
            context: context, toastType: ToastType.error);
      }
    }
  }
}
