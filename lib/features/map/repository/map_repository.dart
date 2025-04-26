import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';
import 'package:tufan_rider/features/map/models/location_model.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

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
    String token,
  ) async {
    final response = await _apiService.createRideRequest(
        location, price, userId, categoryId, token);
    return RideRequestModel.fromJson(response.data);
  }
}
