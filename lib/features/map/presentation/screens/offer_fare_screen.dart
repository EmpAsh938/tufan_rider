import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';

class OfferFareScreen extends StatefulWidget {
  const OfferFareScreen({super.key});

  @override
  State<OfferFareScreen> createState() => _OfferFareScreenState();
}

class _OfferFareScreenState extends State<OfferFareScreen> {
  TextEditingController fareController = TextEditingController(text: '160340');

  RideLocation? source;
  RideLocation? destination;

  bool isCashSelected = true;
  bool autoAccept = false;

  void fetchAddress() {
    final addressCubit = locator.get<AddressCubit>();
    final sourceInfo = addressCubit.fetchSource();
    final destinationInfo = addressCubit.fetchDestination();
    setState(() {
      source = sourceInfo;
      destination = destinationInfo;
    });
  }

  @override
  void initState() {
    fetchAddress();
    super.initState();
  }

  @override
  void dispose() {
    fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Offer your fare",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: TextField(
                  controller: fareController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: ' NRs. ',
                    border: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.monetization_on, color: Colors.green[700]),
                  SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.labelText.copyWith(
                        fontSize: 16,
                        decoration:
                            TextDecoration.none, // Prevents underline globally
                      ),
                      children: [
                        TextSpan(
                          text: 'Recommended Fare: ',
                          style: AppTypography.labelText.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration:
                                TextDecoration.none, // Ensure no underline
                          ),
                        ),
                        TextSpan(
                          text: 'NRs. 500',
                          style: AppTypography.labelText.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                            decoration:
                                TextDecoration.none, // Ensure no underline
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // const Center(
              //   child: Slider(
              //     value: 0.5,
              //     onChanged: null, // purely decorative
              //   ),
              // ),
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 24),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text("Start", style: TextStyle(fontSize: 12)),
              //       Text("Goal", style: TextStyle(fontSize: 12)),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),
              Text(
                "Select your route",
                style: AppTypography.labelText,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _routeRow(
                        "From",
                        source == null
                            ? "Starting location"
                            : source!.name ?? 'Starting location',
                        Icons.radio_button_checked),
                    const Divider(),
                    _routeRow(
                        "Where to",
                        destination == null
                            ? "Destination location"
                            : destination!.name ?? "Destination location",
                        Icons.location_on_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _paymentMethodSelector(),
              const SizedBox(height: 24),
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
                    switchValue: autoAccept,
                    onChanged: (bool value) {
                      setState(() {
                        autoAccept = value;
                      });
                    },
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: CustomButton(
                  onPressed: () {
                    final fare = int.tryParse(fareController.text);
                    if (fare != null) {
                      _confirmFare(fare);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Enter a valid fare")),
                      );
                    }
                  },
                  text: 'Find Drivers',
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neutralColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.placeholderText.copyWith(
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _paymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
          style: AppTypography.labelText,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _paymentOption("Cash payment", isCashSelected, () {
              setState(() => isCashSelected = true);
            }),
            const SizedBox(width: 12),
            _paymentOption("Online payment", !isCashSelected, () {
              setState(() => isCashSelected = false);
            }),
          ],
        ),
      ],
    );
  }

  Widget _paymentOption(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? AppColors.neutralColor : AppColors.gray),
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.neutralColor.withOpacity(0.1)
                : AppColors.gray.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.neutralColor : AppColors.gray,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.smallText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmFare(int fare) {
    log("User offered fare: ₹$fare");
    // handle submission here (API call or navigation)
    Navigator.pop(context, {
      'isFindDriversActive': true,
    });
  }
}
