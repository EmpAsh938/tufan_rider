import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_textfield.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title: 'Personal Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryColor,
            child: Icon(
              Icons.person,
              color: AppColors.primaryBlack,
              size: 60,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          CustomTextField(
              controller: firstNameController,
              hintText: '',
              labelText: 'First Name'),
          SizedBox(
            height: 20,
          ),
          CustomTextField(
              controller: lastNameController,
              hintText: '',
              labelText: 'Last Name'),
          SizedBox(
            height: 20,
          ),
          CustomTextField(
              controller: emailController, hintText: '', labelText: 'Email'),
          Spacer(),
          CustomButton(text: 'Save', onPressed: () {}),
        ],
      ),
    );
  }
}
