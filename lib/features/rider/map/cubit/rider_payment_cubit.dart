import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_state.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';

class RiderPaymentCubit extends Cubit<RiderPaymentState> {
  final RiderRepository _repository;

  RiderPaymentCubit(this._repository) : super(RiderPaymentInitial());

  Future<void> getTransactionHistory(String riderId, String token) async {
    try {
      emit(RiderPaymentFetching());
      final response = await _repository.getTransactionHistory(riderId, token);
      emit(RiderPaymentFetched(response));
    } catch (e) {
      emit(RiderPaymentError(e.toString()));
    }
  }
}
