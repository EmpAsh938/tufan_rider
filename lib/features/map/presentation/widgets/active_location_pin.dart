import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class ActiveLocationPin extends StatelessWidget {
  const ActiveLocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle head
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          // Vertical line as pointer
          Container(
            width: 2,
            height: 10,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
