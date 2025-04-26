import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

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

  const AddressState({
    this.source,
    this.destination,
    this.fareResponse,
    this.rideRequestModel,
  });

  AddressState copyWith({
    RideLocation? source,
    RideLocation? destination,
    FareResponse? fareResponse,
    RideRequestModel? rideRequestModel,
  }) {
    return AddressState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      fareResponse: fareResponse ?? this.fareResponse,
      rideRequestModel: rideRequestModel ?? this.rideRequestModel,
    );
  }

  @override
  List<Object?> get props => [
        source,
        destination,
        fareResponse,
        rideRequestModel,
      ];
}
