import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/map/presentation/widgets/selectable_icons_row.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class LocationSetttingBottomsheet extends StatefulWidget {
  final TextEditingController sourceController;
  final TextEditingController destinationController;
  final void Function(String) onTapped;
  final VoidCallback onPressed;
  final void Function(int) onCategoryChanged;
  final int categoryId;

  const LocationSetttingBottomsheet({
    super.key,
    required this.sourceController,
    required this.destinationController,
    required this.categoryId,
    required this.onTapped,
    required this.onPressed,
    required this.onCategoryChanged,
  });

  @override
  State<LocationSetttingBottomsheet> createState() =>
      _LocationSetttingBottomsheetState();
}

class _LocationSetttingBottomsheetState
    extends State<LocationSetttingBottomsheet> {
  bool isLoading = false;
  Future<void> fetchRideHistory() async {
    if (!mounted) return;
    try {
      setState(() {
        isLoading = true;
      });
      await context.read<AddressCubit>().showRideHistory();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRideHistory();
  }

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
                // Transportation type selector
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableIconsRow(
                    categoryId: widget.categoryId,
                    onCategoryChanged: widget.onCategoryChanged,
                  ),
                ),
                const SizedBox(height: 20),

                // Location fields
                Column(
                  children: [
                    buildLocationField(
                      label: "From",
                      icon: Icons.location_on_outlined,
                      imagePath: Assets.icons.locationPinSource.path,
                      controller: widget.sourceController,
                    ),
                    const SizedBox(height: 16),
                    buildLocationField(
                      label: "To",
                      icon: Icons.location_on_outlined,
                      imagePath: Assets.icons.locationPinDestination.path,
                      controller: widget.destinationController,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Set on Map button (commented out)
                // const SizedBox(height: 30),
                // InkWell(...)

                // History section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Previous History",
                        style: AppTypography.headline.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      !isLoading
                          ? BlocBuilder<AddressCubit, AddressState>(
                              builder: (context, state) {
                                if (state.rideHistory.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'No ride history yet',
                                        style: AppTypography.labelText.copyWith(
                                          color: AppColors.primaryBlack
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ...state.rideHistory.take(5).map((place) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                final source = RideLocation(
                                                  lat: place.sLatitude,
                                                  lng: place.sLongitude,
                                                  name: place.sName,
                                                );
                                                final destination =
                                                    RideLocation(
                                                  lat: place.dLatitude,
                                                  lng: place.dLongitude,
                                                  name: place.dName,
                                                );
                                                context
                                                    .read<AddressCubit>()
                                                    .setSource(source);
                                                context
                                                    .read<AddressCubit>()
                                                    .setDestination(
                                                        destination);
                                                widget.onPressed();
                                              },
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              leading: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryColor
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.history,
                                                  color: AppColors.primaryColor,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                place.dName,
                                                style: AppTypography.labelText
                                                    .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                place.sName,
                                                style: AppTypography.smallText
                                                    .copyWith(
                                                  color: AppColors.primaryBlack
                                                      .withOpacity(0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: AppColors.primaryBlack
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                            const Divider(
                                                height: 1, indent: 60),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                    ],
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
      onTap: () => widget.onTapped(label),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
              ),
            ),
            labelText: label,
            labelStyle: AppTypography.labelText.copyWith(
              color: AppColors.primaryBlack.withOpacity(0.6),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: AppColors.backgroundColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryBlack.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryBlack.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                Assets.icons.materialSymbolsSearch.path,
                width: 24,
                height: 24,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
