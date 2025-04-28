import 'package:equatable/equatable.dart';

abstract class StompSocketState extends Equatable {
  const StompSocketState();

  @override
  List<Object?> get props => [];
}

class StompSocketInitial extends StompSocketState {}

class StompSocketConnecting extends StompSocketState {}

class StompSocketConnected extends StompSocketState {}

class StompSocketMessageReceived extends StompSocketState {
  final String message;
  const StompSocketMessageReceived(this.message);
}

class StompSocketDisconnected extends StompSocketState {}

class StompSocketError extends StompSocketState {
  final String message;
  const StompSocketError(this.message);
}
