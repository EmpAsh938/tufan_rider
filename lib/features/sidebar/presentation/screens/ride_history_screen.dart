import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/date_utils.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/sidebar/models/ride_history.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool _isLoading = true;

  Future<void> getDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on Android:');
        print('Brand: ${androidInfo.brand}');
        print('Device: ${androidInfo.device}');
        print('Model: ${androidInfo.model}');
        print('Android Version: ${androidInfo.version.release}');
        print('SDK: ${androidInfo.version.sdkInt}');
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on iOS:');
        print('Model: ${iosInfo.utsname.machine}');
        print('System Version: ${iosInfo.systemVersion}');
        print('System Name: ${iosInfo.systemName}');
        print('Name: ${iosInfo.name}');
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }
  }

  Future<void> fetchRideHistory() async {
    try {
      final loginResponse = context.read<AuthCubit>().loginResponse;
      if (loginResponse == null) return;

      final userId = loginResponse.user.id.toString();
      final isRider = loginResponse.user.roles[0].name.contains('RIDER');

      if (isRider) {
        await context.read<AddressCubit>().getRiderHistory(userId);
      } else {
        await context.read<AddressCubit>().getPassengerHistory(userId);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getDeviceDetails();
  }

  @override
  void initState() {
    super.initState();
    fetchRideHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
        title: 'Ride History',
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.neutralColor,
                ),
              )
            : BlocBuilder<AddressCubit, AddressState>(
                builder: (context, state) {
                final loginResponse = context.read<AuthCubit>().loginResponse;
                final isRider =
                    loginResponse?.user.roles[0].name.contains('RIDER') ??
                        false;

                final historyList =
                    isRider ? state.riderHistory : state.passengerHistory;

                if (historyList.isEmpty) {
                  return Center(
                    child: Text(
                      'No ride history',
                      style: AppTypography.smallText,
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      if (historyList[index].status.toLowerCase().trim() ==
                          'ride_complete') {
                        return RideCard(ride: historyList[index]);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              }));
  }
}

class RideCard extends StatefulWidget {
  final RideHistory ride;

  const RideCard({super.key, required this.ride});

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
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
                  DateUtilsHelper.formatDateTime(widget.ride.addedDate),
                  style: AppTypography.smallText,
                ),
                Text(
                  "NRs.${widget.ride.actualPrice.toStringAsFixed(0)}",
                  style: AppTypography.smallText,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Location and Vehicle Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Source Pin
                Image.asset(
                  Assets.icons.locationPinSource.path,
                  width: 20,
                  height: 20,
                ),
                // SizedBox(width: 4),

                // Source Name
                Flexible(
                  child: Text(
                    widget.ride.sName.split(',')[1],
                    style: AppTypography.smallText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                // SizedBox(width: 8),

                // Vehicle Image
                Image.asset(
                  widget.ride.category.categoryTitle.toLowerCase() == "bike"
                      ? Assets.icons.bike.path
                      : Assets.icons.car.path,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),

                // SizedBox(width: 8),

                // Destination Name
                Flexible(
                  child: Text(
                    widget.ride.dName.split(',')[1],
                    style: AppTypography.smallText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                // SizedBox(width: 4),

                // Destination Pin
                Image.asset(
                  Assets.icons.locationPinDestination.path,
                  width: 20,
                  height: 20,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Status
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                widget.ride.status == 'RIDE_COMPLETE'
                    ? 'COMPLETED'
                    : widget.ride.status,
                style: AppTypography.smallText.copyWith(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
