import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';

class OfferFareScreen extends StatefulWidget {
  const OfferFareScreen({super.key});

  @override
  State<OfferFareScreen> createState() => _OfferFareScreenState();
}

class _OfferFareScreenState extends State<OfferFareScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController fareController = TextEditingController(text: '');

  RideLocation? source;
  RideLocation? destination;
  FareResponse? fareResponse;
  LoginResponse? loginResponse;

  bool isCashSelected = true;
  bool autoAccept = false;
  bool isLoading = true;
  bool isFindingRides = false;

  void fetchAddress() async {
    final addressCubit = locator.get<AddressCubit>();
    final authCubit = locator.get<AuthCubit>();
    final sourceInfo = addressCubit.source;
    final destinationInfo = addressCubit.destination;
    final fareInfo =
        await addressCubit.getFare(destinationInfo, authCubit.loginResponse);
    if (fareInfo != null) addressCubit.setFare(fareInfo);
    setState(() {
      loginResponse = authCubit.loginResponse;
      source = sourceInfo;
      destination = destinationInfo;
      isLoading = false;
      fareResponse = fareInfo;
      fareController.text =
          fareInfo == null ? '' : (fareInfo.generatedPrice).ceil().toString();
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
        resizeToAvoidBottomInset: false,
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
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        autofocus: true,
                        controller: fareController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          final number = double.tryParse(value ?? '');
                          final generated = fareResponse == null
                              ? 0.0
                              : fareResponse!.generatedPrice;

                          if (number == null) {
                            return 'Enter a valid number';
                          }

                          final diff = (number - generated).abs();

                          if (diff > 10) {
                            return 'Fare must be within ±10 of the generated price';
                          }

                          return null;
                        },
                        onChanged: (_) => _formKey.currentState?.validate(),
                        decoration: const InputDecoration(
                          prefixText: 'NRs. ',
                          border: UnderlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: AppColors.gray, width: 2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide:
                                BorderSide(color: AppColors.gray, width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            // borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: AppColors.neutralColor, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (fareResponse != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.monetization_on, color: Colors.green[700]),
                          SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.labelText.copyWith(
                                fontSize: 16,
                                decoration: TextDecoration
                                    .none, // Prevents underline globally
                              ),
                              children: [
                                TextSpan(
                                  text: 'Recommended Fare: ',
                                  style: AppTypography.labelText.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration
                                        .none, // Ensure no underline
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'NRs. ${fareResponse!.generatedPrice.toStringAsFixed(0)}',
                                  style: AppTypography.labelText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlack,
                                    decoration: TextDecoration
                                        .none, // Ensure no underline
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         "Automatically accept the nearest driver for your fare",
                    //         style: AppTypography.smallText.copyWith(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ),
                    //     CustomSwitch(
                    //       isActive: true,
                    //       switchValue: autoAccept,
                    //       onChanged: (bool value) {
                    //         setState(() {
                    //           autoAccept = value;
                    //         });
                    //       },
                    //     ),
                    //   ],
                    // ),
                    Spacer(),
                    Center(
                      child: isFindingRides
                          ? CircularProgressIndicator(
                              color: AppColors.neutralColor,
                            )
                          : CustomButton(
                              onPressed: () {
                                setState(() {
                                  isFindingRides = true;
                                });
                                final fare = int.tryParse(fareController.text);
                                if (fare != null) {
                                  _confirmFare(fare);
                                } else {
                                  CustomToast.show(
                                    'Enter a valid fare',
                                    context: context,
                                    toastType: ToastType.info,
                                  );
                                  setState(() {
                                    isFindingRides = false;
                                  });
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

  void _confirmFare(int fare) async {
    if (destination == null || loginResponse == null) {
      print('destination/login null');
      return;
    }

    try {
      final rideRequest = await context.read<AddressCubit>().createRideRequest(
            destination!,
            fare.toString(),
            loginResponse!.user.id.toString(),
            loginResponse!.token,
          );
      if (rideRequest == null) {
        return CustomToast.show(
          'Ride fare is either too low or high',
          context: context,
          toastType: ToastType.error,
        );
      }
      // put id from ride request here
      // await context.read<AddressCubit>().showRiders(
      //       rideRequest.rideRequestId.toString(),
      // );
      context
          .read<StompSocketCubit>()
          .subscribeToRideRiders(rideRequest.rideRequestId.toString());

      Navigator.pop(context, {
        'isFindDriversActive': true,
      });
    } catch (e) {
      CustomToast.show(
        e.toString(),
        context: context,
        toastType: ToastType.error,
      );
    } finally {
      setState(() {
        isFindingRides = false;
      });
    }
  }
}
