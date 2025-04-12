import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class SelectableIconsRow extends StatefulWidget {
  const SelectableIconsRow({super.key});

  @override
  State<SelectableIconsRow> createState() => _SelectableIconsRowState();
}

class _SelectableIconsRowState extends State<SelectableIconsRow> {
  String selectedIcon = 'bike'; // Keep track of the selected icon

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSelectableIcon(
          imagePath: Assets.icons.bike.path,
          isSelected: selectedIcon == 'bike',
          onTap: () => setState(() => selectedIcon = 'bike'),
        ),
        const SizedBox(width: 30),
        const SizedBox(
          height: 80,
          child: VerticalDivider(
            thickness: 2,
            width: 2,
            color: AppColors.gray,
          ),
        ),
        const SizedBox(width: 30),
        _buildSelectableIcon(
          imagePath: Assets.icons.car.path,
          isSelected: selectedIcon == 'car',
          onTap: () => setState(() => selectedIcon = 'car'),
        ),
      ],
    );
  }

  Widget _buildSelectableIcon({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.neutralColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
