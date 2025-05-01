import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:imepay_merchant_sdk/start_sdk.dart';
import 'package:tufan_rider/core/utils/random_id_generator.dart';

class RiderCreditScreen extends StatefulWidget {
  const RiderCreditScreen({super.key});

  @override
  State<RiderCreditScreen> createState() => _RiderCreditScreenState();
}

class _RiderCreditScreenState extends State<RiderCreditScreen> {
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();
  final TextEditingController _amountController = TextEditingController();

  final merchantCode = 'DEMOIMEP';
  final merchantName = 'IME Pay Demo';
  final merchantUrl =
      'https://stg.imepay.com.np:7979/api/sdk/recordTransaction';
  final module = 'DEMOIMEP';
  final user = 'demoimepay';
  final password = 'IMEPay@123';
  final deliveryUrl = 'http://172.20.22.11:1717/api/sdk/deliveryService';
  final buildType = BuildType.STAGE;

  void _initiatePayment(BuildContext context) async {
    final refId = generateRandomId();

    if (_amountController.text.isEmpty) {
      CustomToast.show(
        'Enter valid amount',
        context: context,
        toastType: ToastType.error,
      );
      return;
    }

    try {
      var result = await StartSdk.callSdk(
        context,
        merchantCode: merchantCode,
        merchantName: merchantName,
        merchantUrl: merchantUrl,
        amount: _amountController.text,
        refId: refId,
        module: module,
        user: user,
        password: password,
        deliveryUrl: deliveryUrl,
        buildType: buildType,
      );

      print(result.toString());
    } catch (e) {
      print(e);
    }
  }

  void _showLoadCreditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Load Credits',
                style: AppTypography.labelText.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _amountController,
                labelText: 'Enter Amount (NPR)',
                hintText: 'e.g. 500',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '1 Credit = 1 NPR',
                style: AppTypography.paragraph.copyWith(
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Proceed to Payment',
                onPressed: () => _initiatePayment(context),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlack.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Builder(builder: (context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: Icon(
                          Icons.menu,
                          color: AppColors.primaryBlack,
                          size: 26,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tufan Credit',
                      style: AppTypography.labelText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Credit Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: AppColors.gray.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlack.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "NPR6000",
                              style: AppTypography.labelText.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Text(
                              "Credits",
                              style: AppTypography.labelText.copyWith(
                                fontSize: 18,
                                color: AppColors.primaryBlack.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              key: tooltipKey,
                              message:
                                  "1 Credit = 1 NPR\nCredits expire after 30 days",
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlack,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: AppTypography.paragraph.copyWith(
                                color: AppColors.primaryWhite,
                              ),
                              child: IconButton(
                                onPressed: () => tooltipKey.currentState
                                    ?.ensureTooltipVisible(),
                                icon: Icon(
                                  Icons.help_outline,
                                  size: 20,
                                  color:
                                      AppColors.primaryBlack.withOpacity(0.5),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Load Credits',
                              onPressed: _showLoadCreditModal,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.riderCreditHistory);
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: AppColors.primaryColor,
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
          ],
        ),
      ),
    );
  }
}
