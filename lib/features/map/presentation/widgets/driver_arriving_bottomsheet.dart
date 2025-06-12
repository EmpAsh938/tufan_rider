import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tufan_rider/core/agora/agora_voice_service.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/features/rider/map/models/proposed_ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_response.dart';
import 'package:tufan_rider/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverArrivingBottomsheet extends StatefulWidget {
  final VoidCallback startUpdates;
  final Function(bool) handlePickup;
  final Function(String) handleRiders;
  final Function(ProposedRideRequestModel) handlePrice;
  final VoidCallback onPressed;
  final Future<void> Function({
    required LatLng destination,
    required LatLng origin,
    LatLng? waypoint,
  }) drawPolyline;

  const DriverArrivingBottomsheet({
    super.key,
    required this.onPressed,
    required this.handlePickup,
    required this.handlePrice,
    required this.drawPolyline,
    required this.startUpdates,
    required this.handleRiders,
  });

  @override
  State<DriverArrivingBottomsheet> createState() =>
      _DriverArrivingBottomsheetState();
}

class _DriverArrivingBottomsheetState extends State<DriverArrivingBottomsheet> {
  bool _passengerPicked = false;
  RiderResponse? _rider;

  void fetchRider(BuildContext context, String riderId) async {
    try {
      final rider = await context.read<CreateRiderCubit>().getRiderById(
            riderId,
          );
      widget.handleRiders(rider.id.toString());

      setState(() {
        _rider = rider;
      });
    } catch (e) {
      print('Failed to fetch rider: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final proposedRide =
        context.read<ProposePriceCubit>().proposedRideRequestModel;

    if (proposedRide != null) {
      widget.handlePrice(proposedRide);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final source = context.read<AddressCubit>().source;
      // final destination = context.read<AddressCubit>().destination;
      final bargainModel = context.read<AddressCubit>().bargainModel;

      widget.startUpdates();

      if (bargainModel != null) {
        fetchRider(context, bargainModel.userId.toString());
      }

      final stompSocketCubit = context.read<StompSocketCubit>();
      stompSocketCubit.stream.listen((state) {
        if (state is PassengerPickupReceived) {
          widget.handlePickup(true);
          setState(() {
            _passengerPicked = true;
          });

          // if (source == null || destination == null) return;

          // final sourceLocation = LatLng(source.lat, source.lng);
          // final destinationLocation = LatLng(destination.lat, destination.lng);
          // widget.drawPolyline(
          //     sourceLocation, sourceLocation, destinationLocation);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final acceptedRide = context.read<AddressCubit>().acceptedRide;
    final bargainModel = context.read<AddressCubit>().bargainModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver arrival header - updated based on passenger picked status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _passengerPicked
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _passengerPicked
                              ? 'On the way to destination'
                              : 'Driver is arriving in',
                          style: AppTypography.headline.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!_passengerPicked) ...[
                          Text(
                            '~${bargainModel?.minToReach.toStringAsFixed(0) ?? '--'} min',
                            style: AppTypography.headline.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                        if (_passengerPicked)
                          Text(
                            'Estimated arrival: ~${bargainModel?.minToReach.toStringAsFixed(0) ?? '--'} min',
                            style: AppTypography.headline.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        Assets.icons.bike.path,
                        width: 60,
                        // color: _passengerPicked ? AppColors.primaryGreen : null,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bargainModel?.vehicleNumber ?? '--',
                          style: AppTypography.smallText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Driver profile section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Driver avatar and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.gray.withOpacity(0.3),
                            backgroundImage: (_rider?.user.imageName != null &&
                                    _rider!.user.imageName!.isNotEmpty)
                                ? NetworkImage(
                                    ApiEndpoints.baseUrl +
                                        ApiEndpoints.getImage(
                                          _rider!.user.imageName!,
                                        ),
                                  )
                                : null,
                            child: (_rider?.user.imageName == null ||
                                    _rider!.user.imageName!.isEmpty)
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.black54,
                                  )
                                : null,
                          ),
                        ),
                        Text(
                          TextUtils.capitalizeEachWord(
                            _rider?.user.name ?? '--',
                          ),
                          style: AppTypography.labelText.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 24,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.9',
                                      style: AppTypography.smallText.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bargainModel?.vehicleBrand ?? '--',
                                  style: AppTypography.smallText.copyWith(
                                    color: AppColors.primaryBlack.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.call_outlined,
                        label: 'Call',
                        color: Colors.green,
                        // onPressed: () => _makeEmergencyCall(
                        //   context,
                        //   acceptedRide?.token ?? '',
                        //   acceptedRide?.channel ?? '',
                        // ),
                        onPressed: () => _makeEmergencyCall(
                          context,
                          _rider?.user.mobileNo ?? '',
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.shield_outlined,
                        label: 'Safety',
                        color: AppColors.primaryColor,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 12),

            // Ride info section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  // Payment info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment',
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 20,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.labelText.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'NPR ${acceptedRide?.actualPrice.toStringAsFixed(0) ?? '--'}',
                                  style: TextStyle(
                                    color: _passengerPicked
                                        ? AppColors.primaryGreen
                                        : AppColors.primaryBlack,
                                  ),
                                ),
                                TextSpan(
                                  text: '  Cash',
                                  style: TextStyle(
                                    color: AppColors.primaryBlack.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ride locations
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Route',
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLocationRow(
                        icon: Icons.circle,
                        iconColor: _passengerPicked
                            ? AppColors.primaryGreen
                            : AppColors.primaryColor,
                        label: acceptedRide?.sName ?? 'Pickup location',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: Container(
                          height: 20,
                          width: 2,
                          color: AppColors.primaryBlack.withOpacity(0.2),
                        ),
                      ),
                      _buildLocationRow(
                        icon: Icons.location_on,
                        iconColor: AppColors.primaryRed,
                        label: acceptedRide?.dName ?? 'Destination',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Show ride status indicator if passenger is picked
            if (_passengerPicked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Passenger picked up',
                      style: AppTypography.labelText.copyWith(
                        color: AppColors.primaryGreen,
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color),
          ),
        ),
        Text(
          label,
          style: AppTypography.smallText.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelText.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
              'This will start a phone call. Proceed?',
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
  //   // setState(() => _isCalling = true);

  //   final shouldCall = await showDialog<bool>(
  //         context: context,
  //         builder: (context) => _CallConfirmDialog(name: ''),
  //       ) ??
  //       false;

  //   // setState(() => _isCalling = false);

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
  //         name: 'test',
  //         // token: token,
  //         token:
  //             '007eJxTYJC1P+Bwo2NDY23KYqbjRo3a6xeHnbiuNTvZzt/Ffn7jk3AFBtNkM8M0E6NUSxPzJJMkI6NEM9OUZMNkM7OU1CQDMzOT6b/cMhoCGRl0ul6yMjJAIIjPzZCckZiXl5oTn5iUzMAAAAk5IeU=',
  //         // channelName: channelName,
  //         channelName: 'channel_abc',
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
}

class _CallConfirmDialog extends StatelessWidget {
  final String name;
  const _CallConfirmDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, size: 32, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text('Call Passenger',
              style: AppTypography.headline.copyWith(fontSize: 18)),
        ],
      ),
      content: Text(
        'This will initiate a voice call with ${TextUtils.capitalizeEachWord(name)}.',
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
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: AppTypography.labelText.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: Text('Call Now',
                    style: AppTypography.labelText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OngoingCallDialog extends StatefulWidget {
  final RtcEngine engine;
  final String name;
  final String channelName;
  final String token;
  const _OngoingCallDialog(
      {required this.engine,
      required this.channelName,
      required this.token,
      required this.name});

  @override
  State<_OngoingCallDialog> createState() => _OngoingCallDialogState();
}

class _OngoingCallDialogState extends State<_OngoingCallDialog> {
  bool isMuted = false;
  bool isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 100,
        options: const ChannelMediaOptions(),
      );
    });
  }

  @override
  void dispose() {
    widget.engine.leaveChannel();
    widget.engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone,
              size: 32,
              color: isMuted ? Colors.grey : Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text('Call with ${TextUtils.capitalizeEachWord(widget.name)}',
              style: AppTypography.headline.copyWith(fontSize: 18)),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                color: isMuted ? Colors.red : Colors.green,
                onPressed: () {
                  setState(() => isMuted = !isMuted);
                  widget.engine.muteLocalAudioStream(isMuted);
                },
              ),
              Text(isMuted ? 'Unmute' : 'Mute',
                  style: AppTypography.labelText.copyWith(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(isSpeakerOn ? Icons.volume_up : Icons.volume_off),
                color: isSpeakerOn ? Colors.green : Colors.grey,
                onPressed: () {
                  setState(() => isSpeakerOn = !isSpeakerOn);
                  widget.engine.setEnableSpeakerphone(isSpeakerOn);
                },
              ),
              Text(isSpeakerOn ? 'Speaker On' : 'Speaker Off',
                  style: AppTypography.labelText.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.call_end, color: Colors.white),
          label: Text('End Call',
              style: AppTypography.labelText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }
}
