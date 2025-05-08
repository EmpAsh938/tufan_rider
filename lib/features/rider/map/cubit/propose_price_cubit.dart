import 'package:bloc/bloc.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_state.dart';
import 'package:tufan_rider/features/rider/map/models/proposed_ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';

class ProposePriceCubit extends Cubit<ProposePriceState> {
  final RiderRepository _riderRepository;

  ProposePriceCubit(this._riderRepository) : super(ProposePriceInitial());

  ProposedRideRequestModel? _proposedRideRequestModel;

  ProposedRideRequestModel? get proposedRideRequestModel =>
      _proposedRideRequestModel;

  // Add methods to handle propose price logic here
  Future<void> proposePrice(
      String rideRequestId, String userId, String token, String price) async {
    emit(ProposePriceLoading());
    try {
      final response = await _riderRepository.proposePriceForRide(
          rideRequestId, userId, token, price);
      _proposedRideRequestModel = response;
      emit(ProposePriceSuccess(response));
    } catch (e) {
      emit(ProposePriceFailure(e.toString()));
    }
  }
}
