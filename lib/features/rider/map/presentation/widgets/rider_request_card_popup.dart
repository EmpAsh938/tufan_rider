import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/presentation/widgets/rider_request_card.dart';

class RiderRequestCardPopup extends StatefulWidget {
  final void Function(RideRequestModel) prepareDriverArriving;
  final void Function(LatLng, LatLng) drawPolyline;
  final VoidCallback resetModals;
  final VoidCallback showApprove;
  const RiderRequestCardPopup({
    super.key,
    required this.prepareDriverArriving,
    required this.resetModals,
    required this.showApprove,
    required this.drawPolyline,
  });

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
    // Future.delayed(const Duration(seconds: 20), () {
    // _removeRequestById(request.id);
    // });
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

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StompSocketCubit, StompSocketState>(
        listener: (context, state) {
          final loginResponse = context.read<AuthCubit>().loginResponse;

          if (state is RiderRequestMessageReceived) {
            if (loginResponse == null) return;
            if (state.rideRequest.userIds
                    .contains(loginResponse.user.id.toString()) ||
                state.rideRequest.userIds.isEmpty) {
              _addRequest(state.rideRequest.rideRequest);
              context.read<StompSocketCubit>().subscribeToRideReject(
                  state.rideRequest.rideRequest.rideRequestId.toString());
              context.read<StompSocketCubit>().subscribeToRiderApprove(
                  state.rideRequest.rideRequest.rideRequestId.toString());
            }
          }

          if (state is RideRejectedReceived) {
            _removeRequestById(state.rideRequest.rideRequestId.toString());
            widget.resetModals();
          }
          if (state is RideDeclineReceived) {
            // _removeRequestById(state.rideRequest.rideRequestId.toString());
            widget.resetModals();
          }
          if (state is RideApproveReceived) {
            widget.showApprove();
            LatLng mid = LatLng(
                state.rideRequest.sLatitude, state.rideRequest.sLongitude);
            LatLng end = LatLng(
                state.rideRequest.dLatitude, state.rideRequest.dLongitude);
            widget.drawPolyline(mid, end);
          }
        },
        child: Align(
          alignment: Alignment.bottomCenter,
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
                    onDecline: () =>
                        _removeRequestById(request.rideRequestId.toString()),
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
