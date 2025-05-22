import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverArrivingBottomsheet extends StatelessWidget {
  final VoidCallback onPressed;
  const DriverArrivingBottomsheet({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final acceptedRide = context.read<AddressCubit>().acceptedRide;
    final proposedRide =
        context.watch<ProposePriceCubit>().proposedRideRequestModel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver arrival header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver is arriving in',
                          style: AppTypography.headline.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~${proposedRide?.minToReach ?? '--'} min',
                          style: AppTypography.headline.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
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
                          'BA44PA1838',
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
                      mainAxisSize:
                          MainAxisSize.min, // Add this to prevent expansion
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
                            radius: 28,
                            backgroundImage: AssetImage(Assets.icons.bike.path),
                          ),
                        ),
                        Text(
                          'Anil Rai',
                          style: AppTypography.labelText.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1, // Prevent text from wrapping
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          // Constrain the height of the rating row
                          height: 24, // Fixed height
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: Colors.amber),
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
                                // Make the vehicle text expandable
                                child: Text(
                                  'Blue MOTOR-BIKE Honda',
                                  style: AppTypography.smallText.copyWith(
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.7),
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
                        onPressed: () => _makeEmergencyCall(
                            context,
                            proposedRide == null
                                ? ''
                                : proposedRide.user.mobileNo),
                        // _makeCall(proposedRide?.driverPhone ?? ''),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.shield_outlined,
                        label: 'Safety',
                        color: AppColors.primaryColor,
                        onPressed: () {},
                        // onPressed: () => _showSafetyInfo(),
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
                          const Icon(Icons.payment,
                              size: 20, color: AppColors.primaryGreen),
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
                                  style: const TextStyle(
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                TextSpan(
                                  text: '  Cash',
                                  style: TextStyle(
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.6),
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
                        iconColor: AppColors.primaryGreen,
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

            const SizedBox(height: 16),

            // Cancel button
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: AppColors.primaryRed,
            //       side: BorderSide(color: AppColors.primaryRed),
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     onPressed: onPressed,
            //     child: Text(
            //       'Cancel Ride',
            //       style: AppTypography.labelText.copyWith(
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //   ),
            // ),
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

  void _makeEmergencyCall(BuildContext context, String phonenumber) async {
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
              'This will call rider immediately. Proceed?',
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
        final Uri url = Uri(scheme: 'tel', path: phonenumber);
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
