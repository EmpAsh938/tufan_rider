import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class DriverArrivingBottomsheet extends StatelessWidget {
  final VoidCallback onPressed;
  const DriverArrivingBottomsheet({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top driver arrival info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver is arriving in',
                          style: AppTypography.headline.copyWith(
                            color: AppColors.primaryBlack,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 4),
                      Text('~4 min',
                          style: AppTypography.headline.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          )),
                      const SizedBox(height: 4),
                      Text('Blue MOTOR-BIKE Honda',
                          style: AppTypography.smallText.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Image.asset(
                      Assets.icons.bike.path,
                      width: 50,
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('BA44PA1838',
                            style: AppTypography.smallText.copyWith(
                              color: AppColors.backgroundColor,
                              fontWeight: FontWeight.w700,
                            ))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Driver details row: avatar + call + safety
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Avatar + name & rating
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                              color: AppColors.neutralColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage: AssetImage(Assets.icons.bike.path),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '4.9 ★',
                              style: AppTypography.smallText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Anil Rai',
                      style: AppTypography.smallText
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                // Call Icon
                Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.neutralColor.withOpacity(0.5),
                      child: const Icon(
                        Icons.call_outlined,
                        size: 40,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Call Driver',
                      style: AppTypography.smallText
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                // Safety Icon
                Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.neutralColor.withOpacity(0.5),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 40,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Safety',
                      style: AppTypography.smallText
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),

            // Payment
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment', style: AppTypography.labelText),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payment,
                        size: 20, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.smallText.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(text: 'NPR 60'),
                          TextSpan(
                            text: '  Cash',
                            style: AppTypography.smallText.copyWith(
                              color: AppColors.primaryBlack.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ride Location Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your current Ride', style: AppTypography.labelText),
                const SizedBox(height: 8),
                _buildLocationRow(
                  color: AppColors.primaryGreen,
                  label: 'Starting Location Name Goes Here',
                ),
                const SizedBox(height: 8),
                _buildLocationRow(
                  color: AppColors.primaryRed,
                  label: 'Destination Location Name Goes Here',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: onPressed,
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

  Widget _buildLocationRow({required Color color, required String label}) {
    return Row(
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
                  color: color.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.smallText.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
