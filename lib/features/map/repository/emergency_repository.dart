import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/map/models/emergency_contact_model.dart';

class EmergencyRepository {
  final ApiService _apiService;

  EmergencyRepository(this._apiService);

  Future<List<EmergencyContact>> getAllEmergencyContacts(String token) async {
    final response = await _apiService.getAllEmergencyContacts(token);
    final List<dynamic> data = response.data;
    return data.map((json) => EmergencyContact.fromJson(json)).toList();
  }

  Future<List<EmergencyContact>> getEmergencyContactsForUser(
      String userId, String token) async {
    final response =
        await _apiService.getEmergencyContactsbyUser(userId, token);

    final List<dynamic> data = response.data;
    return data.map((json) => EmergencyContact.fromJson(json)).toList();
  }

  Future<EmergencyContact> addEmergencyContact(
    String userId,
    String name,
    String mobile,
    String token,
  ) async {
    final response =
        await _apiService.addEmergencyContact(userId, token, name, mobile);
    return EmergencyContact.fromJson(response.data);
  }

  Future<void> deleteEmergencyContact(
    String econtactId,
    String token,
  ) async {
    final response =
        await _apiService.deleteEmergencyContact(econtactId, token);
    // return EmergencyContact.fromJson(response.data);
  }
}
