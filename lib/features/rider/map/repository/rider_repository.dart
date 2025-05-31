import 'dart:io';

import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/models/create_rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/create_vehicle_model.dart';
import 'package:tufan_rider/features/rider/map/models/proposed_ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_response.dart';
import 'package:tufan_rider/features/rider/map/models/vehicle_response.dart';

class RiderRepository {
  final ApiService _apiService;

  RiderRepository(this._apiService);

  Future<RiderResponse> createRider(
    String userId,
    String categoryId,
    String token,
    CreateRiderModel riderModel,
  ) async {
    final response = await _apiService.createRider(
      userId,
      categoryId,
      token,
      riderModel,
    );
    return RiderResponse.fromJson(response.data);
  }

  Future<RiderResponse> getRiderbyUser(String userId) async {
    final response = await _apiService.getRiderByUser(userId);

    if (response.data is List) {
      final ridersList = response.data as List;
      if (ridersList.isEmpty) throw Exception("No riders found");
      return RiderResponse.fromJson(ridersList.first); // Parse the first item
    } else {
      // If it's not a list, assume it's a single rider
      return RiderResponse.fromJson(response.data);
    }
  }

  Future<List<RideRequestModel>> getAllRideRequests() async {
    final response = await _apiService.getAllRideRequests();

    if (response.data is List) {
      final rideRequestsList = response.data as List;
      if (rideRequestsList.isEmpty) throw Exception("No ride requests found");
      return rideRequestsList
          .map((item) => RideRequestModel.fromJson(item))
          .toList(); // Parse the list of items
    } else {
      // If it's not a list, wrap the single ride request in a list
      return [RideRequestModel.fromJson(response.data)];
    }
  }

  Future<ProposedRideRequestModel> proposePriceForRide(
    String rideRequestId,
    String userId,
    String token,
    String price,
  ) async {
    final response = await _apiService.proposePriceForRide(
      rideRequestId,
      userId,
      token,
      price,
    );

    return ProposedRideRequestModel.fromJson(response.data);
  }

  Future<VehicleResponseModel> createVehicle(
    String userId,
    String categoryId,
    String token,
    CreateVehicleModel vehicleModel,
  ) async {
    final response = await _apiService.createVehicle(
      userId,
      categoryId,
      token,
      vehicleModel,
    );

    return VehicleResponseModel.fromJson(response.data);
  }

  Future<void> uploadRiderDocuments(
    File uploadedFile,
    String userId,
    String token,
    String fileType,
  ) async {
    await _apiService.uploadRiderDocuments(
      uploadedFile,
      userId,
      token,
      fileType,
    );
  }

  Future<void> uploadVehiclePhoto(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    await _apiService.uploadVehiclePhoto(
      uploadedFile,
      vehicleId,
      token,
    );
  }

  Future<void> uploadBillbookFront(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    await _apiService.uploadBillbookFront(
      uploadedFile,
      vehicleId,
      token,
    );
  }

  Future<void> uploadBillbookBack(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    await _apiService.uploadBillbookBack(
      uploadedFile,
      vehicleId,
      token,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(
    String riderId,
    String token,
  ) async {
    final response = await _apiService.getTransactionHistory(riderId, token);
    if (response.data is List) {
      final transactionsList = response.data as List;
      return transactionsList
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception("Unexpected response format");
    }
  }

  Future<double> averageRating(String riderId) async {
    try {
      final response = await _apiService.averageRating(riderId);

      // Example: { "message": "Average Rating: 5.0", "success": true }
      final message = response.data['message'] as String;

      // Extract the number using RegExp
      final match = RegExp(r'[\d.]+').firstMatch(message);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? 0.0;
      } else {
        return 0.0;
      }
    } catch (e) {
      print('Error fetching average rating: $e');
      return 0.0;
    }
  }

  Future<RiderModel> getRiderById(String riderId) async {
    final response = await _apiService.getRider(riderId); // Dio Response

    // Make sure response.data is a map
    if (response.data is Map<String, dynamic>) {
      return RiderModel.fromJson(response.data);
    } else {
      throw Exception('Invalid response format for rider data');
    }
  }
}
