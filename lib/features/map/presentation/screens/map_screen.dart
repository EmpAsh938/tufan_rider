import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/map_helper.dart';
import 'package:tufan_rider/core/widgets/custom_bottomsheet.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/map/models/ride_proposal_model.dart';
import 'package:tufan_rider/features/map/presentation/widgets/active_location_pin.dart';
import 'package:tufan_rider/features/map/presentation/widgets/driver_arriving_bottomsheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/location_settting_bottomsheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/offer_price_bottom_sheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/request_card_popup.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(27.713721408198094, 85.37806766739013),
    zoom: 10,
  );

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  late String _mapStyleString;

  LatLng _center = MapScreen._kDefaultLocation.target;

  final Set<Marker> _dummyMarkers = {};
  Map<String, Marker> _riderMarkers = {}; // Keyed by rider id or rideRequestId

  double zoomLevel = 12;
  bool _locationEnabled = false;
  bool _isDestinationSettingOn = false;
  bool _isSourceSettingOn = false;
  bool _isMapInteractionDisabled = false;
  bool _isLoading = true;
  bool _isFindingDrivers = false;
  bool _hasAcceptedRequest = false;

  Marker? _currentLocationMarker;
  Marker? _destinationLocationMarker;

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Set<Circle> _animatedCircle = {};
  late AnimationController _circleAnimationController;
  late Animation<double> _radiusAnimation;

  Future<void> _checkAndFetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
          _currentLocationMarker = null;
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
            _currentLocationMarker = null;
            _isLoading = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final address = await _getAddressFromLatLng(_center);

      // put updated coordinates
      locator.get<AddressCubit>().setSource(RideLocation(
          lat: _center.latitude, lng: _center.longitude, name: address));

      await locator.get<AddressCubit>().sendCurrentLocationToServer();

      setState(() {
        // _center = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
        sourceController.text = address ?? '';
        _isLoading = false;
        _currentLocationMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: _center,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Your Location"),
        );
      });

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
        _currentLocationMarker = null;
        _isLoading = false;
      });
    }
  }

  // Reverse geocode
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

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _center = position.target;
    });
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

  void _getPolyline(LatLng riderLocation, LatLng sourceLocation,
      LatLng destinationLocation) async {
    try {
      // Get route from current location to mid-point
      PolylineResult resultToMid =
          await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: ApiConstants.mapAPI,
        request: PolylineRequest(
          origin: PointLatLng(
              destinationLocation.latitude, destinationLocation.longitude),
          destination:
              PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
          mode: TravelMode.driving,
          optimizeWaypoints: true,
        ),
      );

      // Get route from mid-point to destination
      PolylineResult resultToDestination =
          await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: ApiConstants.mapAPI,
        request: PolylineRequest(
          origin:
              PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
          destination:
              PointLatLng(riderLocation.latitude, riderLocation.longitude),
          mode: TravelMode.driving,
          optimizeWaypoints: true,
        ),
      );

      // Clear previous coordinates and add new ones
      polylineCoordinates.clear();
      polylineCoordinates.add(destinationLocation);

      if (resultToMid.points.isNotEmpty) {
        for (var point in resultToMid.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      polylineCoordinates.add(sourceLocation);

      if (resultToDestination.points.isNotEmpty) {
        for (var point in resultToDestination.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      polylineCoordinates.add(riderLocation);

      // Draw the polyline
      _drawPolyline(destinationLocation, riderLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _generateDummyMarkers(LatLng source) async {
    final random = Random();
    final radius = 0.05; // approx 3km
    final basePosition = source;

    setState(() => _isMapInteractionDisabled = true);

    final controller = await _controller.future;
    _circleAnimationController.reset();

    // Configure animations
    final radiusTween = Tween<double>(begin: 10.0, end: 1000.0);
    final zoomTween = Tween<double>(begin: 18.0, end: 14.0);

    // Use the same animation controller for both animations
    final radiusAnimation = radiusTween.animate(
      CurvedAnimation(
        parent: _circleAnimationController,
        curve: Curves.easeInOutCubic, // Smoother curve
      ),
    );

    // Add a small delay to prevent initial stutter
    await Future.delayed(const Duration(milliseconds: 100));

    // Animation listener
    radiusAnimation.addListener(() {
      final currentProgress = _circleAnimationController.value;
      final currentZoom = zoomTween.transform(currentProgress);

      setState(() {
        _animatedCircle = {
          Circle(
            circleId: const CircleId('animatedCircle'),
            center: _center,
            radius: radiusAnimation.value,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        };
      });

      // Use newLatLngZoom for smoother camera transitions
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(
          basePosition,
          currentZoom,
        ),
      );
    });

    // Start the animation
    Future.microtask(() async {
      await _circleAnimationController.forward();
    });
    // Add markers with staggered appearance
    for (int i = 0; i < 5; i++) {
      final offsetLat =
          basePosition.latitude + (random.nextDouble() - 0.5) * radius;
      final offsetLng =
          basePosition.longitude + (random.nextDouble() - 0.5) * radius;

      setState(() {
        _dummyMarkers.add(
          createMarker(
            position: LatLng(offsetLat, offsetLng),
            label: 'Vehicles Position',
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }
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

  Future<LatLng?> getPinPointedCoordinates() async {
    try {
      final controller = await _controller.future;

      final screenCoordinate = await controller.getScreenCoordinate(_center);

      const double circleHeight = 26;
      const double lineHeight = 10;
      final offsetY = ((circleHeight / 2) + lineHeight).round();

      final adjustedScreenCoordinate = ScreenCoordinate(
        x: screenCoordinate.x,
        y: screenCoordinate.y + offsetY,
      );

      final LatLng pinTipPosition =
          await controller.getLatLng(adjustedScreenCoordinate);

      return pinTipPosition;
    } catch (e) {
      developer.log('Getting pin point coordinates failed $e');
      return null;
    }
  }

  Future<void> _loadMapStyle() async {
    _mapStyleString = await rootBundle.loadString(Assets.mapStyles);
  }

  void animationInitialization() {
    _circleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );

    _radiusAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(
        parent: _circleAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  void resetMap() {
    context.read<AddressCubit>().reset();
    // context.read<StompSocketCubit>().disconnect();
    setState(() {
      _isFindingDrivers = false;
      _hasAcceptedRequest = false;
      _dummyMarkers.clear();
      _destinationLocationMarker = null;
      _polylines.clear();
      _riderMarkers.clear();

      polylineCoordinates.clear();
      destinationController.clear();
      _animatedCircle.clear();
      _isMapInteractionDisabled = false;
    });
    // _circleAnimationController.reset();
    // _radiusAnimation = null;
  }

  void setLocationForUser(String label) {
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
            _isDestinationSettingOn = false;
          });
        }
        if (addressSearchState['isToFocused']) {
          setState(() {
            _isSourceSettingOn = false;
            _isDestinationSettingOn = true;
          });
        }
      }
      final addressInfo = locator.get<AddressCubit>().fetchAddress();
      final source = addressInfo.source;
      final destination = addressInfo.destination;
      setState(() {
        if (source != null) sourceController.text = source.name ?? '';
        if (destination != null) {
          destinationController.text = destination.name ?? '';
        }
      });
    });
  }

  void prepareDriverArriving() async {
    // Reverse the animation first (for a smooth shrink effect)
    if (_circleAnimationController.isAnimating ||
        _circleAnimationController.value > 0) {
      await _circleAnimationController.reverse();
    }

    // Then reset and clear states
    setState(() {
      _animatedCircle.clear();
      _dummyMarkers.clear();
      _isFindingDrivers = false;
      _hasAcceptedRequest = true;
    });

    _circleAnimationController.reset();
  }

  void addRidersMarker(RideProposalModel request) async {
    // Create or update marker
    // final newMarker = createMarker(
    //   position: LatLng(request., request.lng),
    //   label: request.name,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    // );

    // setState(() {
    //   _riderMarkers[request.rideRequestId.toString()] = newMarker;
    // });
  }

  void findDrivers() async {
    Navigator.pushNamed(context, AppRoutes.mapofferFare)
        .then((offeredFare) async {
      setState(() => _dummyMarkers.clear());

      if (offeredFare == null) return;
      if (offeredFare is Map<String, bool>) {
        final isFindDriversActive = offeredFare['isFindDriversActive'] ?? false;

        if (isFindDriversActive) {
          setState(() {
            _isFindingDrivers = true;
          });
        }
      }
    });
  }

  void addMarkerToRiderMarkers(String id, Marker marker) {
    setState(() {
      _riderMarkers[id] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _checkAndFetchLocation();
    _getAddressFromLatLng(_center);
    animationInitialization();
    context.read<StompSocketCubit>().connectSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _stompSocketCubit = context.read<StompSocketCubit>();
  }

  @override
  void dispose() {
    super.dispose();
    // _stompSocketCubit.disconnect();
    _circleAnimationController.dispose();
    sourceController.dispose();
    destinationController.dispose();
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
                ? BlocListener<StompSocketCubit, StompSocketState>(
                    listener: (context, socketState) {
                    if (socketState is RideCompletionReceive) {
                      resetMap();
                    }
                  }, child: BlocBuilder<AddressCubit, AddressState>(
                    builder: (context, addressState) {
                      return Stack(
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: MapScreen._kDefaultLocation,
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
                              ..._riderMarkers.values,
                            },
                            circles: _animatedCircle,
                            onMapCreated: (controller) {
                              _controller.complete(controller);
                              controller.setMapStyle(_mapStyleString);
                            },
                            onCameraMove: _onCameraMove,
                            polylines: _polylines,
                          ),
                          if (_isDestinationSettingOn ||
                              _isSourceSettingOn) ...[
                            // centered pin
                            if (!_isFindingDrivers) ...[
                              Center(
                                child: ActiveLocationPin(),
                              ),

                              // pin setting done button on map
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: CustomButton(
                                      isRounded: true,
                                      onPressed: () async {
                                        _getAddressFromLatLng(_center);

                                        final latLng =
                                            await getPinPointedCoordinates();
                                        if (latLng == null) return;
                                        final address =
                                            await _getAddressFromLatLng(latLng);

                                        final addressCubit =
                                            context.read<AddressCubit>();

                                        if (_isDestinationSettingOn &&
                                            context.mounted) {
                                          // Clear old destination marker
                                          setState(() {
                                            _destinationLocationMarker = null;
                                          });

                                          final destination = RideLocation(
                                            lat: latLng.latitude,
                                            lng: latLng.longitude,
                                            name: address,
                                          );

                                          addressCubit
                                              .setDestination(destination);

                                          // create marker
                                          final newDestMarker = createMarker(
                                              position: latLng,
                                              label: 'Destination Location',
                                              icon: BitmapDescriptor
                                                  .defaultMarkerWithHue(
                                                      BitmapDescriptor.hueRed));

                                          setState(() {
                                            _destinationLocationMarker =
                                                newDestMarker;
                                            _isDestinationSettingOn = false;
                                            destinationController.text =
                                                address ?? '';
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

                                          await locator
                                              .get<AddressCubit>()
                                              .sendCurrentLocationToServer();

                                          final newSourceMarker = createMarker(
                                            position: latLng,
                                            label: 'Source Location',
                                            icon: BitmapDescriptor
                                                .defaultMarkerWithHue(
                                                    BitmapDescriptor.hueGreen),
                                          );

                                          setState(() {
                                            _currentLocationMarker =
                                                newSourceMarker;
                                            _isSourceSettingOn = false;
                                            sourceController.text =
                                                address ?? '';
                                          });
                                        }
                                        // Get the latest state from the Cubit after updates
                                        final source = addressCubit.source;
                                        final destination =
                                            addressCubit.destination;

                                        if (context.mounted &&
                                            source != null &&
                                            destination != null) {
                                          Navigator.pushNamed(context,
                                                  AppRoutes.mapofferFare)
                                              .then((offeredFare) async {
                                            setState(
                                                () => _dummyMarkers.clear());

                                            if (offeredFare == null) return;
                                            if (offeredFare
                                                is Map<String, bool>) {
                                              final isFindDriversActive =
                                                  offeredFare[
                                                          'isFindDriversActive'] ??
                                                      false;

                                              if (isFindDriversActive) {
                                                setState(() {
                                                  _isFindingDrivers = true;
                                                });
                                              }

                                              // await _generateDummyMarkers(
                                              //   LatLng(source.lat, source.lng),
                                              // );

                                              // _getPolyline(
                                              //   LatLng(source.lat, source.lng),
                                              //   LatLng(destination.lat,
                                              //       destination!.lng),
                                              // );
                                            }
                                          });
                                        }
                                      },
                                      text: 'Done')),
                            ]
                          ] else ...[
                            if (!_isFindingDrivers) ...[
                              if (!_hasAcceptedRequest)
                                CustomBottomsheet(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.75,
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: LocationSetttingBottomsheet(
                                    sourceController: sourceController,
                                    destinationController:
                                        destinationController,
                                    onTapped: setLocationForUser,
                                    onPressed: findDrivers,
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: EdgeInsets.all(
                                      1), // Adds space around the icon
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .primaryWhite, // Background color
                                    borderRadius: BorderRadius.circular(
                                        15), // Makes it circular
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlack
                                            .withOpacity(
                                                0.1), // Optional shadow
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
                              if (addressState.source != null &&
                                  addressState.destination != null)
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
                                          isRounded: true,
                                          text: 'Find Drivers',
                                          onPressed: findDrivers,
                                          // onPressed: () {
                                          // Navigator.pushNamed(context,
                                          //         AppRoutes.mapofferFare)
                                          //     .then((offeredFare) async {
                                          //   setState(
                                          //       () => _dummyMarkers.clear());

                                          //   if (offeredFare == null) return;
                                          //   if (offeredFare
                                          //       is Map<String, bool>) {
                                          //     final isFindDriversActive =
                                          //         offeredFare[
                                          //                 'isFindDriversActive'] ??
                                          //             false;

                                          //     if (isFindDriversActive) {
                                          //       setState(() {
                                          //         _isFindingDrivers = true;
                                          //       });
                                          //     }

                                          // await _generateDummyMarkers(
                                          //   LatLng(addressState.source!.lat,
                                          //       addressState.source!.lng),
                                          // );

                                          // _getPolyline(
                                          //   LatLng(state.source!.lat,
                                          //       state.source!.lng),
                                          //   LatLng(state.destination!.lat,
                                          //       state.destination!.lng),
                                          // );
                                          // }
                                          // });
                                          // },
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: double.infinity,
                                      //   child: CustomButton(
                                      //     backgroundColor: AppColors.neutralColor,
                                      //     text: 'Cancel',
                                      //     onPressed: () {
                                      //       setState(() {
                                      //         _dummyMarkers.clear();
                                      //         context.read<AddressCubit>().reset();
                                      //         // _currentLocationMarker = null;
                                      //         _destinationLocationMarker = null;
                                      //         _polylines.clear();

                                      //         polylineCoordinates.clear();
                                      //         sourceController.clear();
                                      //         destinationController.clear();
                                      //         _checkAndFetchLocation();
                                      //       });
                                      //     },
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              if (_hasAcceptedRequest) ...[
                                CustomBottomsheet(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.7,
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: DriverArrivingBottomsheet(
                                    onPressed: resetMap,
                                  ),
                                ),
                              ]
                            ]
                          ],
                          if (_isFindingDrivers) ...[
                            CustomBottomsheet(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                              child: OfferPriceBottomSheet(onPressed: () async {
                                final loginResponse =
                                    context.read<AuthCubit>().loginResponse;
                                final requestByPassenger =
                                    context.read<AddressCubit>().rideRequest;
                                if (loginResponse == null ||
                                    requestByPassenger == null) return;
                                final isRejected = await context
                                    .read<AddressCubit>()
                                    .rejectRideRequest(
                                        requestByPassenger.rideRequestId
                                            .toString(),
                                        loginResponse.token);

                                if (!isRejected) {
                                  CustomToast.show(
                                    'Request could not be cancelled',
                                    context: context,
                                    toastType: ToastType.error,
                                  );
                                  return;
                                }
                                resetMap();
                              }),
                            ),
                            RequestCardPopup(
                              prepareDriverArriving: prepareDriverArriving,
                              createMarkers: addMarkerToRiderMarkers,
                              drawPolyline: _getPolyline,
                            ),
                          ]
                        ],
                      );
                    },
                  ))
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
                          },
                          child: Text("Enable Location"),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _checkAndFetchLocation(),
                          child: Text(
                              "Try Again to reload the map once you enable location"),
                        )
                      ],
                    ),
                  ),
        drawer: CustomDrawer(),
      ),
    );
  }
}
