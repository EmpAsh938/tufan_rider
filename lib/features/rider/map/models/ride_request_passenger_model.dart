import 'package:tufan_rider/features/map/models/ride_request_model.dart';

class RideRequestPassengerModel {
  final List<String> userIds;
  final RideRequestModel rideRequest;

  RideRequestPassengerModel({required this.userIds, required this.rideRequest});

  factory RideRequestPassengerModel.fromJson(Map<String, dynamic> json) {
    return RideRequestPassengerModel(
      userIds: List<String>.from(
          (json['userIds'] as List).map((id) => id.toString())),
      rideRequest: RideRequestModel.fromJson(json['rideRequest']),
    );
  }
}
