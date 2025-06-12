class RegistrationRequest {
  final String name;
  final String email;
  final String mobileNo;
  final String otp;
  final String password;
  final Map<String, dynamic> deviceInfo;
  // final String branchName;
  // final String dateOfBirth;

  RegistrationRequest({
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.otp,
    required this.password,
    required this.deviceInfo,
    // required this.branchName,
    // required this.dateOfBirth,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) {
    return RegistrationRequest(
      name: json['name'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      otp: json['otp'],
      password: json['password'],
      deviceInfo: json['deviceInfo'] ?? {},
      // branchName: json['branch_Name'],
      // dateOfBirth: json['date_of_Birth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'otp': otp,
      'password': password,
      'deviceInfo': deviceInfo,
      // 'branch_Name': branchName,
      // 'date_of_Birth': dateOfBirth,
    };
  }
}
