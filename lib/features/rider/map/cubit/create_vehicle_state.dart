import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/rider/map/models/vehicle_response.dart';

class CreateVehicleState extends Equatable {
  const CreateVehicleState();

  @override
  List<Object?> get props => [];
}

class CreateVehicleInitial extends CreateVehicleState {}

class CreateVehicleLoading extends CreateVehicleState {}

class CreateVehicleSuccess extends CreateVehicleState {
  final VehicleResponseModel vehicleResponseModel;

  const CreateVehicleSuccess(this.vehicleResponseModel);

  @override
  List<Object?> get props => [vehicleResponseModel];
}

class CreateVehicleFailure extends CreateVehicleState {
  final String message;

  const CreateVehicleFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateVehiclePhotoUploadSuccess extends CreateVehicleState {}

class CreateVehiclePhotoUploadFailure extends CreateVehicleState {
  final String message;

  const CreateVehiclePhotoUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateVehicleBillbookFrontUploadSuccess extends CreateVehicleState {}

class CreateVehicleBillbookFrontUploadFailure extends CreateVehicleState {
  final String message;

  const CreateVehicleBillbookFrontUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateVehicleBillbookBackUploadSuccess extends CreateVehicleState {}

class CreateVehicleBillbookBackUploadFailure extends CreateVehicleState {
  final String message;

  const CreateVehicleBillbookBackUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
