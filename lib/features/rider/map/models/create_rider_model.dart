class CreateRiderModel {
  final String driverLicense;
  final String dateOfBirth;
  final String nidNo;
  final String citizenNo;

  CreateRiderModel({
    required this.driverLicense,
    required this.dateOfBirth,
    required this.nidNo,
    required this.citizenNo,
  });

  // Factory constructor to create an instance from JSON
  factory CreateRiderModel.fromJson(Map<String, dynamic> json) {
    return CreateRiderModel(
      driverLicense: json['driver_License'] ?? '',
      dateOfBirth: json['date_Of_Birth'] ?? '',
      nidNo: json['nid_No'] ?? '',
      citizenNo: json['citizen_No'] ?? '',
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'driver_License': driverLicense,
      'date_Of_Birth': dateOfBirth,
      'nid_No': nidNo,
      'citizen_No': citizenNo,
    };
  }
}
