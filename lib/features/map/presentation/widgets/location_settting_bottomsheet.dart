import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/features/map/presentation/widgets/selectable_icons_row.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class LocationSetttingBottomsheet extends StatelessWidget {
  final TextEditingController sourceController;
  final TextEditingController destinationController;
  final void Function(String) onTapped;

  const LocationSetttingBottomsheet({
    super.key,
    required this.sourceController,
    required this.destinationController,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableIconsRow(),
                SizedBox(height: 10),
                buildLocationField(
                  label: "From",
                  icon: Icons.location_on_outlined,
                  imagePath: Assets.icons.locationPinSource.path,
                  controller: sourceController,
                ),
                SizedBox(height: 10),
                buildLocationField(
                  label: "To",
                  icon: Icons.location_on_outlined,
                  imagePath: Assets.icons.locationPinDestination.path,
                  controller: destinationController,
                ),
                // SizedBox(height: 30),
                // InkWell(
                //   onTap: () {
                //     setState(() {
                //       _isDestinationSettingOn = true;
                //     });
                //   },
                //   borderRadius: BorderRadius.circular(8),
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //         vertical: 12, horizontal: 16),
                //     decoration: BoxDecoration(
                //       color: AppColors.primaryWhite,
                //       borderRadius:
                //           BorderRadius.circular(8),
                //       border:
                //           Border.all(color: AppColors.gray),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Image.asset(
                //           Assets.icons.carbonMap.path,
                //           width: 24,
                //           height: 24,
                //         ),
                //         const SizedBox(width: 10),
                //         Text(
                //           'Set on Map',
                //           style: AppTypography.paragraph,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Text(
                  "Previous History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...List.generate(
                  4,
                  (index) => ListTile(
                    leading: Icon(Icons.history, color: Colors.orangeAccent),
                    title: Text("Sallaghari, Araniko Highway"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocationField({
    required String label,
    required IconData icon,
    required String imagePath,
    required TextEditingController controller,
  }) {
    return GestureDetector(
      onTap: () => onTapped(label),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Image.asset(imagePath),
            labelText: label,
            labelStyle: TextStyle(
              color: AppColors.gray,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: Image.asset(
              Assets.icons.materialSymbolsSearch.path,
            ),
          ),
        ),
      ),
    );
  }
}
