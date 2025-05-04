import 'package:tufan_rider/features/map/models/ride_request_model.dart';

class VehicleResponseModel {
  final int id;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleNumber;
  final String productionYear;
  final String vechicleImg;
  final String billBook1;
  final String billBook2;
  final Category category;

  VehicleResponseModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleNumber,
    required this.productionYear,
    required this.vechicleImg,
    required this.billBook1,
    required this.billBook2,
    required this.category,
  });

  factory VehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return VehicleResponseModel(
      id: json['id'],
      vehicleType: json['vehicleType'],
      vehicleBrand: json['vehicleBrand'],
      vehicleNumber: json['vehicleNumber'],
      productionYear: json['productionYear'],
      vechicleImg: json['vechicleImg'],
      billBook1: json['billBook1'],
      billBook2: json['billBook2'],
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'vehicleBrand': vehicleBrand,
      'vehicleNumber': vehicleNumber,
      'productionYear': productionYear,
      'vechicleImg': vechicleImg,
      'billBook1': billBook1,
      'billBook2': billBook2,
      'category': category.toJson(),
    };
  }
}
