import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_bottomsheet.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/rider/map/presentation/widgets/accepted_bottomsheet.dart';
import 'package:tufan_rider/features/rider/map/presentation/widgets/bargain_price_bottomsheet.dart';
import 'package:tufan_rider/features/rider/map/presentation/widgets/rider_request_card_popup.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({super.key});

  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(27.7172, 85.3240),
    zoom: 10,
  );

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late String _mapStyleString;

  bool isAccepted = false;
  bool isBargain = false;

  Future<void> _loadMapStyle() async {
    _mapStyleString = await rootBundle.loadString(Assets.mapStyles);
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    // _checkAndFetchLocation();
    // _getAddressFromLatLng(_center);
    // animationInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: RiderMapScreen._kDefaultLocation,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _controller.complete(controller);
              controller.setMapStyle(_mapStyleString);
            },
          ),

          // Drawer
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(1), // Adds space around the icon
              decoration: BoxDecoration(
                color: AppColors.primaryWhite, // Background color
                borderRadius: BorderRadius.circular(15), // Makes it circular
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack
                        .withOpacity(0.1), // Optional shadow
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(
                    Icons.menu,
                    color: AppColors.primaryBlack,
                    size: 30,
                  ),
                );
              }),
            ),
          ),

          // popups
          if (!isAccepted && !isBargain)
            RiderRequestCardPopup(
              prepareDriverArriving: () {
                setState(() {
                  isBargain = true;
                });
              },
            ),

// bargain bottomsheet
          if (isBargain)
            CustomBottomsheet(
                minHeight: MediaQuery.of(context).size.height * 0.3,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
                child: BargainPriceBottomsheet(onPressed: () {
                  setState(() {
                    isBargain = false;
                    isAccepted = true;
                  });
                })),

          // accepted bottomsheet
          if (isAccepted)
            CustomBottomsheet(
                minHeight: MediaQuery.of(context).size.height * 0.3,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
                child: AcceptedBottomsheet(onPressed: () {
                  setState(() {
                    isBargain = false;
                    isAccepted = false;
                  });
                })),
        ],
      ),
      drawer: CustomDrawer(),
    ));
  }
}
