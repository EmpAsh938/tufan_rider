import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class BargainPriceBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  const BargainPriceBottomsheet({super.key, required this.onPressed});

  @override
  State<BargainPriceBottomsheet> createState() =>
      _BargainPriceBottomsheetState();
}

class _BargainPriceBottomsheetState extends State<BargainPriceBottomsheet> {
  final TextEditingController _askPriceController =
      TextEditingController(text: '100');

  @override
  void dispose() {
    _askPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding:
            MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile and Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(Assets.images.tufan.path),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John', style: AppTypography.labelText),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Source Location',
                                style: AppTypography.labelText,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.flag, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Destination',
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
                    Text('Offered in NRS', style: AppTypography.labelText),
                    const SizedBox(height: 4),
                    Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('100', style: AppTypography.labelText)),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
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
              child: CustomButton(
                text: 'Send',
                onPressed: () {
                  final enteredPrice = _askPriceController.text;
                  widget.onPressed();
                  // Use enteredPrice here for further logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
