import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title: 'Emergency',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectableIcon(
                  'assets/icons/contact.png', 'Emergency Contact Lists'),
              SizedBox(
                width: 20,
              ),
              _buildSelectableIcon('assets/icons/alert.png', 'Emergency Alert'),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _buildDescriptionText(
              'On pressing emergency contact lists, the contacts you have added will get notified about your situation.'),
          SizedBox(
            height: 20,
          ),
          _buildDescriptionText(
              'On pressing emergency Alert, your call will be redirected to Nepal Police.'),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Emergency Contact Lists',
              style: AppTypography.paragraph,
              textAlign: TextAlign.left,
            ),
          ),
          _buildContactLists(),
          _buildContactLists(),
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Add Contact',
              onPressed: () {},
              backgroundColor: AppColors.gray,
              textColor: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableIcon(String imagePath, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align elements
      children: [
        Container(
          padding: EdgeInsets.all(8), // Add padding to the container
          decoration: BoxDecoration(
            color: AppColors
                .backgroundColor, // Background color for the image container
            border: Border.all(
              color: AppColors.primaryColor,
              width: 1, // Slightly thicker border for more prominence
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2), // Shadow to give depth
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(50), // Ensure the image is rounded
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(height: 8), // Add space between the image and the title
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: AppTypography.smallText.copyWith(
              color: AppColors.primaryRed,
              fontSize: 14,
              fontWeight: FontWeight.w500, // Slightly bolder text for emphasis
            ),
            textAlign: TextAlign.center, // Center-align the text
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText(String description) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align the image and text properly
      children: [
        Image.asset(
          'assets/icons/warning.png',
          width: 20, // Set fixed width for the image
          height: 20, // Set fixed height for the image
        ),
        SizedBox(width: 10), // Space between the image and text
        Flexible(
          child: Text(
            description,
            style: AppTypography.smallText,
            textAlign: TextAlign.justify,
            softWrap: true, // Allow text to wrap
          ),
        ),
      ],
    );
  }

  Widget _buildContactLists() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'John Doe',
          style: AppTypography.smallText.copyWith(
            fontSize: 14,
          ),
        ),
        Text(
          '9811111111',
          style: AppTypography.smallText.copyWith(
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.edit,
                  size: 20,
                  color: AppColors.primaryBlack,
                )),
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.primaryBlack,
                )),
          ],
        )
      ],
    );
  }
}
