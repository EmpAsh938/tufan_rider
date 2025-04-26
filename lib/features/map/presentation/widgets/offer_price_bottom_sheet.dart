import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';

class OfferPriceBottomSheet extends StatelessWidget {
  final VoidCallback onPressed;
  const OfferPriceBottomSheet({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AddressCubit>();
    return SingleChildScrollView(
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
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                'NPR${state.fareResponse!.generatedPrice.toStringAsFixed(0)}',
                style: AppTypography.labelText.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: AppColors.neutralColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '+10',
                  style: AppTypography.actionText.copyWith(
                    fontSize: 20,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () {},
              text: 'Raise Fare',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Automatically accept the nearest driver for your fare",
                  style: AppTypography.smallText.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CustomSwitch(
                isActive: true,
                switchValue: false,
                onChanged: (bool value) {},
              ),
            ],
          ),
          const SizedBox(height: 4),
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
                          text:
                              'NPR${state.fareResponse!.generatedPrice.toStringAsFixed(0)}',
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
          const SizedBox(height: 8),
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
                      state.source == null ? '' : state.source!.name ?? '',
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
                      state.destination == null
                          ? ''
                          : state.destination!.name ?? '',
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
    );
  }
}
