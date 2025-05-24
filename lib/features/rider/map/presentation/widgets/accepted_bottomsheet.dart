import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/model/ride_message_model.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  final RideRequestModel request;
  const AcceptedBottomsheet(
      {super.key, required this.onPressed, required this.request});

  @override
  State<AcceptedBottomsheet> createState() => _AcceptedBottomsheetState();
}

class _AcceptedBottomsheetState extends State<AcceptedBottomsheet> {
  Timer? _locationTimer;
  bool _passengerPicked = false;

  Future<void> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  void startSendingRiderLiveLocation() async {
    if (_locationTimer != null) return; // already sending

    await ensureLocationPermission();

    _locationTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final RideMessageModel rideMessageModel = RideMessageModel(
          latitude: position.latitude,
          longitude: position.longitude,
          type:
              'rider-${widget.request.user.id.toString()}-${widget.request.rideRequestId.toString()}',
          userId: widget.request.user.id,
          rideRequestId: widget.request.rideRequestId,
        );

        print(rideMessageModel.toJson());

        context.read<StompSocketCubit>().sendMessage(rideMessageModel);
      } catch (e) {
        print('❌ Failed to get location or send message: $e');
      }
    });
  }

  void stopSendingRiderLiveLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _markPassengerPicked() async {
    final loginResponse = context.read<AuthCubit>().loginResponse;
    if (loginResponse == null) return;

    final isPicked = await context.read<AddressCubit>().pickupPassenger(
          widget.request.rideRequestId.toString(),
          loginResponse.token,
        );

    if (isPicked) {
      setState(() {
        _passengerPicked = true;
      });
      CustomToast.show(
        'Passenger marked as picked',
        context: context,
        toastType: ToastType.success,
      );
    } else {
      CustomToast.show(
        'Failed to mark passenger as picked',
        context: context,
        toastType: ToastType.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startSendingRiderLiveLocation();
  }

  @override
  void dispose() {
    super.dispose();
    stopSendingRiderLiveLocation();
  }

  @override
  Widget build(BuildContext context) {
    final proposedRideRequestModel =
        context.read<ProposePriceCubit>().proposedRideRequestModel;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding:
            MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile and Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage: (widget.request.user.imageName != null &&
                          widget.request.user.imageName!.isNotEmpty)
                      ? NetworkImage(ApiEndpoints.baseUrl +
                          ApiEndpoints.getImage(widget.request.user.imageName!))
                      : null,
                  child: (widget.request.user.imageName == null ||
                          widget.request.user.imageName!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primaryBlack,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TextUtils.capitalizeEachWord(widget.request.user.name),
                      style: AppTypography.labelText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.request.totalKm} KM",
                      style: AppTypography.labelText.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.request.sName,
                          style: AppTypography.labelText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.flag, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.request.dName,
                          style: AppTypography.labelText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Price and Call Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accepted Price',
                        style: AppTypography.labelText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NRS ${proposedRideRequestModel?.proposedPrice.toString() ?? '0'}',
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _makeEmergencyCall(
                        context, proposedRideRequestModel!.user.mobileNo),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Icon(
                        Icons.call,
                        size: 28,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Passenger Picked or Ride Completed Button
            if (!_passengerPicked)
              CustomButton(
                text: 'Passenger Picked',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        contentPadding:
                            const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        title: Column(
                          children: [
                            Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Confirm Passenger Pickup',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        content: Text(
                          'Are you sure you have picked up the passenger?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlack.withOpacity(0.7),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                  child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColors.primaryBlack.withOpacity(0.5),
                                  side: BorderSide(
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.2),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await _markPassengerPicked();
                                  },
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: AppColors.primaryColor,
              ),

            if (_passengerPicked)
              CustomButton(
                text: 'Set Ride as Completed',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        contentPadding:
                            const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        title: Column(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 40,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Confirm Ride Completion',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to mark this ride as completed? This action cannot be undone.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlack.withOpacity(0.7),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        AppColors.primaryBlack.withOpacity(0.5),
                                    side: BorderSide(
                                      color: AppColors.primaryBlack
                                          .withOpacity(0.2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    final loginResponse =
                                        context.read<AuthCubit>().loginResponse;
                                    if (loginResponse == null) return;
                                    final isCompleted = await context
                                        .read<AddressCubit>()
                                        .completeRide(
                                            widget.request.rideRequestId
                                                .toString(),
                                            loginResponse.token);
                                    if (!isCompleted) return;
                                    stopSendingRiderLiveLocation();
                                    Navigator.pop(context);
                                    context
                                        .read<StompSocketCubit>()
                                        .clearRide(widget.request);
                                  },
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  void _makeEmergencyCall(BuildContext context, String number) async {
    // Show confirmation dialog
    final shouldCall = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            actionsPadding: const EdgeInsets.all(8),
            title: Column(
              children: [
                Icon(
                  Icons.phone,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  'Call Passenger',
                  style: AppTypography.labelText.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              'This will call the passenger immediately. Do you want to continue?',
              style: AppTypography.labelText.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.primaryBlack.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Call Now',
                            style: AppTypography.labelText.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.backgroundColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;

    if (shouldCall) {
      try {
        final Uri url = Uri(scheme: 'tel', path: number);
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
        CustomToast.show(
          'Error making call: ${e.toString()}',
          context: context,
          toastType: ToastType.error,
        );
      }
    }
  }
}
