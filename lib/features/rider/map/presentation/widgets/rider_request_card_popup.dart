import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/ride_request_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/ride_request_state.dart';
import 'package:tufan_rider/features/rider/map/presentation/widgets/rider_request_card.dart';

class RiderRequestCardPopup extends StatefulWidget {
  final void Function(RideRequestModel) prepareDriverArriving;
  const RiderRequestCardPopup({super.key, required this.prepareDriverArriving});

  @override
  State<RiderRequestCardPopup> createState() => _RiderRequestCardPopupState();
}

class _RiderRequestCardPopupState extends State<RiderRequestCardPopup>
    with TickerProviderStateMixin {
  final List<RideRequestModel> _requests = [];
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<Offset>> _animations = {};

  void _addRequest(RideRequestModel request) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    setState(() {
      _requests.add(request);
      _controllers[request.rideRequestId.toString()] = controller;
      _animations[request.rideRequestId.toString()] = animation;
    });

    Future.delayed(Duration(milliseconds: 150 * _requests.length), () {
      if (mounted && _controllers[request.rideRequestId.toString()] != null) {
        _controllers[request.rideRequestId.toString()]!.forward();
      }
    });

    // Auto-remove after 10 seconds
    Future.delayed(const Duration(seconds: 20), () {
      // _removeRequestById(request.id);
    });
  }

  void _removeRequestById(String id) async {
    final controller = _controllers[id];
    if (controller == null) return;

    await controller.reverse();

    if (!mounted) return;

    setState(() {
      _requests.removeWhere((r) => r.rideRequestId.toString() == id);
      _controllers.remove(id)?.dispose();
      _animations.remove(id);
    });
  }

  void fetchRiders() {
    // final data = context.read<AddressCubit>().riderRequest;
    // for (var item in data) {
    //   _addRequest(Request(
    //       id: item.id.toString(), vehicle: 'Toyota Prius', driver: 'John'));
    // }

    context.read<RideRequestCubit>().fetchRideRequests();
  }

  void _handleStateChanges(RideRequestState state) {
    if (state is RideRequestSuccess) {
      // Clear existing requests
      for (var request in _requests) {
        _removeRequestById(request.rideRequestId.toString());
      }

      // Add new requests with animation
      for (var request in state.rideRequest) {
        _addRequest(request);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // fetchRiders();
  }

  @override
  Widget build(BuildContext context) {
    return
        //  BlocListener<RideRequestCubit, RideRequestState>(
        //     listener: (context, state) {
        //       _handleStateChanges(state);
        //     },
        BlocListener<StompSocketCubit, StompSocketState>(
            listener: (context, state) {
              // _handleStateChanges(state);
              if (state is RiderRequestMessageReceived) {
                // final request = RideRequestModel.fromJson(state.message);
                // _addRequest(request);
                print(state.message);
              }
            },
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height:
                  MediaQuery.of(context).size.height * 0.5, // Adjust as needed
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _requests.map((request) {
                    final animation =
                        _animations[request.rideRequestId.toString()]!;

                    return SlideTransition(
                      position: animation,
                      child: RiderRequestCard(
                        request: request,
                        onDecline: () => _removeRequestById(
                            request.rideRequestId.toString()),
                        onAccept: () {
                          // _removeRequestById(request.id);
                          // final loginResponse = context.read<AuthCubit>().loginResponse;
                          // if (loginResponse == null) return;
                          // context
                          //     .read<AddressCubit>()
                          //     .approveRide('52', '43', loginResponse.token);
                          // _removeAllRequests();
                          widget.prepareDriverArriving(request);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ));
  }
}
