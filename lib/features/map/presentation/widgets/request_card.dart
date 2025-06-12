import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/map/models/rider_bargain_model.dart';

class RequestCard extends StatelessWidget {
  final RiderBargainModel request;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final double acceptProgress;
  const RequestCard({
    super.key,
    required this.request,
    required this.onDecline,
    required this.onAccept,
    this.acceptProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // Header Row: Avatar and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: (request.riderImage.isNotEmpty)
                    ? NetworkImage(ApiEndpoints.baseUrl +
                        ApiEndpoints.getImage(request.riderImage))
                    : null,
                child: (request.riderImage.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryBlack,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(TextUtils.capitalizeEachWord(request.vehicleBrand),
                    Text(TextUtils.capitalizeEachWord(request.vehicleBrand),
                        style: AppTypography.labelText),
                    const SizedBox(height: 4),
                    // Text(TextUtils.capitalizeEachWord(request.name),
                    Text(
                      TextUtils.capitalizeEachWord(request.name),
                      style: AppTypography.labelText,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Row(
                    //   children: [
                    //     const Icon(Icons.star,
                    //         size: 16, color: Colors.amberAccent),
                    //     const SizedBox(width: 4),
                    //     Text('4.9',
                    //         style: AppTypography.labelText.copyWith(
                    //           fontSize: 14,
                    //         )),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       '(432)',
                    //       style: AppTypography.labelText.copyWith(
                    //         fontSize: 14,
                    //         color: AppColors.primaryBlack.withOpacity(0.4),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR ${request.proposedPrice.toStringAsFixed(0)}',
                    style: AppTypography.labelText.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${request.minToReach.toStringAsFixed(0)} min',
                      style: AppTypography.labelText),
                  // Text('1 km', style: AppTypography.labelText),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors.gray,
                  textColor: AppColors.primaryRed,
                  text: 'Decline',
                  onPressed: onDecline,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  // backgroundColor: AppColors.neutralColor,
                  textColor: Colors.white,
                  text: 'Accept',
                  onPressed: onAccept,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
