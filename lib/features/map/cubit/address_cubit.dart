import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';
import 'package:tufan_rider/features/map/models/fare_response.dart';
import 'package:tufan_rider/features/map/models/location_model.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/map/models/riders_request.dart';
import 'package:tufan_rider/features/map/repository/map_repository.dart';
import 'package:tufan_rider/features/sidebar/models/ride_history.dart';

class AddressCubit extends Cubit<AddressState> {
  final MapRepository _repository;

  AddressCubit(this._repository) : super(const AddressState());

  FareResponse? get fareResponse => state.fareResponse;
  RideLocation? get source => state.source;
  RideLocation? get destination => state.destination;
  List<RideHistory> get rideHistory => state.rideHistory;
  List<RiderRequest> get riderRequest => state.riderRequest;

  void setSource(RideLocation source) {
    emit(state.copyWith(source: source));
  }

  void setDestination(RideLocation destination) {
    emit(state.copyWith(destination: destination));
  }

  AddressState fetchAddress() {
    return state;
  }

  void setFare(FareResponse fareResponse) {
    emit(state.copyWith(fareResponse: fareResponse));
  }

  Future<void> sendCurrentLocationToServer() async {
    final source = state.source;
    final authCubit = locator.get<AuthCubit>();
    if (source == null) {
      print('No source location set');
      return;
    }

    final loginResponse = authCubit.loginResponse;

    if (loginResponse == null) {
      print('Unauthenticated');
      return;
    }
    if (loginResponse.user == null) {
      print('No user found');
      return;
    }

    final data = LocationModel(latitude: source.lat, longitude: source.lng);

    try {
      await _repository.updateCurrentLocation(
          data, loginResponse.user.id.toString(), loginResponse.token);
    } catch (e) {
      print(e);
    }
  }

  Future<FareResponse?> getFare(
    RideLocation? destinationInfo,
    LoginResponse? loginResponse,
  ) async {
    try {
      if (destinationInfo == null || loginResponse == null) {
        throw Exception();
      }
      if (destinationInfo.lat == null || destinationInfo.lng == null) {
        throw Exception();
      }
      final location = LocationModel(
        latitude: destinationInfo.lat,
        longitude: destinationInfo.lng,
      );
      final data = await _repository.getFare(
        location,
        loginResponse.user.id.toString(),
        '1',
        loginResponse.token,
      );
      return data;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<RideRequestModel?> createRideRequest(
    RideLocation destination,
    String price,
    String userId,
    String token,
  ) async {
    try {
      final location =
          LocationModel(latitude: destination.lat, longitude: destination.lng);

      final data = await _repository.createRideRequest(
          location, price, userId, '1', token);
      emit(state.copyWith(rideRequestModel: data));
      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> showRiders(String requestId) async {
    try {
      final data = await _repository.showRiders(requestId);
      emit(state.copyWith(riderRequest: data));
    } catch (e) {
      print(e);
    }
  }

  Future<void> showRideHistory() async {
    try {
      final data = await _repository.showRideHistory();
      emit(state.copyWith(rideHistory: data));
    } catch (e) {
      print(e);
    }
  }

  Future<void> approveRide(
      String offerId, String requestId, String token) async {
    try {
      await _repository.approveRide(offerId, requestId, token);
    } catch (e) {
      print(e);
    }
  }

  void reset() {
    emit(AddressState(source: state.source, destination: null));
  }
}
