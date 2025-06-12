import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_state.dart';
import 'package:tufan_rider/features/rider/map/models/create_vehicle_model.dart';
import 'package:tufan_rider/features/rider/map/models/update_vehicle_model.dart';
import 'package:tufan_rider/features/rider/map/models/vehicle_response.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';

class CreateVehicleCubit extends Cubit<CreateVehicleState> {
  final RiderRepository _repository;
  CreateVehicleCubit(this._repository) : super(CreateVehicleInitial());

  VehicleResponseModel? _vehicleResponseModel;

  VehicleResponseModel? get vehicleResponseModel => _vehicleResponseModel;

  Future<void> createVehicle(
    String userId,
    String categoryId,
    String token,
    CreateVehicleModel vehicleModel,
  ) async {
    emit(CreateVehicleLoading());
    try {
      final vehicleData = await _repository.createVehicle(
          userId, categoryId, token, vehicleModel);
      _vehicleResponseModel = vehicleData;
      emit(CreateVehicleSuccess(vehicleData));
    } catch (e) {
      emit(CreateVehicleFailure(e.toString()));
    }
  }

  Future<void> getVehicle(
    String userId,
    String token,
  ) async {
    try {
      final vehicleData = await _repository.getVehicle(userId);
      _vehicleResponseModel = vehicleData;
      emit(CreateVehicleSuccess(vehicleData));
    } catch (e) {
      emit(CreateVehicleFailure(e.toString()));
    }
  }

  Future<void> updateVehicle(
    String userId,
    String token,
    UpdateVehicleModel vehicleModel,
  ) async {
    emit(CreateVehicleLoading());
    try {
      final vehicleData =
          await _repository.updateVehicle(userId, token, vehicleModel);
      _vehicleResponseModel = vehicleData;
      emit(CreateVehicleSuccess(vehicleData));
    } catch (e) {
      emit(CreateVehicleFailure(e.toString()));
    }
  }

  Future<void> uploadVehicleDocuments(
    File uploadedFile,
    String vehicleId,
    String categoryId,
    String token,
  ) async {
    emit(CreateVehicleLoading());
    try {
      await _repository.uploadVehiclePhoto(
        uploadedFile,
        vehicleId,
        token,
      );
      emit(CreateVehiclePhotoUploadSuccess());
    } catch (e) {
      emit(CreateVehiclePhotoUploadFailure(e.toString()));
    }
  }

  Future<void> uploadBillbookFront(
    File uploadedFile,
    String vehicleId,
    String categoryId,
    String token,
  ) async {
    emit(CreateVehicleLoading());
    try {
      await _repository.uploadBillbookFront(
        uploadedFile,
        vehicleId,
        token,
      );
      emit(CreateVehicleBillbookFrontUploadSuccess());
    } catch (e) {
      emit(CreateVehicleBillbookFrontUploadFailure(e.toString()));
    }
  }

  Future<void> uploadBillbookBack(
    File uploadedFile,
    String vehicleId,
    String categoryId,
    String token,
  ) async {
    emit(CreateVehicleLoading());
    try {
      await _repository.uploadBillbookBack(
        uploadedFile,
        vehicleId,
        token,
      );
      emit(CreateVehicleBillbookBackUploadSuccess());
    } catch (e) {
      emit(CreateVehicleBillbookBackUploadFailure(e.toString()));
    }
  }
}
