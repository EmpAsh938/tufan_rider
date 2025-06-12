import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

class RiderResponse {
  final int id;
  final String driverLicense;
  final String nidNo;
  final String citizenNo;
  final String selfieWithIdCard;
  final String licenseImage;
  final String citizenFront;
  final String citizenBack;
  final String dateOfBirth;
  final double? balance;
  final List<int> addedDate;
  final List<int>? updatedDate;
  final String? statusMessage;
  final String status;
  final dynamic vehicle; // Can be null or Vehicle model
  final User user;
  final Category category;

  RiderResponse({
    required this.id,
    required this.driverLicense,
    required this.selfieWithIdCard,
    required this.licenseImage,
    required this.citizenFront,
    required this.citizenBack,
    required this.dateOfBirth,
    required this.nidNo,
    required this.citizenNo,
    this.balance,
    required this.addedDate,
    this.updatedDate,
    this.statusMessage,
    required this.status,
    this.vehicle,
    required this.user,
    required this.category,
  });

  factory RiderResponse.fromJson(Map<String, dynamic> json) {
    return RiderResponse(
      id: json['id'],
      driverLicense: json['driver_License'],
      selfieWithIdCard: json['selfieWithIdCard'] ?? '',
      licenseImage: json['license_Image'] ?? '',
      citizenFront: json['citizen_Front'] ?? '',
      citizenBack: json['citizen_Back'] ?? '',
      nidNo: json['nid_No'] ?? '',
      citizenNo: json['citizen_No'] ?? '',
      dateOfBirth: json['date_Of_Birth'],
      balance: json['balance']?.toDouble(),
      addedDate: List<int>.from(json['addedDate'] ?? []),
      updatedDate: json['updatedDate'] != null
          ? List<int>.from(json['updatedDate'])
          : null,
      statusMessage: json['statusMessage'],
      status: json['status'],
      vehicle: json['vehicle'], // Can be parsed to Vehicle model if not null
      user: User.fromJson(json['user']),
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_License': driverLicense,
      'selfieWithIdCard': selfieWithIdCard,
      'license_Image': licenseImage,
      'citizen_Front': citizenFront,
      'citizen_Back': citizenBack,
      'date_Of_Birth': dateOfBirth,
      'nid_No': nidNo,
      'citizen_No': citizenNo,
      'balance': balance,
      'addedDate': addedDate,
      'updatedDate': updatedDate,
      'statusMessage': statusMessage,
      'status': status,
      'vehicle': vehicle,
      'user': user.toJson(),
      'category': category.toJson(),
    };
  }
}
