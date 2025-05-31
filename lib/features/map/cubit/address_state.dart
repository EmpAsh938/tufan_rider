import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/map/models/rider_bargain_model.dart';
import 'package:tufan_rider/features/map/models/riders_request.dart';
import 'package:tufan_rider/features/sidebar/models/ride_history.dart';

class RideLocation {
  final double lat;
  final double lng;
  final String? name;

  RideLocation({required this.lat, required this.lng, this.name});
}

class AddressState extends Equatable {
  final RideLocation? source;
  final RideLocation? destination;
  final FareResponse? fareResponse;
  final RideRequestModel? rideRequestModel;
  final List<RideHistory> rideHistory;
  final List<RideHistory> passengerHistory;
  final List<RideHistory> riderHistory;
  final List<RiderRequest> riderRequest;
  final RideRequestModel? acceptedRide;
  final RiderBargainModel? bargainModel;

  const AddressState({
    this.source,
    this.destination,
    this.fareResponse,
    this.rideRequestModel,
    this.acceptedRide,
    this.rideHistory = const [],
    this.passengerHistory = const [],
    this.riderHistory = const [],
    this.riderRequest = const [],
    this.bargainModel,
  });

  AddressState copyWith({
    RideLocation? source,
    RideLocation? destination,
    FareResponse? fareResponse,
    RideRequestModel? rideRequestModel,
    RideRequestModel? acceptedRide,
    RiderBargainModel? bargainModel,
    List<RideHistory>? rideHistory,
    List<RideHistory>? passengerHistory,
    List<RideHistory>? riderHistory,
    List<RiderRequest>? riderRequest,
  }) {
    return AddressState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      fareResponse: fareResponse ?? this.fareResponse,
      rideRequestModel: rideRequestModel ?? this.rideRequestModel,
      acceptedRide: acceptedRide ?? this.acceptedRide,
      rideHistory: rideHistory ?? this.rideHistory,
      passengerHistory: passengerHistory ?? this.passengerHistory,
      riderHistory: riderHistory ?? this.riderHistory,
      riderRequest: riderRequest ?? this.riderRequest,
      bargainModel: bargainModel ?? this.bargainModel,
    );
  }

  @override
  List<Object?> get props => [
        source,
        destination,
        fareResponse,
        rideRequestModel,
        acceptedRide,
        rideHistory,
        passengerHistory,
        riderHistory,
        riderRequest,
        bargainModel,
      ];
}
