import 'package:tufan_rider/features/auth/models/login_response.dart';

class BidModel {
  final int id;
  final User user;
  final int? rideRequestId;
  final double proposedPrice;
  final double minToReach;
  final String status;
  final String addedDate;

  BidModel({
    required this.id,
    required this.user,
    this.rideRequestId,
    required this.proposedPrice,
    required this.minToReach,
    required this.status,
    required this.addedDate,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'],
      user: User.fromJson(json['user']),
      rideRequestId: json['rideRequestId'],
      proposedPrice: json['proposed_price'].toDouble(),
      minToReach: json['minToReach'].toDouble(),
      status: json['status'],
      addedDate: json['addedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'rideRequestId': rideRequestId,
      'proposed_price': proposedPrice,
      'minToReach': minToReach,
      'status': status,
      'addedDate': addedDate,
    };
  }
}
