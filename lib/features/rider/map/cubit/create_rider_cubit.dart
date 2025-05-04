import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_state.dart';
import 'package:tufan_rider/features/rider/map/models/create_rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/rider_response.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';

class CreateRiderCubit extends Cubit<CreateRiderState> {
  final RiderRepository _repository;
  CreateRiderCubit(this._repository) : super(CreateRiderStateInitial());

  RiderResponse? _riderResponse;

  RiderResponse? get riderResponse => _riderResponse;

  Future<void> createRider(
    String userId,
    String categoryId,
    String token,
    CreateRiderModel riderModel,
  ) async {
    emit(CreateRiderStateLoading());
    try {
      final riderData =
          await _repository.createRider(userId, categoryId, token, riderModel);
      _riderResponse = riderData;
      emit(CreateRiderStateSuccess(riderData));
    } catch (e) {
      emit(CreateRiderStateFailure(e.toString()));
    }
  }

  Future<void> uploadRiderDocuments(
    File uploadedFile,
    String userId,
    String categoryId,
    String token,
    String fileType,
  ) async {
    emit(CreateRiderStateLoading());
    try {
      await _repository.uploadRiderDocuments(
        uploadedFile,
        userId,
        token,
        fileType,
      );
      emit(CreateRiderUploadedSuccess());
    } catch (e) {
      emit(CreateRiderUploadedFailure(e.toString()));
    }
  }
}
