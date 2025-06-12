import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';

/// A row that lets you tap to pick a file (e.g. an image),
/// displays [label] or the chosen filename, and shows a thumbnail if [pickedFile] or [networkImageUrl] is provided.
class CustomFileupload extends StatelessWidget {
  final String label;
  final File? pickedFile;
  final String? networkImageUrl;
  final VoidCallback onTap;

  const CustomFileupload({
    super.key,
    required this.label,
    this.pickedFile,
    this.networkImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText =
        pickedFile != null ? pickedFile!.path.split('/').last : label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Text or filename
            Expanded(
              child: Text(
                displayText,
                style: AppTypography.labelText.copyWith(
                  color: pickedFile != null || networkImageUrl != null
                      ? AppColors.primaryBlack
                      : AppColors.primaryBlack.withOpacity(0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12),

            // Thumbnail (local or network) or placeholder icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildImageThumbnail(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail() {
    if (pickedFile != null) {
      return Image.file(pickedFile!, fit: BoxFit.cover);
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return Image.network(networkImageUrl!, fit: BoxFit.cover);
    } else {
      return Icon(Icons.upload_file, color: AppColors.primaryColor);
    }
  }
}
