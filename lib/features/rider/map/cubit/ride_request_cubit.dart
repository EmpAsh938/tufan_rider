import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/cubit/ride_request_state.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';

class RideRequestCubit extends Cubit<RideRequestState> {
  final RiderRepository _riderRepository;

  RideRequestCubit(this._riderRepository) : super(RideRequestInitial());

  List<RideRequestModel> _rideRequests = [];

  List<RideRequestModel> get rideRequests => _rideRequests;

  Future<void> fetchRideRequests() async {
    emit(RideRequestLoading());
    try {
      final requests = await _riderRepository.getAllRideRequests();
      _rideRequests = requests;
      emit(RideRequestSuccess(requests));
    } catch (e) {
      emit(RideRequestFailure(e.toString()));
    }
  }
}
