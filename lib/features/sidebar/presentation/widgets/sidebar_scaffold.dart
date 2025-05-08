import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';

class SidebarScaffold extends StatefulWidget {
  final Widget child;
  final String title;
  const SidebarScaffold({super.key, required this.child, required this.title});

  @override
  State<SidebarScaffold> createState() => _SidebarScaffoldState();
}

class _SidebarScaffoldState extends State<SidebarScaffold> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.primaryBlack : AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor:
              isDarkMode ? AppColors.primaryBlack : AppColors.backgroundColor,
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: isDarkMode
                    ? AppColors.backgroundColor
                    : AppColors.primaryBlack,
              ),
            );
          }),
          title: Text(
            widget.title,
            style: AppTypography.paragraph.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: widget.child,
        ),
        drawer: CustomDrawer(),
      ),
    );
  }
}
