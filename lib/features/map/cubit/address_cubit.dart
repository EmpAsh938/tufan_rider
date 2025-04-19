import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/map/cubit/address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(const AddressState());

  void setSource(RideLocation source) {
    emit(state.copyWith(source: source));
  }

  void setDestination(RideLocation destination) {
    emit(state.copyWith(destination: destination));
  }

  AddressState fetchAddress() {
    return state;
  }

  RideLocation? fetchSource() {
    return state.source;
  }

  RideLocation? fetchDestination() {
    return state.destination;
  }

  void reset() {
    emit(state.copyWith(destination: null));
  }
}
