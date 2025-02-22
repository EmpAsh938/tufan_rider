import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';

class RideHistoryScreen extends StatelessWidget {
  RideHistoryScreen({super.key});

  final List<Ride> rides = [
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Completed",
        "bike"),
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Cancelled",
        "car"),
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Completed",
        "bike"),
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Completed",
        "car"),
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Completed",
        "bike"),
    Ride("Jan 02, 5:55 pm", "Sallaghari", "Koteshwor", "Rs. 555", "Cancelled",
        "bike"),
  ];

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
        title: 'Ride History',
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            return RideCard(ride: rides[index]);
          },
        ));
  }
}

class Ride {
  final String time;
  final String from;
  final String to;
  final String fare;
  final String status;
  final String vehicleType;

  Ride(this.time, this.from, this.to, this.fare, this.status, this.vehicleType);
}

class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: AppColors.primaryWhite,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Fare Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride.time,
                  style: AppTypography.smallText,
                ),
                Text(
                  ride.fare,
                  style: AppTypography.smallText,
                ),
              ],
            ),
            // Location and Vehicle Row
            Row(
              children: [
                Image.asset(
                  'assets/icons/location_pin_source.png',
                ),
                SizedBox(width: 5),
                Text(
                  ride.from,
                  style: AppTypography.smallText,
                ),
                Spacer(),
                Image.asset(
                  ride.vehicleType == "bike"
                      ? "assets/icons/bike.png"
                      : "assets/icons/car.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                Spacer(),
                Image.asset(
                  'assets/icons/location_pin_destination.png',
                ),
                SizedBox(width: 5),
                Text(ride.to, style: TextStyle(fontSize: 14)),
              ],
            ),
            // Status
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                ride.status,
                style: AppTypography.smallText.copyWith(
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                  color: ride.status == "Completed"
                      ? AppColors.primaryGreen
                      : AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
