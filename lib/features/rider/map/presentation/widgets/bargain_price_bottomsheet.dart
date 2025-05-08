import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_state.dart';

class BargainPriceBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  final RideRequestModel request;
  const BargainPriceBottomsheet(
      {super.key, required this.onPressed, required this.request});

  @override
  State<BargainPriceBottomsheet> createState() =>
      _BargainPriceBottomsheetState();
}

class _BargainPriceBottomsheetState extends State<BargainPriceBottomsheet> {
  final TextEditingController _askPriceController =
      TextEditingController(text: '100');

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
        listener: (context, state) => {
              if (state is ProposePriceFailure)
                {
                  CustomToast.show(
                    state.message,
                    context: context,
                    toastType: ToastType.error,
                  )
                },
              if (state is ProposePriceSuccess) {widget.onPressed()}
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
                  // Profile and Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryColor,
                        backgroundImage:
                            (widget.request.user.imageName != null &&
                                    widget.request.user.imageName!.isNotEmpty)
                                ? NetworkImage(ApiEndpoints.baseUrl +
                                    ApiEndpoints.getImage(
                                        widget.request.user.imageName!))
                                : null,
                        child: (widget.request.user.imageName == null ||
                                widget.request.user.imageName!.isEmpty)
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
                            Text(
                                TextUtils.capitalizeEachWord(
                                    widget.request.user.name),
                                style: AppTypography.labelText),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(widget.request.sName,
                                      style: AppTypography.labelText,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.flag, size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(widget.request.dName,
                                      style: AppTypography.labelText,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Offer & Ask Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('Offered in NRS',
                              style: AppTypography.labelText),
                          const SizedBox(height: 4),
                          Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(widget.request.actualPrice.toString(),
                                  style: AppTypography.labelText)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Ask in NRS', style: AppTypography.labelText),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: TextFormField(
                              controller: _askPriceController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: AppTypography.labelText,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Send Button
                  Align(
                    alignment: Alignment.center,
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          )
                        : CustomButton(
                            text: 'Send',
                            onPressed: () {
                              final enteredPrice = _askPriceController.text;
                              final loginResponse =
                                  context.read<AuthCubit>().loginResponse;
                              if (loginResponse == null) {
                                return;
                              }
                              final userId = loginResponse.user.id.toString();
                              final token = loginResponse.token;
                              context.read<ProposePriceCubit>().proposePrice(
                                    widget.request.rideRequestId.toString(),
                                    userId,
                                    token,
                                    enteredPrice,
                                  );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
