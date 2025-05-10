import 'package:tufan_rider/features/auth/models/login_response.dart';

class EmergencyContact {
  final int econtactId;
  final String name;
  final String mobile;
  final User user;

  EmergencyContact({
    required this.econtactId,
    required this.name,
    required this.mobile,
    required this.user,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      econtactId: json['econtactId'],
      name: json['name'],
      mobile: json['mobile'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'econtactId': econtactId,
      'name': name,
      'mobile': mobile,
      'user': user.toJson(),
    };
  }
}
