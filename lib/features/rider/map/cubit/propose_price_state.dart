import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/rider/map/models/proposed_ride_request_model.dart';

abstract class ProposePriceState extends Equatable {
  const ProposePriceState();

  @override
  List<Object> get props => [];
}

class ProposePriceInitial extends ProposePriceState {}

class ProposePriceLoading extends ProposePriceState {}

class ProposePriceSuccess extends ProposePriceState {
  final ProposedRideRequestModel proposedRideRequestModel;

  const ProposePriceSuccess(this.proposedRideRequestModel);

  @override
  List<Object> get props => [proposedRideRequestModel];
}

class ProposePriceFailure extends ProposePriceState {
  final String message;

  const ProposePriceFailure(this.message);

  @override
  List<Object> get props => [message];
}
