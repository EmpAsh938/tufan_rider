import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class AcceptedBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  final RideRequestModel request;
  const AcceptedBottomsheet(
      {super.key, required this.onPressed, required this.request});

  @override
  State<AcceptedBottomsheet> createState() => _AcceptedBottomsheetState();
}

class _AcceptedBottomsheetState extends State<AcceptedBottomsheet> {
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
    final proposedRideRequestModel =
        context.read<ProposePriceCubit>().proposedRideRequestModel;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding:
            MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile and Name
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: (widget.request.user.imageName != null &&
                        widget.request.user.imageName!.isNotEmpty)
                    ? NetworkImage(ApiEndpoints.baseUrl +
                        ApiEndpoints.getImage(widget.request.user.imageName!))
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
              Text(TextUtils.capitalizeEachWord(widget.request.user.name),
                  style: AppTypography.labelText),
              Spacer(),
              Text("${widget.request.totalKm} KM",
                  style: AppTypography.labelText),
            ]),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
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

            const SizedBox(height: 16),

            // Offer & Ask Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Accepted Price in NRS',
                        style: AppTypography.labelText),
                    const SizedBox(height: 4),
                    Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                            proposedRideRequestModel == null
                                ? ''
                                : proposedRideRequestModel.proposedPrice
                                    .toString(),
                            style: AppTypography.labelText)),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(0.1), // light green background
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child:
                          const Icon(Icons.call, size: 28, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
