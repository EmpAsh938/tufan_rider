import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';

class OfferFareScreen extends StatefulWidget {
  const OfferFareScreen({super.key});

  @override
  State<OfferFareScreen> createState() => _OfferFareScreenState();
}

class _OfferFareScreenState extends State<OfferFareScreen> {
  TextEditingController fareController = TextEditingController(text: '160340');
  bool isCashSelected = true;
  bool autoAccept = false;

  @override
  void dispose() {
    fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Center(
              child: Text(
                "Total amount",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 4),
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
                  border: InputBorder.none,
                  prefixText: 'NRs.',
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            const Text("Select your route",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _routeRow("From", "Your current location",
                      Icons.radio_button_checked),
                  const Divider(),
                  _routeRow(
                      "Where to", "Enter location", Icons.location_on_outlined),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _paymentMethodSelector(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Automatically accept the nearest driver for your fare",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                CustomSwitch(
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
    );
  }

  Widget _routeRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
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
        const Text("Payment Method",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                color: selected ? Colors.blue : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: selected ? Colors.blue.shade50 : Colors.grey.shade100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Colors.blue : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmFare(int fare) {
    print("User offered fare: ₹$fare");
    // handle submission here (API call or navigation)
  }
}
