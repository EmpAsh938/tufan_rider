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
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
          // Top Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Photo
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: (request.user.imageName != null &&
                        request.user.imageName!.isNotEmpty)
                    ? NetworkImage(ApiEndpoints.baseUrl +
                        ApiEndpoints.getImage(request.user.imageName!))
                    : null,
                child: (request.user.imageName == null ||
                        request.user.imageName!.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryBlack,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Middle: Name, Vehicle, Ratings, Source → Destination
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TextUtils.capitalizeEachWord(request.user.name),
                        style: AppTypography.labelText),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        // Source
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  request.sName,
                                  style: AppTypography.labelText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Destination
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.flag,
                                  size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  request.dName,
                                  style: AppTypography.labelText,
                                  overflow: TextOverflow.ellipsis,
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

              // Right: Arrow + Fare
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onAccept,
                    icon: const Icon(Icons.arrow_forward_ios_outlined,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text('NPR${request.actualPrice}',
                      style: AppTypography.labelText),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
