class CreateVehicleModel {
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleNumber;
  final String productionYear;

  CreateVehicleModel({
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleNumber,
    required this.productionYear,
  });

  // Factory constructor to create an instance from JSON
  factory CreateVehicleModel.fromJson(Map<String, dynamic> json) {
    return CreateVehicleModel(
      vehicleType: json['vehicleType'] ?? '',
      vehicleBrand: json['vehicleBrand'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      productionYear: json['productionYear'] ?? '',
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'vehicleBrand': vehicleBrand,
      'vehicleNumber': vehicleNumber,
      'productionYear': productionYear,
    };
  }
}
