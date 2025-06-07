import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/model/ride_message_model.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/map_helper.dart';
import 'package:tufan_rider/core/utils/marker_util.dart';
import 'package:tufan_rider/core/widgets/custom_bottomsheet.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/map/models/ride_proposal_model.dart';
import 'package:tufan_rider/features/map/presentation/screens/offer_fare_screen.dart';
import 'package:tufan_rider/features/map/presentation/widgets/active_location_pin.dart';
import 'package:tufan_rider/features/map/presentation/widgets/driver_arriving_bottomsheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/location_settting_bottomsheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/offer_price_bottom_sheet.dart';
import 'package:tufan_rider/features/map/presentation/widgets/request_card_popup.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/features/rider/map/models/proposed_ride_request_model.dart';
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
  late AudioPlayer _player;

  final Completer<GoogleMapController> _controller = Completer();

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  Timer? _updateTimer;

  late String _mapStyleString;

  LatLng _center = MapScreen._kDefaultLocation.target;

  final Set<Marker> _dummyMarkers = {};
  Map<String, Marker> _riderMarkers = {}; // Keyed by rider id or rideRequestId

  List<LatLng> _riderPath = [];

  double zoomLevel = 12;
  bool _locationEnabled = false;
  bool _isDestinationSettingOn = false;
  bool _isSourceSettingOn = false;
  bool _isMapInteractionDisabled = false;
  bool _isLoading = true;
  bool _isFindingDrivers = false;
  bool _hasAcceptedRequest = false;
  bool _hasPickedup = false;
  int _categoryId = 1;
  bool _autoAcceptRiders = false;
  bool _isPlayed = false;

  String? riderId;

  ProposedRideRequestModel? price;

  LatLng? _sourceLocation;

  Marker? _currentLocationMarker;
  Marker? _destinationLocationMarker;

  BitmapDescriptor? riderMarkerIcon;

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Set<Circle> _animatedCircle = {};
  late AnimationController _circleAnimationController;
  late Animation<double> _radiusAnimation;

  void handleCategoryChange(int value) {
    setState(() {
      _categoryId = value;
    });
    // _loadCustomMarker();
  }

  void handleAutoAcceptRiders(bool value) {
    setState(() {
      _autoAcceptRiders = value;
    });
  }

  void handleRiders(String id) {
    setState(() {
      riderId = id;
    });
  }

  void handlePrice(ProposedRideRequestModel price) {
    setState(() {
      price = price;
    });
  }

  Future<void> _checkAndFetchLocation() async {
    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
          _currentLocationMarker = null;
          _isLoading = false;
        });
        return;
      }

      // 2. Check and request location permission
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

      // 3. Get the current position
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final LatLng currentLatLng =
          LatLng(position.latitude, position.longitude);

      // 4. Reverse geocode
      final address = await _getAddressFromLatLng(currentLatLng);

      // 5. Update Cubit
      locator.get<AddressCubit>().setSource(RideLocation(
            lat: position.latitude,
            lng: position.longitude,
            name: address,
          ));

      await locator.get<AddressCubit>().sendCurrentLocationToServer();

      // 6. Update state
      setState(() {
        _center = currentLatLng;
        _sourceLocation = currentLatLng;
        _locationEnabled = true;
        sourceController.text = address ?? '';
        _isLoading = false;
        _currentLocationMarker = Marker(
          zIndex: 1,
          markerId: const MarkerId('current_location_person'),
          position: currentLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: "Your Location"),
        );
      });

      // 7. Animate camera
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLatLng,
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationEnabled = false;
        _currentLocationMarker = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _init() async {
    try {
      await _player.setAsset(
          'assets/audio/ride_request_notification.wav'); // Add your audio in pubspec.yaml
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void playNotification() async {
    await _player.stop();
    _init();
    _player.play();
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
    if (_hasAcceptedRequest || _isFindingDrivers) return;
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

  Future<void> _getPolyline({
    required LatLng origin,
    required LatLng destination,
    LatLng? waypoint, // optional
  }) async {
    try {
      polylineCoordinates.clear();

      final request = PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
        wayPoints: waypoint != null
            ? [
                PolylineWayPoint(
                  location:
                      "${waypoint.latitude},${waypoint.longitude}", // formatted as string
                ),
              ]
            : [],
      );

      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: ApiConstants.mapAPI,
        request: request,
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }

      _drawPolyline(origin, destination);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Polyline Error: $e")));
      }
    }
  }

  // Future<void> _generateAnimatedCircle(LatLng source) async {
  //   final radius = 0.05; // approx 3km
  //   final basePosition = source;

  //   setState(() => _isMapInteractionDisabled = true);

  //   final controller = await _controller.future;
  //   _circleAnimationController.reset();

  //   // Configure animations
  //   final radiusTween = Tween<double>(begin: 10.0, end: 10000.0);
  //   final zoomTween = Tween<double>(begin: 18.0, end: 14.0);

  //   // Use the same animation controller for both animations
  //   final radiusAnimation = radiusTween.animate(
  //     CurvedAnimation(
  //       parent: _circleAnimationController,
  //       curve: Curves.easeInOutCubic, // Smoother curve
  //     ),
  //   );

  //   // Add a small delay to prevent initial stutter
  //   await Future.delayed(const Duration(milliseconds: 100));

  //   // Animation listener
  //   radiusAnimation.addListener(() {
  //     final currentProgress = _circleAnimationController.value;
  //     final currentZoom = zoomTween.transform(currentProgress);

  //     setState(() {
  //       _animatedCircle = {
  //         Circle(
  //           circleId: const CircleId('animatedCircle'),
  //           center: _center,
  //           radius: radiusAnimation.value,
  //           fillColor: Colors.blue.withOpacity(0.2),
  //           strokeColor: Colors.blue,
  //           strokeWidth: 2,
  //         ),
  //       };
  //     });

  //     // Use newLatLngZoom for smoother camera transitions
  //     controller.moveCamera(
  //       CameraUpdate.newLatLngZoom(
  //         basePosition,
  //         currentZoom,
  //       ),
  //     );
  //   });

  //   // Start the animation
  //   Future.microtask(() async {
  //     await _circleAnimationController.forward();
  //   });
  //   // Add markers with staggered appearance
  //   // for (int i = 0; i < 5; i++) {
  //   //   final offsetLat =
  //   //       basePosition.latitude + (random.nextDouble() - 0.5) * radius;
  //   //   final offsetLng =
  //   //       basePosition.longitude + (random.nextDouble() - 0.5) * radius;

  //   //   setState(() {
  //   //     _dummyMarkers.add(
  //   //       createMarker(
  //   //         position: LatLng(offsetLat, offsetLng),
  //   //         label: 'Vehicles Position',
  //   //         icon:
  //   //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //   //       ),
  //   //     );
  //   //   });
  //   //   await Future.delayed(const Duration(milliseconds: 100));
  //   // }
  // }

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
      _hasPickedup = false;
      _autoAcceptRiders = false;

      _dummyMarkers.clear(); // custom markers
      _riderMarkers.clear(); // all rider markers
      _destinationLocationMarker = null; // destination marker
      // _currentLocationMarker = null; // <--- ADD THIS LINE IF YOU HAVE ONE

      _polylines.clear();
      polylineCoordinates.clear();
      destinationController.clear();
      _animatedCircle.clear();
      _isMapInteractionDisabled = false;
    });

    _circleAnimationController.reset();

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

  void handlePickup(bool value) {
    setState(() {
      _hasPickedup = value;
    });
  }

  void findDrivers(String categoryId) async {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OfferFareScreen(categoryId: categoryId)))
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

  void addMarkerToRiderMarkers(String id, Marker marker) async {
    setState(() {
      _riderMarkers[id] = marker;
    });

    // 7. Animate camera
    // if (_controller.isCompleted) {
    //   final GoogleMapController controller = await _controller.future;
    //   controller.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         target: marker.position,
    //         zoom: 10,
    //       ),
    //     ),
    //   );
    // }
  }

  void _showRideCompletedDialog(BuildContext context) {
    int selectedRating = 0;
    bool isSubmitting = false;
    bool submissionSuccess = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final loginResponse = context.read<AuthCubit>().loginResponse;
        final userId = loginResponse?.user.id.toString() ?? '';
        final token = loginResponse?.token ?? '';
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!submissionSuccess) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Rate Your Ride',
                        style: AppTypography.headline.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How was your experience with the driver?',
                        style: AppTypography.labelText.copyWith(
                          color: AppColors.primaryBlack.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 32,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      selectedRating = index + 1;
                                    });
                                  },
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: isSubmitting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: selectedRating == 0
                                    ? null
                                    : () async {
                                        setState(() => isSubmitting = true);
                                        final success = await context
                                            .read<AddressCubit>()
                                            .createRating(userId, riderId ?? '',
                                                token, selectedRating);

                                        setState(() {
                                          isSubmitting = false;
                                          submissionSuccess = success;
                                        });
                                        stopUpdates();
                                        resetMap();

                                        Navigator.pop(context);

                                        // if (success) {
                                        //   await Future.delayed(
                                        //       const Duration(seconds: 1));
                                        // }
                                      },
                                child: Text(
                                  'Submit Rating',
                                  style: AppTypography.labelText.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Thank You!',
                        style: AppTypography.headline.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your rating has been submitted successfully.',
                        style: AppTypography.labelText.copyWith(
                          color: AppColors.primaryBlack.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Done',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void startUpdates() async {
    if (_updateTimer != null) return; // already sending

    // await MapHelper.ensureLocationPermission();

    _updateTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final location = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentLocationMarker = Marker(
            markerId: const MarkerId('current_location_person'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: "Your Location"),
          );

          _sourceLocation = location;
        });
      } catch (e) {
        print('❌ Failed to get location or send message: $e');
      }
    });
  }

  void _loadCustomMarker() async {
    try {
      final bikeIcon = await MarkerUtil.createSimpleMarker(
        Assets.markers.bikeMarker.path,
      );

      final carIcon = await MarkerUtil.createSimpleMarker(
        Assets.markers.carMarker.path,
      );
      setState(() {
        riderMarkerIcon = _categoryId == 1 ? bikeIcon : carIcon;
      });
    } catch (e) {
      print("Failed to load icon: $e");
    }
  }

  void checkIfRiderIsNear(double riderLat, double riderLng, double passengerLat,
      double passengerLng) {
    if (_isPlayed) return;
    bool nearby = MapHelper().isWithin500Meters(
      riderLat: riderLat,
      riderLng: riderLng,
      passengerLat: passengerLat,
      passengerLng: passengerLng,
    );

    if (nearby) {
      _isPlayed = true;
      playNotification();
      print('Rider is within 500 meters.');
    } else {
      print('Rider is too far.');
    }
  }

  void stopUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _polylines.clear();
    polylineCoordinates.clear();
  }

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _loadMapStyle();
    // _getAddressFromLatLng(_center);
    animationInitialization();
    context.read<StompSocketCubit>().connectSocket();
    _checkAndFetchLocation();
    _player = AudioPlayer();
    _init();

    // startUpdates();
  }

  @override
  void dispose() {
    super.dispose();
    // _stompSocketCubit.disconnect();
    _circleAnimationController.dispose();
    sourceController.dispose();
    destinationController.dispose();
    stopUpdates();
    _player.dispose();
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
                    // if (socketState is StompSocketConnected) {
                    //   context.read<StompSocketCubit>().listenToMessage();
                    // }
                    if (socketState is RideCompletionReceive) {
                      stopUpdates();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showRideCompletedDialog(
                          context,
                        );
                      });
                      resetMap();
                    }

                    if (socketState is RideMessageReceived) {
                      final ridemessageModel = socketState.rideRequest;
                      final incomingData = ridemessageModel.type.split('-');
                      final incomingUserId = incomingData[1];
                      final loginResponse =
                          context.read<AuthCubit>().loginResponse;
                      if (loginResponse == null) return;

                      // if (incomingUserId == loginResponse.user.id.toString()) {
                      final LatLng newPosition = LatLng(
                          ridemessageModel.latitude,
                          ridemessageModel.longitude);
                      final Marker newMarker = Marker(
                        markerId: MarkerId(ridemessageModel.rideRequestId
                            .toString()), // Unique key
                        position: newPosition,
                        infoWindow: InfoWindow(
                            title: ridemessageModel.rideRequestId.toString()),
                        icon: riderMarkerIcon ??
                            BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue),

                        // icon: _customIcon,
                      );

                      // Clear the old one and add the updated marker
                      addMarkerToRiderMarkers(
                          ridemessageModel.rideRequestId.toString(), newMarker);
                      final requestRide =
                          context.read<AddressCubit>().rideRequest;
                      if (requestRide == null) return;
                      final riderLocation = LatLng(ridemessageModel.latitude,
                          ridemessageModel.longitude);
                      final destinationLocation =
                          LatLng(requestRide.dLatitude, requestRide.dLongitude);
                      if (_sourceLocation == null) return;

                      if (_hasPickedup) {
                        _getPolyline(
                            origin: _sourceLocation!,
                            destination: destinationLocation,
                            waypoint: null);
                      } else if (_hasAcceptedRequest) {
                        _getPolyline(
                            origin: riderLocation,
                            destination: _sourceLocation!,
                            waypoint: null);
                      }
                      final destinationMaker = createMarker(
                          position: destinationLocation,
                          label: 'Your destination');
                      setState(() {
                        if (_hasPickedup) {
                          _riderMarkers.clear();
                        }
                        _destinationLocationMarker = destinationMaker;
                      });

                      if (_hasAcceptedRequest) {
                        checkIfRiderIsNear(
                            riderLocation.latitude,
                            riderLocation.longitude,
                            _sourceLocation!.latitude,
                            _sourceLocation!.longitude);
                      }
                      // final RideMessageModel newModal = RideMessageModel(
                      //   latitude: _center.latitude,
                      //   longitude: _center.longitude,
                      //   type:
                      //       'passenger-${loginResponse.user.id.toString()}-${ridemessageModel.rideRequestId.toString()}',
                      //   userId: loginResponse.user.id,
                      //   rideRequestId: ridemessageModel.rideRequestId,
                      // );

                      // context.read<StompSocketCubit>().sendMessage(newModal);

                      // _getPolyline(riderLocation, sourceLocation, destinationLocation)
                      // }
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
                            circles: _animatedCircle,
                            onMapCreated: (controller) {
                              _controller.complete(controller);
                              // controller.setMapStyle(_mapStyleString);
                              if (_controller.isCompleted) {
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                          _center.latitude, _center.longitude),
                                      zoom: 14,
                                    ),
                                  ),
                                );
                              }
                            },
                            markers: {
                              if (_currentLocationMarker != null)
                                _currentLocationMarker!,
                              if (_destinationLocationMarker != null)
                                _destinationLocationMarker!,
                              ..._riderMarkers.values,
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

                                              // await _generateAnimatedCircle(
                                              //   LatLng(source.lat, source.lng),
                                              // );

                                              // _getPolyline(
                                              //   LatLng(source.lat, source.lng),
                                              //   LatLng(destination.lat,
                                              //       destination!.lng),
                                              // );

                                              // final sourceLocation = LatLng(
                                              //     source.lat, source.lng);
                                              final destinationLocation =
                                                  LatLng(destination.lat,
                                                      destination.lng);
                                              if (_sourceLocation == null)
                                                return;
                                              _getPolyline(
                                                origin: _sourceLocation!,
                                                destination:
                                                    destinationLocation,
                                                waypoint: null,
                                              );
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
                                    categoryId: _categoryId,
                                    onTapped: setLocationForUser,
                                    onPressed: () =>
                                        findDrivers(_categoryId.toString()),
                                    onCategoryChanged: handleCategoryChange,
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
                                          onPressed: () async {
                                            // await _generateAnimatedCircle(
                                            //   LatLng(addressState.source!.lat,
                                            //       addressState.source!.lng),
                                            // );

                                            findDrivers(_categoryId.toString());
                                          },
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
                                    handlePrice: handlePrice,
                                    handlePickup: handlePickup,
                                    startUpdates: startUpdates,
                                    drawPolyline: _getPolyline,
                                    onPressed: resetMap,
                                    handleRiders: handleRiders,
                                  ),
                                ),
                              ]
                            ]
                          ],
                          if (_isFindingDrivers) ...[
                            CustomBottomsheet(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.6,
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                              child: OfferPriceBottomSheet(
                                  drawPolyline: _getPolyline,
                                  onPressed: (bool isMapReset) async {
                                    final loginResponse =
                                        context.read<AuthCubit>().loginResponse;
                                    final requestByPassenger = context
                                        .read<AddressCubit>()
                                        .rideRequest;
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
                                    if (isMapReset) resetMap();
                                  }),
                            ),
                            RequestCardPopup(
                              riderMarkerIcon: riderMarkerIcon,
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
