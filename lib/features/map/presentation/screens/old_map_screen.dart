import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/utils/marker_util.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
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

  // LatLng? _currentLocation;
  // LatLng? _selectedDestination;
  LatLng? _lastCameraPosition;

  bool _locationEnabled = false;
  bool _isDestinationSettingOn = false;
  bool _isSourceSettingOn = false;
  bool _isMapInteractionDisabled = false;

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
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final address = await getAddressFromCoordinates(27.7172, 85.3240);
      locator
          .get<AddressCubit>()
          .setSource(RideLocation(lat: 27.7172, lng: 85.3240, name: address));

      setState(() {
        // _currentLocation = LatLng(position.latitude, position.longitude);
        // _currentLocation = LatLng(27.7172, 85.3240);
        _locationEnabled = true;
        sourceController.text = address;
      });

      await _loadCurrentLocationMarker();

      final GoogleMapController controller = await _controller.future;
      final currentLocation = locator.get<AddressCubit>().source;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(currentLocation!.lat, currentLocation.lng),
              zoom: zoomLevel),
        ),
      );
    } catch (e) {
      setState(() {
        _locationEnabled = false;
      });
    }
  }

  Future<void> _loadCurrentLocationMarker() async {
    final currentLocation = locator.get<AddressCubit>().source;

    if (currentLocation != null) {
      final marker = await MarkerUtil.createMarker(
        markerId: 'current_location',
        position: LatLng(currentLocation.lat - 0.0003, currentLocation.lng),
        assetPath: Assets.icons.locationPinSource.path,
        title: 'You are here',
      );

      setState(() {
        _currentLocationMarker = marker;
      });
    }
  }

  // Generate some dummy markers around the current location
  Future<void> _generateDummyMarkers(LatLng source) async {
    final random = Random();
    final radius = 0.01; // approx 1km
    final basePosition = source;

    setState(() {
      _isMapInteractionDisabled =
          true; // Disable gestures (you'll use this in GoogleMap)
    });

    final controller = await _controller.future;

    // Step 1: Move to center & zoom in smoothly
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: basePosition, zoom: 18),
      ),
    );
    await Future.delayed(Duration(milliseconds: 1000));
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: basePosition, zoom: 16),
      ),
    );

    // Step 2: Move camera upward slightly
    final targetOffset = LatLng(
      basePosition.latitude + 0.0025, // shift north
      basePosition.longitude,
    );
    await Future.delayed(Duration(milliseconds: 1000));
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: targetOffset, zoom: 14),
      ),
    );

    // Step 3: Add dummy markers
    for (int i = 0; i < 5; i++) {
      double offsetLat =
          basePosition.latitude + (random.nextDouble() - 0.5) * radius;
      double offsetLng =
          basePosition.longitude + (random.nextDouble() - 0.5) * radius;

      final markerId = 'dummy_marker_$i';
      final markerPosition = LatLng(offsetLat, offsetLng);

      final marker = await MarkerUtil.createMarker(
        markerId: markerId,
        position: markerPosition,
        assetPath: Assets.icons.bike.path,
        title: 'Dummy Marker $i',
        size: 100,
      );

      setState(() {
        _dummyMarkers.add(marker);
      });
    }

    setState(() {
      _isMapInteractionDisabled = false; // Re-enable map gestures
    });
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
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
          top: MediaQuery.of(context).padding.top - 10,
          // top: 0,
        ),
        child:
            BlocBuilder<AddressCubit, AddressState>(builder: (context, state) {
          return Stack(
            children: [
              // Placeholder for map section (Insert Map here)
              if (_locationEnabled && _currentLocationMarker != null) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentLocationMarker!.position.latitude,
                          _currentLocationMarker!.position.longitude),
                      zoom: zoomLevel,
                    ),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: !_isMapInteractionDisabled,
                    scrollGesturesEnabled: !_isMapInteractionDisabled,
                    rotateGesturesEnabled: !_isMapInteractionDisabled,
                    tiltGesturesEnabled: !_isMapInteractionDisabled,
                    markers: {
                      if (_currentLocationMarker != null)
                        _currentLocationMarker!,
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
                    onCameraMove: (CameraPosition position) {
                      if (_isDestinationSettingOn || _isSourceSettingOn) {
                        _lastCameraPosition = position.target;
                      }
                    },
                    polylines: _polylines,
                    // minMaxZoomPreference: MinMaxZoomPreference(1, 20),
                  ),
                ),
                // set pin
                if (_isDestinationSettingOn || _isSourceSettingOn)
                  Center(
                    child: IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circle head
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          // Vertical line as pointer
                          Container(
                            width: 2,
                            height: 10,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                // draggable scroll sheet

                // menu
                if (!(_isDestinationSettingOn || _isSourceSettingOn))
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

                // current location
                if (!(_isDestinationSettingOn || _isSourceSettingOn))
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.35,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.9), // light background
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

                // done button
                if (_isDestinationSettingOn || _isSourceSettingOn)
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomButton(
                          onPressed: () async {
                            if (_lastCameraPosition == null) return;

                            final latLng = _lastCameraPosition!;
                            final address = await getAddressFromCoordinates(
                              latLng.latitude,
                              latLng.longitude,
                            );

                            final addressCubit = context.read<AddressCubit>();

                            if (_isDestinationSettingOn && context.mounted) {
                              // Clear old destination marker
                              setState(() {
                                _destinationLocationMarker = null;
                              });

                              final destination = RideLocation(
                                lat: latLng.latitude,
                                lng: latLng.longitude,
                                name: address,
                              );

                              addressCubit.setDestination(destination);

                              final newDestMarker =
                                  await MarkerUtil.createMarker(
                                markerId: 'destination',
                                position: latLng,
                                assetPath:
                                    Assets.icons.locationPinDestination.path,
                                title: 'Your Destination',
                              );

                              setState(() {
                                _destinationLocationMarker = newDestMarker;
                                _isDestinationSettingOn = false;
                                destinationController.text = address;
                              });
                            } else if (_isSourceSettingOn) {
                              setState(() {
                                _currentLocationMarker = null;
                              });

                              final source = RideLocation(
                                lat: latLng.latitude,
                                lng: latLng.longitude,
                                name: address,
                              );

                              addressCubit.setSource(source);

                              final newSourceMarker =
                                  await MarkerUtil.createMarker(
                                markerId: 'source',
                                position: latLng,
                                assetPath: Assets.icons.locationPinSource.path,
                                title: 'Your Source',
                              );

                              setState(() {
                                _currentLocationMarker = newSourceMarker;
                                _isSourceSettingOn = false;
                                sourceController.text = address;
                              });
                            }

                            // Get the latest state from the Cubit after updates
                            final updatedState = state;

                            if (context.mounted &&
                                updatedState.source != null &&
                                updatedState.destination != null) {
                              Navigator.pushNamed(
                                      context, AppRoutes.mapofferFare)
                                  .then((_) async {
                                setState(() => _dummyMarkers.clear());

                                await _generateDummyMarkers(
                                  LatLng(updatedState.source!.lat,
                                      updatedState.source!.lng),
                                );

                                _getPolyline(
                                  LatLng(updatedState.source!.lat,
                                      updatedState.source!.lng),
                                  LatLng(updatedState.destination!.lat,
                                      updatedState.destination!.lng),
                                );
                              });
                            }
                          },
                          text: 'Done')),
                if (!(_isDestinationSettingOn || _isSourceSettingOn) &&
                    state.source != null &&
                    state.destination != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Find Drivers',
                            onPressed: () {
                              Navigator.pushNamed(
                                      context, AppRoutes.mapofferFare)
                                  .then((_) async {
                                setState(() => _dummyMarkers.clear());

                                await _generateDummyMarkers(
                                  LatLng(state.source!.lat, state.source!.lng),
                                );

                                _getPolyline(
                                  LatLng(state.source!.lat, state.source!.lng),
                                  LatLng(state.destination!.lat,
                                      state.destination!.lng),
                                );
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            backgroundColor: AppColors.neutralColor,
                            text: 'Cancel',
                            onPressed: () {
                              setState(() {
                                _dummyMarkers.clear();
                                context.read<AddressCubit>().reset();
                                // _currentLocationMarker = null;
                                _destinationLocationMarker = null;
                                _polylines.clear();
                                polylineCoordinates.clear();
                                sourceController.clear();
                                destinationController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else
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
            ],
          );
        }),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.mapAddressSearch,
          arguments: {
            'isFromFocused': label == 'From',
            'isToFocused': label == 'To',
          },
        ).then((addressSearchState) {
          if (addressSearchState != null &&
              addressSearchState is Map<String, dynamic>) {
            if (addressSearchState['isFromFocused']) {
              setState(() {
                _isSourceSettingOn = true;
              });
            }
            if (addressSearchState['isToFocused']) {
              setState(() {
                _isDestinationSettingOn = true;
              });
            }
          }
        });
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
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
        ),
      ),
    );
  }
}
