import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';
import 'package:tufan_rider/features/map/models/location_model.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/map/models/riders_request.dart';
import 'package:tufan_rider/features/sidebar/models/ride_history.dart';

class MapRepository {
  final ApiService _apiService;

  MapRepository(this._apiService);

  Future<void> updateCurrentLocation(
    LocationModel location,
    String userId,
    String token,
  ) async {
    await _apiService.updateCurrentLocation(location, userId, token);
  }

  Future<FareResponse> getFare(
    LocationModel location,
    String userId,
    String categoryId,
    String token,
  ) async {
    final response =
        await _apiService.getFare(location, userId, categoryId, token);
    return FareResponse.fromJson(response.data);
  }

  Future<RideRequestModel> createRideRequest(
    LocationModel location,
    String price,
    String userId,
    String categoryId,
    String destinationName,
    String token,
  ) async {
    final response = await _apiService.createRideRequest(
        location, price, userId, categoryId, destinationName, token);
    return RideRequestModel.fromJson(response.data);
  }

  Future<RideRequestModel> updateRideRequest(
    LocationModel location,
    String price,
    String rideRequestId,
    String destinationName,
    String token,
  ) async {
    final response = await _apiService.updateRideRequest(
        location, price, rideRequestId, destinationName, token);
    return RideRequestModel.fromJson(response.data);
  }

  Future<RideRequestModel> completeRide(
    String rideRequestId,
    String token,
  ) async {
    final response = await _apiService.completeRide(rideRequestId, token);
    return RideRequestModel.fromJson(response.data);
  }

  Future<List<RideHistory>> showRideHistory() async {
    final response = await _apiService.showRideHistory();
    final List<dynamic> data = response.data;
    return data.map((json) => RideHistory.fromJson(json)).toList();
  }

  Future<List<RideHistory>> showPassengerHistory(String userId) async {
    final response = await _apiService.getPassengerHistory(userId);
    final List<dynamic> data = response.data;
    return data.map((json) => RideHistory.fromJson(json)).toList();
  }

  Future<List<RideHistory>> showRiderHistory(String userId) async {
    final response = await _apiService.getRiderHistory(userId);
    final List<dynamic> data = response.data;
    return data.map((json) => RideHistory.fromJson(json)).toList();
  }

  Future<List<RiderRequest>> showRiders(String requestId) async {
    final response = await _apiService.showRiders(requestId);
    final List<dynamic> data = response.data;
    return data.map((json) => RiderRequest.fromJson(json)).toList();
  }

  Future<RideRequestModel> approveByPassenger(
    String approveId,
    String requestId,
    String token,
  ) async {
    final response =
        await _apiService.approveByPassenger(approveId, requestId, token);
    return RideRequestModel.fromJson(response.data);
  }

  Future<void> rejectRideRequest(
    String rideRequestId,
    String token,
  ) async {
    await _apiService.rejectRideRequest(rideRequestId, token);
  }

  Future<void> rejectRideRequestApproval(
    String approveId,
    String token,
  ) async {
    await _apiService.rejectRideApproval(approveId, token);
  }

  Future<void> pickupPassenger(
    String rideRequestId,
    String token,
  ) async {
    await _apiService.pickupPassenger(rideRequestId, token);
  }

  Future<void> createRating(
    String userId,
    String riderId,
    String token,
    int star,
  ) async {
    await _apiService.createRating(userId, riderId, token, star);
  }
}
