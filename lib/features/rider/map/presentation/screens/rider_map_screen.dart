import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/widgets/custom_bottomsheet.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
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

  LatLng _center = RiderMapScreen._kDefaultLocation.target;

  late String _mapStyleString;

  bool _locationEnabled = false;
  bool _isLoading = true;
  bool isAccepted = false;
  bool isBargain = false;
  RideRequestModel? request;
  Set<Marker> _markers = {};

  Future<void> _checkAndFetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          setState(() {
            _locationEnabled = false;
            _isLoading = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final address = await _getAddressFromLatLng(_center);

      // // put updated coordinates
      // locator.get<AddressCubit>().setSource(RideLocation(
      //     lat: _center.latitude, lng: _center.longitude, name: address));

      // await locator.get<AddressCubit>().sendCurrentLocationToServer();

      setState(() {
        // _center = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
        // sourceController.text = address ?? '';
        _isLoading = false;
        final currentLocationMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: _center,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Your Location"),
        );
        _markers.add(currentLocationMarker);
      });

      final GoogleMapController controller = await _controller.future;
      // final currentLocation = locator.get<AddressCubit>().source;
      // controller.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //         target: LatLng(currentLocation!.lat, currentLocation.lng),
      //         zoom: zoomLevel),
      //   ),
      // );
    } catch (e) {
      setState(() {
        _locationEnabled = false;
        // _currentLocationMarker = null;
        _isLoading = false;
      });
    }
  }

  Future<String?> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Use null-aware operators and fallback values
        String name = place.name ?? '';
        String locality = place.locality ?? '';
        String administrativeArea = place.administrativeArea ?? '';
        String country = place.country ?? '';

        String address = "$name, $locality, $administrativeArea, $country";

        return address.trim().replaceAll(RegExp(r'^,+|,+$'), '');
      } else {
        return "Unknown Location";
      }
    } catch (e) {
      print("Error getting address: $e");
      return "";
    }
  }

  Future<void> _loadMapStyle() async {
    _mapStyleString = await rootBundle.loadString(Assets.mapStyles);
  }

  Marker createMarker({
    required LatLng position,
    required String label,
    BitmapDescriptor? icon,
    String? snippet,
    MarkerId? markerId,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: markerId ?? MarkerId(position.toString()),
      position: position,
      icon: icon ?? BitmapDescriptor.defaultMarker, // fallback to default
      infoWindow: InfoWindow(
        title: label,
        snippet: snippet ?? 'Unknown Location',
      ),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _checkAndFetchLocation();
    // _getAddressFromLatLng(_center);
    // animationInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.neutralColor,
              ),
            )
          : _locationEnabled
              ? Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: RiderMapScreen._kDefaultLocation,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      markers: _markers,
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
                        padding:
                            EdgeInsets.all(1), // Adds space around the icon
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhite, // Background color
                          borderRadius:
                              BorderRadius.circular(15), // Makes it circular
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
                        prepareDriverArriving: (RideRequestModel request) {
                          setState(() {
                            isBargain = true;
                            this.request = request;

                            final passengerMarker = {
                              // Create a new Set instead of clearing the existing one
                              createMarker(
                                position: LatLng(
                                    request.dLatitude, request.dLongitude),
                                label: request.sName,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue),
                                snippet: request.rideRequestId.toString(),
                                markerId:
                                    MarkerId(request.rideRequestId.toString()),
                              ),
                            };
                            _markers.addAll(passengerMarker);
                          });
                          _controller.future.then((controller) {
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                      request.dLatitude, request.dLongitude),
                                  zoom:
                                      12.0, // Adjust zoom level as needed (15–17 is usually good for streets)
                                ),
                              ),
                            );
                          });
                        },
                      ),

// bargain bottomsheet
                    if (isBargain && request != null)
                      CustomBottomsheet(
                          minHeight: MediaQuery.of(context).size.height * 0.3,
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                          child: BargainPriceBottomsheet(
                            onPressed: () {
                              setState(() {
                                isBargain = false;
                                isAccepted = true;
                              });
                            },
                            request: request!,
                          )),

                    // accepted bottomsheet
                    if (isAccepted && request != null)
                      CustomBottomsheet(
                          minHeight: MediaQuery.of(context).size.height * 0.3,
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                          child: AcceptedBottomsheet(
                            onPressed: () {
                              setState(() {
                                isBargain = false;
                                isAccepted = false;
                              });
                            },
                            request: request!,
                          )),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off, size: 48, color: Colors.red),
                      SizedBox(height: 10),
                      Text(
                        "Location is disabled.\nPlease enable location services.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await Geolocator.openLocationSettings();
                          _checkAndFetchLocation(); // Retry
                        },
                        child: Text("Enable Location"),
                      ),
                    ],
                  ),
                ),
      drawer: CustomDrawer(),
    ));
  }
}
