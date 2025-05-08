import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

abstract class RideRequestState extends Equatable {
  const RideRequestState();

  @override
  List<Object?> get props => [];
}

class RideRequestInitial extends RideRequestState {}

class RideRequestLoading extends RideRequestState {}

class RideRequestSuccess extends RideRequestState {
  final List<RideRequestModel> rideRequest;

  const RideRequestSuccess(this.rideRequest);

  @override
  List<Object?> get props => [rideRequest];
}

class RideRequestFailure extends RideRequestState {
  final String message;

  const RideRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}
