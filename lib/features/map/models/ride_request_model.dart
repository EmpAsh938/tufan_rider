import 'package:tufan_rider/features/auth/models/login_response.dart';

class RideRequestModel {
  final int? rideRequestId;
  final double actualPrice;
  final double dLatitude;
  final double dLongitude;
  final String dName;
  final double sLatitude;
  final double sLongitude;
  final String sName;
  final double totalKm;
  final DateTime? addedDate;
  final User user;
  final double replacePessengerPrice;
  final double generatedPrice;
  final String status;
  final int? ridebookedId;
  final int totalMin;
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
    required this.totalMin,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseAddedDate(dynamic input) {
      if (input == null) return null;

      try {
        // Case 1: it's a list like [2025, 5, 13, 14, 23, 0, 840000000]
        if (input is List && input.length >= 6) {
          return DateTime(
            input[0],
            input[1],
            input[2],
            input[3],
            input[4],
            input[5],
            input.length > 6 ? input[6] ~/ 1000000 : 0,
          );
        }

        // Case 2: it's a string
        if (input is String) {
          return DateTime.tryParse(input);
        }
      } catch (e) {
        print("❌ Failed to parse addedDate: $e");
      }

      return null;
    }

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
      addedDate: parseAddedDate(json['addedDate']),
      user: User.fromJson(json['user']),
      replacePessengerPrice: json['replacePessengerPrice'].toDouble(),
      generatedPrice: (json['generatedPrice'] ?? 0).toDouble(),
      status: json['status'],
      ridebookedId: json['ridebookedId'],
      category: Category.fromJson(json['category']),
      totalMin: json['total_min'],
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
