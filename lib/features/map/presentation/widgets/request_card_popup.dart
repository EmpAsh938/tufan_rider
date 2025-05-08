import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/models/riders_request.dart';
import 'package:tufan_rider/features/map/presentation/widgets/request_card.dart';

class RequestCardPopup extends StatefulWidget {
  final VoidCallback prepareDriverArriving;
  const RequestCardPopup({super.key, required this.prepareDriverArriving});

  @override
  State<RequestCardPopup> createState() => _RequestCardPopupState();
}

class _RequestCardPopupState extends State<RequestCardPopup>
    with TickerProviderStateMixin {
  final List<RiderRequest> _requests = [];
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<Offset>> _animations = {};

  void _addRequest(RiderRequest request) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    setState(() {
      _requests.add(request);
      _controllers[request.id.toString()] = controller;
      _animations[request.id.toString()] = animation;
    });

    Future.delayed(Duration(milliseconds: 150 * _requests.length), () {
      if (mounted && _controllers[request.id.toString()] != null) {
        _controllers[request.id.toString()]!.forward();
      }
    });

    // Auto-remove after 10 seconds
    Future.delayed(const Duration(seconds: 30), () {
      // _removeRequestById(request.id);
    });
  }

  void _removeRequestById(String id) async {
    final controller = _controllers[id];
    if (controller == null) return;

    await controller.reverse();

    if (!mounted) return;

    setState(() {
      _requests.removeWhere((r) => r.id.toString() == id);
      _controllers.remove(id)?.dispose();
      _animations.remove(id);
    });
  }

  void _removeAllRequests() async {
    final controllers = Map<String, AnimationController>.from(_controllers);

    for (var id in controllers.keys) {
      final controller = controllers[id];
      if (controller != null) {
        await controller.reverse();
      }
    }

    if (!mounted) return;

    setState(() {
      _requests.clear();
      controllers.forEach((id, controller) {
        controller.dispose();
      });
      _controllers.clear();
      _animations.clear();
    });
  }

  void fetchRiders() {
    final data = context.read<AddressCubit>().riderRequest;
    for (var item in data) {
      _addRequest(item);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchRiders();
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _requests.map((request) {
          final animation = _animations[request.id.toString()]!;
          return SlideTransition(
            position: animation,
            child: RequestCard(
              request: request,
              onDecline: () async {
                // final loginResponse = context.read<AuthCubit>().loginResponse;
                // if (loginResponse == null) return;
                // final isRejected = await context
                //     .read<AddressCubit>()
                //     .rejectRideRequest(
                //         request.rideRequestId.toString(), loginResponse.token);

                // if (!isRejected) {
                //   CustomToast.show(
                //     'Ride could not be rejected',
                //     context: context,
                //     toastType: ToastType.error,
                //   );
                //   return;
                // }
                // _removeRequestById(request.id.toString());
              }, // need to cancel the accepted request
              onAccept: () async {
                // need to accept the ride and show in rider also in passenger

                final loginResponse = context.read<AuthCubit>().loginResponse;
                if (loginResponse == null) return;
                final acceptedRide = await context
                    .read<AddressCubit>()
                    .approveByPassenger(request.id.toString(),
                        request.rideRequestId.toString(), loginResponse.token);
                if (acceptedRide == null) {
                  CustomToast.show(
                    'Ride could not be accepted',
                    context: context,
                    toastType: ToastType.error,
                  );
                  return;
                }
                _removeAllRequests();
                widget.prepareDriverArriving();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
