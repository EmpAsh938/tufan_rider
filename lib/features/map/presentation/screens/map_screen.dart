import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/marker_util.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/map/presentation/widgets/selectable_icons_row.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class MapBookingScreen extends StatefulWidget {
  const MapBookingScreen({super.key});

  @override
  State<MapBookingScreen> createState() => _MapBookingScreenState();
}

class _MapBookingScreenState extends State<MapBookingScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  late String _mapStyleString;

  double zoomLevel = 12;

  LatLng? _currentLocation;
  LatLng? _selectedDestination;

  bool _locationEnabled = false;
  bool _isLoading = true;
  bool _isDestinationSettingOn = false;

  Marker? _currentLocationMarker;
  Marker? _destinationLocationMarker;

  final Set<Marker> _dummyMarkers = {};

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Future<void> _checkAndFetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
          _isLoading = false; // Stop loading if location is disabled
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
            _isLoading = false; // Stop loading if permission is denied
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final address = await getAddressFromCoordinates(27.7172, 85.3240);

      setState(() {
        // _currentLocation = LatLng(position.latitude, position.longitude);
        _currentLocation = LatLng(27.7172, 85.3240);
        _locationEnabled = true;
        _isLoading = false;
        sourceController.text = address;
      });

      await _loadCurrentLocationMarker();

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: zoomLevel),
        ),
      );
    } catch (e) {
      setState(() {
        _locationEnabled = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentLocationMarker() async {
    if (_currentLocation != null) {
      final marker = await MarkerUtil.createMarker(
        markerId: 'current_location',
        position: _currentLocation!,
        assetPath: Assets.icons.locationPinSource.path,
        title: 'You are here',
      );

      setState(() {
        _currentLocationMarker = marker;
      });
    }
  }

  // Generate some dummy markers around the current location
  Future<void> _generateDummyMarkers() async {
    final random = Random();
    final radius = 0.01; // approx 1km radius

    // Generate 5 dummy markers
    for (int i = 0; i < 5; i++) {
      double offsetLat =
          _currentLocation!.latitude + (random.nextDouble() - 0.5) * radius;
      double offsetLng =
          _currentLocation!.longitude + (random.nextDouble() - 0.5) * radius;

      final markerId = 'dummy_marker_$i';
      final markerPosition = LatLng(offsetLat, offsetLng);

      final marker = await MarkerUtil.createMarker(
        markerId: markerId,
        position: markerPosition,
        assetPath: Assets.icons.bike.path, // Custom marker icon
        title: 'Dummy Marker $i',
        size: 100, // You can adjust the size
      );

      setState(() {
        _dummyMarkers.add(marker);
      });
    }
  }

  Future<void> _loadMapStyle() async {
    _mapStyleString = await rootBundle.loadString(Assets.mapStyles);
  }

  void _drawPolyline(LatLng start, LatLng end) {
    final Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue,
      width: 5,
      points: polylineCoordinates,
    );

    setState(() {
      _polylines.clear();

      _polylines = {polyline};
    });
  }

  void _getPolyline(LatLng currentLocation, LatLng destinationLocation) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: ApiConstants.mapAPI,
      request: PolylineRequest(
        origin:
            PointLatLng(currentLocation.latitude, currentLocation.longitude),
        destination: PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude),
        mode: TravelMode.driving,
        // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _drawPolyline(currentLocation, destinationLocation);
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
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

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _checkAndFetchLocation();
  }

  @override
  void dispose() {
    super.dispose();
    sourceController.dispose();
    destinationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Stack(
          children: [
            // Placeholder for map section (Insert Map here)
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (_locationEnabled && _currentLocation != null)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: zoomLevel,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    if (_currentLocationMarker != null) _currentLocationMarker!,
                    if (_destinationLocationMarker != null)
                      _destinationLocationMarker!,
                    ..._dummyMarkers, // Add dummy markers here
                  },
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                      controller.setMapStyle(_mapStyleString);
                    }
                  },
                  onCameraMove: (CameraPosition position) async {
                    if (_isDestinationSettingOn) {
                      _selectedDestination = position.target;
                      // _selectedDestination = LatLng(27.6945, 85.3088);
                      final address = await getAddressFromCoordinates(
                          _selectedDestination!.latitude,
                          _selectedDestination!.longitude);

                      setState(() {
                        zoomLevel = 10;
                        destinationController.text = address;
                        // destinationController.text =
                        //     "${position.target.latitude} ${position.target.longitude}";
                      });
                    }
                  },
                  polylines: _polylines,
                  minMaxZoomPreference: MinMaxZoomPreference(1, 20),
                ),
              )
            else
              Center(
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
            if (_isDestinationSettingOn)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 -
                    96, // Center vertically
                left: MediaQuery.of(context).size.width / 2 -
                    24, // Center horizontally
                child: Image.asset(
                  Assets.icons.locationPinDestination.path,
                  width: 48,
                  height: 48,
                ),
              ),

            if (!_isDestinationSettingOn)
              DraggableScrollableSheet(
                initialChildSize: 0.35,
                minChildSize: 0.35,
                maxChildSize: 0.75,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Notch Handle
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SelectableIconsRow(),
                                SizedBox(height: 10),
                                buildLocationField(
                                  label: "From",
                                  icon: Icons.location_on_outlined,
                                  imagePath:
                                      Assets.icons.locationPinSource.path,
                                  controller: sourceController,
                                ),
                                SizedBox(height: 10),
                                buildLocationField(
                                  label: "To",
                                  icon: Icons.location_on_outlined,
                                  imagePath:
                                      Assets.icons.locationPinDestination.path,
                                  controller: destinationController,
                                ),
                                SizedBox(height: 30),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isDestinationSettingOn = true;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.gray),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          Assets.icons.carbonMap.path,
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Set on Map',
                                          style: AppTypography.paragraph,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Previous History",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                ...List.generate(
                                  4,
                                  (index) => ListTile(
                                    leading: Icon(Icons.history,
                                        color: Colors.orangeAccent),
                                    title: Text("Sallaghari, Araniko Highway"),
                                    trailing:
                                        Icon(Icons.arrow_forward_ios, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            if (!_isDestinationSettingOn)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.all(1), // Adds space around the icon
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

            if (!_isDestinationSettingOn)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.35,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // light background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      _checkAndFetchLocation();
                    },
                    iconSize: 34,
                    icon: const Icon(Icons.location_searching_outlined),
                  ),
                ),
              ),

            if (_isDestinationSettingOn)
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomButton(
                      onPressed: () async {
                        if (_selectedDestination != null) {
                          final marker = await MarkerUtil.createMarker(
                            markerId: 'destination',
                            position: _selectedDestination!,
                            assetPath: Assets.icons.locationPinDestination.path,
                            title: 'Your Destination',
                          );

                          if (_currentLocation != null &&
                              _selectedDestination != null) {
                            // _getPolyline(
                            //     _currentLocation!, _selectedDestination!);
                            await _generateDummyMarkers();
                          }

                          setState(() {
                            _destinationLocationMarker = marker;
                            _isDestinationSettingOn = false;
                          });
                        }
                      },
                      text: 'Done'))
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget buildLocationField({
    required String label,
    required IconData icon,
    required String imagePath,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Image.asset(imagePath),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.gray,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: Image.asset(
          Assets.icons.materialSymbolsSearch.path,
        ),
      ),
    );
  }
}
