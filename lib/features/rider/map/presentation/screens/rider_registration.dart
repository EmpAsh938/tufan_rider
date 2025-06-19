import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_state.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_cubit.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_map_screen.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RiderRegistration extends StatefulWidget {
  const RiderRegistration({super.key});

  @override
  State<RiderRegistration> createState() => _RiderRegistrationState();
}

class _RiderRegistrationState extends State<RiderRegistration> {
  void getRiderByUser() {
    final loginResponse = context.read<AuthCubit>().loginResponse;
    if (loginResponse != null) {
      context
          .read<CreateRiderCubit>()
          .getRiderByUser(loginResponse.user.id.toString());
    }
  }

  void getVehicle() {
    final loginResponse = context.read<AuthCubit>().loginResponse;
    if (loginResponse != null) {
      context
          .read<CreateVehicleCubit>()
          .getVehicle(loginResponse.user.id.toString(), '');
    }
  }

  @override
  void initState() {
    super.initState();
    getRiderByUser();
    getVehicle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: BlocListener<CreateRiderCubit, CreateRiderState>(
              listenWhen: (previous, current) =>
                  current is! CreateRiderStateLoading &&
                  current is! CreateRiderStateFailure,
              listener: (context, state) {
                final riderResponse =
                    context.read<CreateRiderCubit>().riderResponse;
                if (riderResponse != null &&
                    riderResponse.status.toLowerCase() == 'approved') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RiderMapScreen()),
                  );
                }
              },
              child: BlocBuilder<CreateRiderCubit, CreateRiderState>(
                builder: (context, state) {
                  if (state is CreateRiderStateLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  // if (state is CreateRiderStateFailure) {
                  //   CustomToast.show(
                  //     state.message,
                  //     context: context,
                  //     toastType: ToastType.error,
                  //   );
                  // }

                  final riderResponse =
                      context.read<CreateRiderCubit>().riderResponse;

                  // Case 2: Rider exists but pending approval
                  if (riderResponse != null &&
                      riderResponse.status.toLowerCase() == 'pending') {
                    return _buildPendingApprovalUI();
                  }
                  if (riderResponse != null &&
                      riderResponse.status.toLowerCase() == 'rejected') {
                    return _buildRejectedUI();
                  }

                  // Case 3: No rider exists (default case)
                  return _buildRegistrationPromptUI();
                },
              ))),
      drawer: CustomDrawer(),
    );
  }

  Widget _buildPendingApprovalUI() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_top,
                  size: 100,
                  color: AppColors.neutralColor,
                ),
                const SizedBox(height: 32),
                Text(
                  "Your application is under review",
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Our team is verifying your details. "
                  "You'll receive a notification once approved.",
                  textAlign: TextAlign.center,
                  style: AppTypography.labelText,
                ),
                const SizedBox(height: 32),
                SizedBox(height: 20),
                CustomButton(
                  text: "Update Documents here",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.riderUpdateflow);
                  },
                ),
                // TextButton(
                //   onPressed: () {
                //     // Optionally: Contact support or check status
                //   },
                //   child: Text("Contact Support"),
                // ),
              ],
            ),
          ),
        ),
        _buildDrawerButton(), // Your existing drawer button
      ],
    );
  }

  Widget _buildRegistrationPromptUI() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.images.tufan.path,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  "Not registered yet?",
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "Register here",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.riderSignupFlow);
                  },
                ),
              ],
            ),
          ),
        ),
        _buildDrawerButton(), // Your existing drawer button
      ],
    );
  }

  Widget _buildDrawerButton() {
    return Positioned(
        top: 10,
        left: 10,
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlack.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(
                  Icons.menu,
                  color: AppColors.primaryBlack,
                  size: 30,
                ),
              );
            },
          ),
        ));
  }

  Widget _buildRejectedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              'Your application has been rejected.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please contact support or try again later.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Update Documents here",
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.riderUpdateflow);
              },
            ),
          ],
        ),
      ),
    );
  }
}
