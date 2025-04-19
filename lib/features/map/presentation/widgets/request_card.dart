import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/map/models/request.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RequestCard extends StatelessWidget {
  final Request request;
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
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 30,
                  child: Image.asset(
                    Assets.images.tufan.path,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Toyota Prius', style: AppTypography.labelText),
                    const SizedBox(height: 4),
                    Text('John', style: AppTypography.labelText),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amberAccent),
                        const SizedBox(width: 4),
                        Text('4.9',
                            style: AppTypography.labelText.copyWith(
                              fontSize: 14,
                            )),
                        const SizedBox(width: 4),
                        Text(
                          '(432)',
                          style: AppTypography.labelText.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryBlack.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NPR 120',
                    style: AppTypography.labelText.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('5 min', style: AppTypography.labelText),
                  Text('1 km', style: AppTypography.labelText),
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
