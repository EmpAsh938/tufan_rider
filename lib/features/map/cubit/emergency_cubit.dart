import 'package:bloc/bloc.dart';
import 'package:tufan_rider/features/map/cubit/emergency_state.dart';
import 'package:tufan_rider/features/map/models/emergency_contact_model.dart';
import 'package:tufan_rider/features/map/repository/emergency_repository.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  final EmergencyRepository _emergencyRepository;

  EmergencyCubit(this._emergencyRepository) : super(EmergencyInitial());

  List<EmergencyContact> _emergencyContactLists = [];

  List<EmergencyContact> get emergencyContactLists => _emergencyContactLists;

  Future<void> getAllEmergencyContacts(String token) async {
    try {
      emit(EmergencyLoading());
      final response =
          await _emergencyRepository.getAllEmergencyContacts(token);
      emit(EmergencySuccess(response));
      _emergencyContactLists = response;
    } catch (error) {
      emit(EmergencyFailure(error.toString()));
    }
  }

  Future<void> getEmergencyContactsForUser(String userId, String token) async {
    try {
      emit(EmergencyLoading());
      final response =
          await _emergencyRepository.getEmergencyContactsForUser(userId, token);
      emit(EmergencySuccess(response));
      _emergencyContactLists = response;
    } catch (error) {
      emit(EmergencyFailure(error.toString()));
    }
  }

  Future<bool> addEmergencyContact(
      String userId, String name, String mobile, String token) async {
    try {
      final response = await _emergencyRepository.addEmergencyContact(
          userId, name, mobile, token);
      emit(EmergencyContactCreated(response));
      _emergencyContactLists.add(response);
      return true;
    } catch (error) {
      emit(EmergencyFailure(error.toString()));
      return false;
    }
  }

  Future<bool> deleteEmergencyContact(String econtactId, String token) async {
    try {
      emit(EmergencyLoading());
      final response =
          await _emergencyRepository.deleteEmergencyContact(econtactId, token);
      emit(EmergencyContactDeleted());
      _emergencyContactLists.removeWhere(
          (contact) => contact.econtactId.toString() == econtactId);
      return true;
    } catch (error) {
      emit(EmergencyFailure(error.toString()));
      return false;
    }
  }
}
