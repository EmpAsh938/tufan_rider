class UpdateVehicleModel {
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleNumber;
  final String productionYear;
  final int categoryId;

  UpdateVehicleModel({
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleNumber,
    required this.productionYear,
    required this.categoryId,
  });

  // Factory constructor to create an instance from JSON
  factory UpdateVehicleModel.fromJson(Map<String, dynamic> json) {
    return UpdateVehicleModel(
      vehicleType: json['vehicleType'] ?? '',
      vehicleBrand: json['vehicleBrand'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      productionYear: json['productionYear'] ?? '',
      categoryId: json['category']?['categoryId'] ?? 0,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'vehicleBrand': vehicleBrand,
      'vehicleNumber': vehicleNumber,
      'productionYear': productionYear,
      'category': {
        'categoryId': categoryId,
      },
    };
  }
}
