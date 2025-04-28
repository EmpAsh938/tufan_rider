import 'package:tufan_rider/features/auth/models/login_response.dart';

class RideRequestModel {
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
  final double replacePessengerPrice;
  final double generatedPrice;
  final String status;
  final int? ridebookedId;
  final Category category;

  RideRequestModel({
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
    required this.replacePessengerPrice,
    required this.generatedPrice,
    required this.status,
    required this.ridebookedId,
    required this.category,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      rideRequestId: json['rideRequestId'],
      actualPrice: json['actualPrice'].toDouble(),
      dLatitude: json['d_latitude'].toDouble(),
      dLongitude: json['d_longitude'].toDouble(),
      dName: json['d_Name'],
      sLatitude: json['s_latitude'].toDouble(),
      sLongitude: json['s_longitude'].toDouble(),
      sName: json['s_Name'],
      totalKm: json['total_Km'].toDouble(),
      addedDate: DateTime(
        json['addedDate'][0],
        json['addedDate'][1],
        json['addedDate'][2],
        json['addedDate'][3],
        json['addedDate'][4],
        json['addedDate'][5],
        json['addedDate'][6] ~/ 1000000,
      ),
      user: User.fromJson(json['user']),
      replacePessengerPrice: json['replacePessengerPrice'].toDouble(),
      generatedPrice: json['generatedPrice'].toDouble(),
      status: json['status'],
      ridebookedId: json['ridebookedId'],
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  final int categoryId;
  final String categoryTitle;

  Category({
    required this.categoryId,
    required this.categoryTitle,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      categoryTitle: json['categoryTitle'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
    };
  }
}
