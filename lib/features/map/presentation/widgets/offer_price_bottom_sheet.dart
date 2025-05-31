import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';

class OfferPriceBottomSheet extends StatefulWidget {
  final void Function(bool) onPressed;
  final Future<void> Function(
      {required LatLng destination,
      required LatLng origin,
      LatLng? waypoint}) drawPolyline;
  const OfferPriceBottomSheet(
      {super.key, required this.onPressed, required this.drawPolyline});

  @override
  State<OfferPriceBottomSheet> createState() => _OfferPriceBottomSheetState();
}

class _OfferPriceBottomSheetState extends State<OfferPriceBottomSheet> {
  bool isSending = false;

  void handleSending(bool value) {
    setState(() {
      isSending = value;
    });
  }

  @override
  void initState() {
    super.initState();
    final addressCubit = context.read<AddressCubit>();
    final source = addressCubit.source;
    final destination = addressCubit.destination;
    if (source == null || destination == null) return;
    final sourceCoordinates = LatLng(source.lat, source.lng);
    final destinationCoordinates = LatLng(destination.lat, destination.lng);

    widget.drawPolyline(
        origin: sourceCoordinates,
        destination: destinationCoordinates,
        waypoint: null);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddressCubit>().rideRequest;
    final loginResponse = context.read<AuthCubit>().loginResponse;
    return AbsorbPointer(
      absorbing: isSending,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Offering Your Price',
                style: AppTypography.labelText.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    if (state != null) {
                      handleSending(true);
                      widget.onPressed(false);

                      await context.read<AddressCubit>().updateRideRequest(
                            RideLocation(
                                lat: state.dLatitude, lng: state.dLongitude),
                            (state.actualPrice - 10).toString(),
                            state.rideRequestId.toString(),
                            loginResponse!.token,
                          );
                      handleSending(false);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: AppColors.gray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '-10',
                    style: AppTypography.actionText.copyWith(
                      fontSize: 20,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
                Text(
                  'NPR${state!.actualPrice.toStringAsFixed(0)}',
                  style: AppTypography.labelText.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    handleSending(true);
                    widget.onPressed(false);
                    await context.read<AddressCubit>().updateRideRequest(
                          RideLocation(
                              lat: state.dLatitude, lng: state.dLongitude),
                          (state.actualPrice + 10).toString(),
                          state.rideRequestId.toString(),
                          loginResponse!.token,
                        );
                    handleSending(false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '+10',
                    style: AppTypography.actionText.copyWith(
                      fontSize: 20,
                      color: AppColors.backgroundColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // state.to
            // SizedBox(
            //   width: double.infinity,
            //   child: CustomButton(
            //     onPressed: () {},
            //     text: 'Raise Fare',
            //   ),
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         "Automatically accept the nearest driver for your fare",
            //         style: AppTypography.smallText.copyWith(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //     CustomSwitch(
            //       isActive: true,
            //       switchValue: false,
            //       onChanged: (bool value) {},
            //     ),
            //   ],
            // ),
            const SizedBox(height: 8),

            FareInfoBubble(
              fare: '${state.totalKm.toStringAsFixed(0)} Km',
              duration: '${state.totalMin} min',
            ),

            const SizedBox(height: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment',
                  style: AppTypography.labelText,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.smallText.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'NPR${state.actualPrice.toStringAsFixed(0)}',
                          ),
                          TextSpan(
                              text: '  Cash',
                              style: AppTypography.smallText.copyWith(
                                color: AppColors.primaryBlack.withOpacity(0.5),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your current Ride',
                  style: AppTypography.labelText,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.sName,
                        style: AppTypography.smallText.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.dName,
                        style: AppTypography.smallText.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () => widget.onPressed(true),
                backgroundColor: AppColors.gray,
                textColor: AppColors.primaryRed,
                text: 'Cancel Request',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FareInfoBubble extends StatelessWidget {
  final String fare;
  final String duration;

  const FareInfoBubble({
    Key? key,
    required this.fare,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  const TextSpan(text: 'The total estimated distance is '),
                  TextSpan(
                    text: fare,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.\nTravel time ~'),
                  TextSpan(
                    text: duration,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
