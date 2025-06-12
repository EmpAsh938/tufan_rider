import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

class RiderRequestCard extends StatelessWidget {
  final RideRequestModel request;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final double acceptProgress;

  const RiderRequestCard({
    super.key,
    required this.request,
    required this.onDecline,
    required this.onAccept,
    this.acceptProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: (request.user.imageName != null &&
                          request.user.imageName!.isNotEmpty)
                      ? NetworkImage(ApiEndpoints.baseUrl +
                          ApiEndpoints.getImage(request.user.imageName!))
                      : null,
                  child: (request.user.imageName == null ||
                          request.user.imageName!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            TextUtils.capitalizeEachWord(request.user.name),
                            style: AppTypography.labelText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'NPR ${request.actualPrice}',
                          style: AppTypography.labelText.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Distance
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.totalKm} km',
                          style: AppTypography.labelText.copyWith(
                            color: AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action Button
              Column(
                children: [
                  IconButton(
                    onPressed: onAccept,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Route Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Source
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.sName,
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Destination
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.dName,
                        style: AppTypography.labelText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
