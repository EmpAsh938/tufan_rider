import 'package:equatable/equatable.dart';
import 'package:tufan_rider/core/model/ride_message_model.dart';
import 'package:tufan_rider/features/map/models/bid_model.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/map/models/rider_bargain_model.dart';
import 'package:tufan_rider/features/rider/map/models/ride_request_passenger_model.dart';

abstract class StompSocketState extends Equatable {
  const StompSocketState();

  @override
  List<Object?> get props => [];
}

class StompSocketInitial extends StompSocketState {}

class StompSocketConnecting extends StompSocketState {}

class StompSocketConnected extends StompSocketState {}

class StompSocketMessageReceived extends StompSocketState {
  final String message;
  const StompSocketMessageReceived(this.message);
}

class RiderRequestMessageReceived extends StompSocketState {
  final RideRequestPassengerModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RiderRequestMessageReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class PassengerMessageReceived extends StompSocketState {
  final List<RiderBargainModel> rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  PassengerMessageReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class PassengerPickupReceived extends StompSocketState {
  final RideRequestModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  PassengerPickupReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class RideRejectedReceived extends StompSocketState {
  final RideRequestModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RideRejectedReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class RideDeclineReceived extends StompSocketState {
  final BidModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RideDeclineReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class RideApproveReceived extends StompSocketState {
  final RideRequestModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RideApproveReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class RideCompletionReceive extends StompSocketState {
  final RideRequestModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RideCompletionReceive(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class RideMessageReceived extends StompSocketState {
  final RideMessageModel rideRequest;
  final DateTime timestamp; // or use a UUID if you prefer

  RideMessageReceived(this.rideRequest) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [rideRequest, timestamp];
}

class StompSocketDisconnected extends StompSocketState {}

class StompSocketError extends StompSocketState {
  final String message;
  const StompSocketError(this.message);
}
