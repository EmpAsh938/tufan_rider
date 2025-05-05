import 'dart:io';

import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/rider/map/models/create_rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/create_vehicle_model.dart';
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
}
