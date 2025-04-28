import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';

class RideHistory {
  final int rideRequestId;
  final double actualPrice;
  final double dLatitude;
  final double dLongitude;
  final String dName;
  final double sLatitude;
  final double sLongitude;
  final String sName;
  final double totalKm;
  final DateTime addedDate;
  final User user;
  final double replacePassengerPrice;
  final double generatedPrice;
  final String status;
  final int? rideBookedId;
  final Category category;

  RideHistory({
    required this.rideRequestId,
    required this.actualPrice,
    required this.dLatitude,
    required this.dLongitude,
    required this.dName,
    required this.sLatitude,
    required this.sLongitude,
    required this.sName,
    required this.totalKm,
    required this.addedDate,
    required this.user,
    required this.replacePassengerPrice,
    required this.generatedPrice,
    required this.status,
    required this.rideBookedId,
    required this.category,
  });

  factory RideHistory.fromJson(Map<String, dynamic> json) {
    return RideHistory(
      rideRequestId: json['rideRequestId'],
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      dLatitude: (json['d_latitude'] ?? 0).toDouble(),
      dLongitude: (json['d_longitude'] ?? 0).toDouble(),
      dName: json['d_Name'] ?? '',
      sLatitude: (json['s_latitude'] ?? 0).toDouble(),
      sLongitude: (json['s_longitude'] ?? 0).toDouble(),
      sName: json['s_Name'] ?? '',
      totalKm: (json['total_Km'] ?? 0).toDouble(),
      addedDate: DateTime(
        json['addedDate'][0],
        json['addedDate'][1],
        json['addedDate'][2],
        json['addedDate'][3],
        json['addedDate'][4],
        json['addedDate'][5],
      ),
      user: User.fromJson(json['user']),
      replacePassengerPrice: (json['replacePessengerPrice'] ?? 0).toDouble(),
      generatedPrice: (json['generatedPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      rideBookedId: json['ridebookedId'],
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideRequestId': rideRequestId,
      'actualPrice': actualPrice,
      'd_latitude': dLatitude,
      'd_longitude': dLongitude,
      'd_Name': dName,
      's_latitude': sLatitude,
      's_longitude': sLongitude,
      's_Name': sName,
      'total_Km': totalKm,
      'addedDate': [
        addedDate.year,
        addedDate.month,
        addedDate.day,
        addedDate.hour,
        addedDate.minute,
        addedDate.second,
      ],
      'user': user.toJson(),
      'replacePessengerPrice': replacePassengerPrice,
      'generatedPrice': generatedPrice,
      'status': status,
      'ridebookedId': rideBookedId,
      'category': category.toJson(),
    };
  }
}
