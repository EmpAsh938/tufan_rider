import 'dart:async';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  final RideRequestModel request;
  final Function(bool) handlePickup;
  final Function(bool) handleCompleted;
  final LatLng sourceLocation;
  final void Function(RideRequestModel) drawPolyline;

  const AcceptedBottomsheet({
    super.key,
    required this.onPressed,
    required this.handlePickup,
    required this.request,
    required this.drawPolyline,
    required this.handleCompleted,
    required this.sourceLocation,
  });

  @override
  State<AcceptedBottomsheet> createState() => _AcceptedBottomsheetState();
}

class _AcceptedBottomsheetState extends State<AcceptedBottomsheet> {
  bool _passengerPicked = false;
  bool _isCalling = false;

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
      widget.handlePickup(true);
      CustomToast.show(
        'Passenger marked as picked',
        context: context,
        toastType: ToastType.success,
      );

      widget.drawPolyline(widget.request);
    } else {
      CustomToast.show(
        'Failed to mark passenger as picked',
        context: context,
        toastType: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposedRideRequestModel =
        context.read<ProposePriceCubit>().proposedRideRequestModel;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: MediaQuery.of(
              context,
            ).viewInsets.add(const EdgeInsets.all(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with status
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ride Accepted',
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price and distance information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: AppTypography.labelText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.request.totalKm} km',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Fare',
                            style: AppTypography.labelText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NRS ${proposedRideRequestModel?.proposedPrice.toString() ?? '0'}',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration',
                            style: AppTypography.labelText.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.request.totalKm ~/ 0.3} min', // Simple estimation
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profile and Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: (widget.request.user.imageName != null &&
                              widget.request.user.imageName!.isNotEmpty)
                          ? NetworkImage(
                              ApiEndpoints.baseUrl +
                                  ApiEndpoints.getImage(
                                    widget.request.user.imageName!,
                                  ),
                            )
                          : null,
                      child: (widget.request.user.imageName == null ||
                              widget.request.user.imageName!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TextUtils.capitalizeEachWord(
                                widget.request.user.name),
                            style: AppTypography.headline.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (25 rides)',
                                style: AppTypography.labelText.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      // onPressed: () => _makeEmergencyCall(
                      //   context,
                      //   widget.request?.token ?? '',
                      //   widget.request?.channel ?? '',
                      // ),
                      onPressed: () => _makeEmergencyCall(
                        context,
                        widget.request.user.mobileNo,
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          size: 24,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Trip information card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup location',
                                  style: AppTypography.labelText.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.request.sName,
                                  style: AppTypography.labelText.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Destination location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.flag,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Destination',
                                  style: AppTypography.labelText.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.request.dName,
                                  style: AppTypography.labelText.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                if (!_passengerPicked) ...[
                  Row(
                    children: [
                      // Expanded(
                      //   child: OutlinedButton(
                      //     style: OutlinedButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       side: BorderSide(
                      //         color: AppColors.primaryColor,
                      //       ),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //     onPressed: widget.onPressed,
                      //     child: Text(
                      //       'Cancel Ride',
                      //       style: AppTypography.labelText.copyWith(
                      //         color: AppColors.primaryColor,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              _showPickupConfirmationDialog(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm Pickup',
                                style: AppTypography.labelText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showCompletionConfirmationDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Complete Ride',
                          style: AppTypography.labelText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Positioned Navigate Button
        Positioned(
          top: 16,
          right: 16,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            color: Colors.white, // or any background color you prefer
            child: IconButton(
              onPressed: () => openGoogleMaps(
                destinationLat: _passengerPicked
                    ? widget.request.dLatitude
                    : widget.request.sLatitude,
                destinationLng: _passengerPicked
                    ? widget.request.dLongitude
                    : widget.request.sLongitude,
                sourceLat: widget.sourceLocation.latitude,
                sourceLng: widget.sourceLocation.longitude,
              ),
              icon: const Icon(
                Icons.navigation,
                color: AppColors.primaryColor, // or AppColors.primaryColor
                size: 24,
              ),
              tooltip: 'Navigate',
            ),
          ),
        ),
      ],
    );
  }

  void _showPickupConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 32,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Passenger Pickup',
              style: AppTypography.headline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Have you picked up ${TextUtils.capitalizeEachWord(widget.request.user.name)} from the pickup location?',
          style: AppTypography.labelText.copyWith(
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.primaryBlack.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
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
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _markPassengerPicked();
                  },
                  child: Text(
                    'Confirm',
                    style: AppTypography.labelText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompletionConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                size: 32,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete Ride',
              style: AppTypography.headline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to mark this ride as completed?',
          style: AppTypography.labelText.copyWith(
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.primaryBlack.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
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
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final loginResponse =
                        context.read<AuthCubit>().loginResponse;
                    if (loginResponse == null) return;

                    final isCompleted =
                        await context.read<AddressCubit>().completeRide(
                              widget.request.rideRequestId.toString(),
                              loginResponse.token,
                            );

                    if (isCompleted) {
                      widget.handleCompleted(true);
                      context.read<StompSocketCubit>().clearRide(
                            widget.request,
                          );

                      widget.onPressed();
                      Navigator.pop(context);

                      // Navigator.pushReplacementNamed(context, AppRoutes.map);
                    } else {
                      CustomToast.show(
                        'Failed to complete ride',
                        context: context,
                        toastType: ToastType.error,
                      );
                    }
                  },
                  child: Text(
                    'Complete',
                    style: AppTypography.labelText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _makeEmergencyCall(BuildContext context, String phoneNumber) async {
    final shouldCall = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundColor,
            title: Text(
              'Emergency Call',
              style: AppTypography.labelText.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'This will start a phone call to emergency number. Proceed?',
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

    if (!shouldCall) return;

    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      CustomToast.show(
        'Could not launch phone call',
        context: context,
        toastType: ToastType.error,
      );
    }
  }

  // Future<void> _makeEmergencyCall(
  //   BuildContext context,
  //   String token,
  //   String channelName,
  // ) async {
  //   if (!mounted) return;
  //   setState(() => _isCalling = true);

  //   final shouldCall = await showDialog<bool>(
  //         context: context,
  //         builder: (context) =>
  //             _CallConfirmDialog(name: widget.request.user.name),
  //       ) ??
  //       false;

  //   setState(() => _isCalling = false);

  //   if (!shouldCall) return;

  //   final engine = createAgoraRtcEngine();

  //   try {
  //     await engine.initialize(
  //       const RtcEngineContext(appId: '5c61f42e947b4b22a65dc1c66deb0664'),
  //     );

  //     final micStatus = await Permission.microphone.request();
  //     if (!micStatus.isGranted) {
  //       if (!mounted) return;
  //       CustomToast.show(
  //         'Microphone permission required',
  //         context: context,
  //         toastType: ToastType.error,
  //       );
  //       return;
  //     }

  //     await engine
  //       ..setChannelProfile(ChannelProfileType.channelProfileCommunication)
  //       ..setClientRole(role: ClientRoleType.clientRoleBroadcaster)
  //       ..enableAudio()
  //       ..setEnableSpeakerphone(true);

  //     if (!mounted) return;

  //     await showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => _OngoingCallDialog(
  //         engine: engine,
  //         name: widget.request.user.name,
  //         token: token,
  //         channelName: channelName,
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     CustomToast.show(
  //       'Error: ${e.toString()}',
  //       context: context,
  //       toastType: ToastType.error,
  //     );
  //   }
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  //   // Set up the Agora RTC engine instance
  //   Future<void> _initializeAgoraVoiceSDK() async {
  //     _engine = createAgoraRtcEngine();
  //     if (_engine == null) return;
  //     await _engine!.initialize(RtcEngineContext(
  //       appId: '',
  //       channelProfile: ChannelProfileType.channelProfileCommunication,
  //     ));
  //   }

  // // Join a channel
  //   Future<void> _joinChannel() async {
  //     if (_engine == null) return;
  //     await _engine!.joinChannel(
  //       token: 'token',
  //       channelId: 'channel',
  //       options: const ChannelMediaOptions(
  //         autoSubscribeAudio:
  //             true, // Automatically subscribe to all audio streams
  //         publishMicrophoneTrack: true, // Publish microphone-captured audio
  //         // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
  //         clientRoleType: ClientRoleType.clientRoleBroadcaster,
  //       ),
  //       uid: 0,
  //     );
  //   }

  // // Register an event handler for Agora RTC
  //   void _setupEventHandlers() {
  //     if (_engine == null) return;

  //     _engine!.registerEventHandler(
  //       RtcEngineEventHandler(
  //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
  //           debugPrint("Local user ${connection.localUid} joined");
  //         },
  //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
  //           debugPrint("Remote user $remoteUid joined");
  //           setState(() {
  //             _remoteUid = remoteUid; // Store remote user ID
  //           });
  //         },
  //         onUserOffline: (RtcConnection connection, int remoteUid,
  //             UserOfflineReasonType reason) {
  //           debugPrint("Remote user $remoteUid left");
  //           setState(() {
  //             _remoteUid = null; // Remove remote user ID
  //           });
  //         },
  //       ),
  //     );
  //   }

  // // Requests microphone permission
  //   Future<void> _requestPermissions() async {
  //     await [Permission.microphone].request();
  //   }

  // // Leaves the channel and releases resources
  //   Future<void> _cleanupAgoraEngine() async {
  //     if (_engine == null) return;

  //     await _engine!.leaveChannel();
  //     await _engine!.release();
  //   }

  // await _requestPermissions();
  // await _initializeAgoraVoiceSDK();
  // _setupEventHandlers();
  // await _joinChannel();

  Future<void> openGoogleMaps({
    required double sourceLat,
    required double sourceLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$sourceLat,$sourceLng&destination=$destinationLat,$destinationLng&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// class _CallConfirmDialog extends StatelessWidget {
//   final String name;
//   const _CallConfirmDialog({required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: AppColors.backgroundColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.phone, size: 32, color: Colors.green),
//           ),
//           const SizedBox(height: 16),
//           Text('Call Passenger',
//               style: AppTypography.headline.copyWith(fontSize: 18)),
//         ],
//       ),
//       content: Text(
//         'This will initiate a voice call with ${TextUtils.capitalizeEachWord(name)}.',
//         style: AppTypography.labelText.copyWith(
//           color: AppColors.primaryBlack.withOpacity(0.7),
//         ),
//         textAlign: TextAlign.center,
//       ),
//       actions: [
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text('Cancel',
//                     style: AppTypography.labelText.copyWith(
//                       fontWeight: FontWeight.w600,
//                     )),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 icon: const Icon(Icons.phone, color: Colors.white),
//                 label: Text('Call Now',
//                     style: AppTypography.labelText.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     )),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _OngoingCallDialog extends StatefulWidget {
//   final RtcEngine engine;
//   final String name;
//   final String channelName;
//   final String token;
//   const _OngoingCallDialog(
//       {required this.engine,
//       required this.channelName,
//       required this.token,
//       required this.name});

//   @override
//   State<_OngoingCallDialog> createState() => _OngoingCallDialogState();
// }

// class _OngoingCallDialogState extends State<_OngoingCallDialog> {
//   bool isMuted = false;
//   bool isSpeakerOn = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await widget.engine.joinChannel(
//         // token: widget.token,
//         token:
//             '007eJxTYJC1P+Bwo2NDY23KYqbjRo3a6xeHnbiuNTvZzt/Ffn7jk3AFBtNkM8M0E6NUSxPzJJMkI6NEM9OUZMNkM7OU1CQDMzOT6b/cMhoCGRl0ul6yMjJAIIjPzZCckZiXl5oTn5iUzMAAAAk5IeU=',
//         // channelId: widget.channelName,
//         channelId: 'channel_abc',
//         uid: 100,
//         options: const ChannelMediaOptions(),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     widget.engine.leaveChannel();
//     widget.engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.phone,
//               size: 32,
//               color: isMuted ? Colors.grey : Colors.green,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text('Call with ${TextUtils.capitalizeEachWord(widget.name)}',
//               style: AppTypography.headline.copyWith(fontSize: 18)),
//         ],
//       ),
//       content: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Column(
//             children: [
//               IconButton(
//                 icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
//                 color: isMuted ? Colors.red : Colors.green,
//                 onPressed: () {
//                   setState(() => isMuted = !isMuted);
//                   widget.engine.muteLocalAudioStream(isMuted);
//                 },
//               ),
//               Text(isMuted ? 'Unmute' : 'Mute',
//                   style: AppTypography.labelText.copyWith(fontSize: 12)),
//             ],
//           ),
//           Column(
//             children: [
//               IconButton(
//                 icon: Icon(isSpeakerOn ? Icons.volume_up : Icons.volume_off),
//                 color: isSpeakerOn ? Colors.green : Colors.grey,
//                 onPressed: () {
//                   setState(() => isSpeakerOn = !isSpeakerOn);
//                   widget.engine.setEnableSpeakerphone(isSpeakerOn);
//                 },
//               ),
//               Text(isSpeakerOn ? 'Speaker On' : 'Speaker Off',
//                   style: AppTypography.labelText.copyWith(fontSize: 12)),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.call_end, color: Colors.white),
//           label: Text('End Call',
//               style: AppTypography.labelText.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               )),
//         ),
//       ],
//     );
//   }
// }
