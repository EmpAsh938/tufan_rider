import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/rider/map/models/vehicle_response.dart';

class RiderModel {
  final int id;
  final String driverLicense;
  final String? selfieWithIdCard;
  final String dateOfBirth;
  final double? balance;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String? statusMessage;
  final String status;
  final VehicleResponseModel? vehicle;
  final User user;
  final Category category;

  RiderModel({
    required this.id,
    required this.driverLicense,
    this.selfieWithIdCard,
    required this.dateOfBirth,
    this.balance,
    required this.addedDate,
    required this.updatedDate,
    this.statusMessage,
    required this.status,
    this.vehicle,
    required this.user,
    required this.category,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as int,
      driverLicense: json['driver_License'] as String,
      selfieWithIdCard: json['selfieWithIdCard'] as String?,
      dateOfBirth: json['date_Of_Birth'] as String,
      balance: json['balance']?.toDouble(),
      addedDate: _parseDateTime(json['addedDate']),
      updatedDate: _parseDateTime(json['updatedDate']),
      statusMessage: json['statusMessage'] as String?,
      status: json['status'] as String,
      vehicle: json['vehicle'] != null
          ? VehicleResponseModel.fromJson(json['vehicle'])
          : null,
      user: User.fromJson(json['user']),
      category: Category.fromJson(json['category']),
    );
  }

  static DateTime _parseDateTime(List<dynamic> dateParts) {
    return DateTime(
      dateParts[0] as int,
      dateParts[1] as int,
      dateParts[2] as int,
      dateParts[3] as int,
      dateParts[4] as int,
      dateParts[5] as int,
      dateParts[6] ~/ 1000000, // Convert nanoseconds to milliseconds
    );
  }
}
