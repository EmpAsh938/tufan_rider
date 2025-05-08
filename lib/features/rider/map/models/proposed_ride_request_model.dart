import 'package:tufan_rider/features/auth/models/login_response.dart';

class ProposedRideRequestModel {
  final String id;
  final User user;
  final String rideRequestId;
  final double proposedPrice;
  final double minToReach;
  final String status;
  final DateTime addedDate;

  ProposedRideRequestModel({
    required this.id,
    required this.user,
    required this.rideRequestId,
    required this.proposedPrice,
    required this.minToReach,
    required this.status,
    required this.addedDate,
  });

  factory ProposedRideRequestModel.fromJson(Map<String, dynamic> json) {
    return ProposedRideRequestModel(
      id: json['id'].toString(), // Convert to string if it's numeric
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      rideRequestId: json['rideRequestId'].toString(), // Convert to string
      proposedPrice: (json['proposed_price'] as num).toDouble(),
      minToReach: (json['minToReach'] as num).toDouble(),
      status: json['status'].toString(),
      addedDate: _parseDateTime(json['addedDate'] as List<dynamic>),
    );
  }

  static DateTime _parseDateTime(List<dynamic> dateParts) {
    try {
      return DateTime(
        dateParts[0] as int, // year
        dateParts[1] as int, // month
        dateParts[2] as int, // day
        dateParts[3] as int, // hour
        dateParts[4] as int, // minute
        dateParts[5] as int, // second
        (dateParts[6] as int) ~/ 1000000, // nanoseconds to milliseconds
      );
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id, // Try to convert back to int if possible
      'user': user.toJson(),
      'rideRequestId': int.tryParse(rideRequestId) ?? rideRequestId,
      'proposed_price': proposedPrice,
      'minToReach': minToReach,
      'status': status,
      'addedDate': [
        addedDate.year,
        addedDate.month,
        addedDate.day,
        addedDate.hour,
        addedDate.minute,
        addedDate.second,
        addedDate.millisecond * 1000000, // Convert back to nanoseconds
      ],
    };
  }
}
