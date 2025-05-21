import 'package:equatable/equatable.dart';

abstract class RiderPaymentState extends Equatable {
  const RiderPaymentState();

  @override
  List<Object> get props => [];
}

class RiderPaymentInitial extends RiderPaymentState {}

class RiderPaymentFetching extends RiderPaymentState {}

class RiderPaymentFetched extends RiderPaymentState {
  final List<Map<String, dynamic>> transactions;

  const RiderPaymentFetched(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class RiderPaymentError extends RiderPaymentState {
  final String message;

  const RiderPaymentError(this.message);

  @override
  List<Object> get props => [message];
}
