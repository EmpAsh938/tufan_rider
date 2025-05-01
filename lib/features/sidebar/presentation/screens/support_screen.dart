import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
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
                      'Tufan Support',
                      style: AppTypography.labelText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Support Section
                    _buildSectionHeader('Support'),
                    _buildMenuItem('FAQ', Icons.help_outline, () {
                      // Navigate to FAQ screen
                    }),

                    // Articles Section
                    _buildSectionHeader('Articles'),
                    _buildMenuItem('Article 1', Icons.article, () {
                      // Open Article 1
                    }),
                    _buildMenuItem('Article 2', Icons.article, () {
                      // Open Article 2
                    }),
                    _buildMenuItem('Article 3', Icons.article, () {
                      // Open Article 3
                    }),
                    _buildMenuItem('Article 4', Icons.article, () {
                      // Open Article 4
                    }),
                    _buildMenuItem('Article 5', Icons.article, () {
                      // Open Article 5
                    }),

                    // Contact Section
                    _buildSectionHeader('Reach us'),
                    _buildContactItem('Website', Icons.language, () {
                      _launchUrl('https://yourwebsite.com');
                    }),
                    _buildContactItem('Email', Icons.email, () {
                      _launchUrl('mailto:support@tufan.com');
                    }),
                    _buildContactItem('FB Page', Icons.facebook, () {
                      _launchUrl('https://facebook.com/tufanpage');
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelText.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: AppTypography.labelText),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: AppTypography.labelText),
      subtitle: title == 'Email'
          ? const Text('support@tufan.com')
          : title == 'FB Page'
              ? const Text('facebook.com/tufanpage')
              : const Text('yourwebsite.com'),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
