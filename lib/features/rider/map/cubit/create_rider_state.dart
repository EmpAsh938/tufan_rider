import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/rider/map/models/rider_response.dart';

class CreateRiderState extends Equatable {
  const CreateRiderState();

  @override
  List<Object?> get props => [];
}

class CreateRiderStateInitial extends CreateRiderState {}

class CreateRiderStateLoading extends CreateRiderState {}

class CreateRiderStateSuccess extends CreateRiderState {
  final RiderResponse riderResponse;

  const CreateRiderStateSuccess(this.riderResponse);

  @override
  List<Object?> get props => [riderResponse];
}

class CreateRiderStateFailure extends CreateRiderState {
  final String message;

  const CreateRiderStateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateRiderUploadedSuccess extends CreateRiderState {}

class CreateRiderUploadedFailure extends CreateRiderState {
  final String message;

  const CreateRiderUploadedFailure(this.message);

  @override
  List<Object?> get props => [message];
}
