import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class AcceptedBottomsheet extends StatefulWidget {
  final VoidCallback onPressed;
  const AcceptedBottomsheet({super.key, required this.onPressed});

  @override
  State<AcceptedBottomsheet> createState() => _AcceptedBottomsheetState();
}

class _AcceptedBottomsheetState extends State<AcceptedBottomsheet> {
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
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(Assets.images.tufan.path),
              ),
              const SizedBox(width: 12),
              Text('John', style: AppTypography.labelText),
            ]),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
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
                        child: Text('100', style: AppTypography.labelText)),
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
