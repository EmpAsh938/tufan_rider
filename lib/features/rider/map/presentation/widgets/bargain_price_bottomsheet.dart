import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_state.dart';

class BargainPriceBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onCancel;
  final RideRequestModel request;
  const BargainPriceBottomsheet({
    super.key,
    required this.onCancel,
    required this.onPressed,
    required this.request,
  });

  @override
  State<BargainPriceBottomsheet> createState() =>
      _BargainPriceBottomsheetState();
}

class _BargainPriceBottomsheetState extends State<BargainPriceBottomsheet> {
  final TextEditingController _askPriceController =
      TextEditingController(text: '100');
  bool isSent = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _askPriceController.text = widget.request.actualPrice.toString();
    });
  }

  @override
  void dispose() {
    _askPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProposePriceCubit, ProposePriceState>(
      listener: (context, state) {
        if (state is ProposePriceFailure) {
          CustomToast.show(
            state.message,
            context: context,
            toastType: ToastType.error,
          );
        }
        if (state is ProposePriceSuccess) {
          context.read<StompSocketCubit>().subscribeToRequestDecline(
              state.proposedRideRequestModel.id.toString());
          setState(() {
            isSent = true;
          });
        }
      },
      child: BlocBuilder<ProposePriceCubit, ProposePriceState>(
        builder: (context, state) {
          final isLoading = state is ProposePriceLoading;
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: MediaQuery.of(context)
                  .viewInsets
                  .add(const EdgeInsets.all(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile and Route Information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlack.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
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
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                            backgroundImage: (widget.request.user.imageName !=
                                        null &&
                                    widget.request.user.imageName!.isNotEmpty)
                                ? NetworkImage(ApiEndpoints.baseUrl +
                                    ApiEndpoints.getImage(
                                        widget.request.user.imageName!))
                                : null,
                            child: (widget.request.user.imageName == null ||
                                    widget.request.user.imageName!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    size: 32,
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.6),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Route Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Passenger Name
                              Text(
                                TextUtils.capitalizeEachWord(
                                    widget.request.user.name),
                                style: AppTypography.labelText.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Route Information
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    // Pickup Location
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
                                            widget.request.sName,
                                            style: AppTypography.labelText
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Dropoff Location
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
                                            widget.request.dName,
                                            style: AppTypography.labelText
                                                .copyWith(
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
                              const SizedBox(height: 8),
                              // Distance
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 16,
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.request.totalKm} km',
                                    style: AppTypography.labelText.copyWith(
                                      color: AppColors.primaryBlack
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Price Proposal Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlack.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Passenger Offer',
                                  style: AppTypography.labelText.copyWith(
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NPR ${widget.request.actualPrice}',
                                  style: AppTypography.labelText.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Counter Offer',
                                  style: AppTypography.labelText.copyWith(
                                    color:
                                        AppColors.primaryBlack.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 120,
                                  child: TextFormField(
                                    controller: _askPriceController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: AppTypography.labelText.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryBlack
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isSent)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_top,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Waiting for passenger response',
                                  style: AppTypography.labelText.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(
                                      color: AppColors.primaryBlack
                                          .withOpacity(0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: widget.onCancel,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final enteredPrice =
                                              _askPriceController.text;
                                          final loginResponse = context
                                              .read<AuthCubit>()
                                              .loginResponse;
                                          if (loginResponse == null) return;

                                          context
                                              .read<ProposePriceCubit>()
                                              .proposePrice(
                                                widget.request.rideRequestId
                                                    .toString(),
                                                loginResponse.user.id
                                                    .toString(),
                                                loginResponse.token,
                                                enteredPrice,
                                              );
                                        },
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Send Offer',
                                          style:
                                              AppTypography.labelText.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
