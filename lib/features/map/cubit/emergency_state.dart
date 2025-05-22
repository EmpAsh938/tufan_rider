import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/map/models/emergency_contact_model.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object?> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyLoading extends EmergencyState {}

class EmergencySuccess extends EmergencyState {
  final List<EmergencyContact> emergencies;

  const EmergencySuccess(this.emergencies);

  @override
  List<Object?> get props => [emergencies];
}

class EmergencyFailure extends EmergencyState {
  final String message;

  const EmergencyFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EmergencyContactCreated extends EmergencyState {
  final EmergencyContact newContact;

  const EmergencyContactCreated(this.newContact);

  @override
  List<Object?> get props => [newContact];
}

class EmergencyContactDeleted extends EmergencyState {
  // final EmergencyContact deletedContactId;

  const EmergencyContactDeleted();

  @override
  List<Object?> get props => [];
}
