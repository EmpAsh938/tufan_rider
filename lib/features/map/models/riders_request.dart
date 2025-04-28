class RiderRequest {
  final int userId;
  final String name;
  final String mobileNo;
  final double minToReach;
  final String vehicleBrand;
  final double proposedPrice;
  final String vehicleType;
  final int rideRequestId;
  final String? vehicleNumber;
  final int id;

  RiderRequest({
    required this.userId,
    required this.name,
    required this.mobileNo,
    required this.minToReach,
    required this.vehicleBrand,
    required this.proposedPrice,
    required this.vehicleType,
    required this.rideRequestId,
    this.vehicleNumber,
    required this.id,
  });

  factory RiderRequest.fromJson(Map<String, dynamic> json) {
    return RiderRequest(
      userId: json['userId'] as int,
      name: json['name'] as String,
      mobileNo: json['mobileNo'].toString(),
      minToReach: (json['minToReach'] as num).toDouble(),
      vehicleBrand: json['vehicleBrand'] as String,
      proposedPrice: (json['proposedPrice'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      rideRequestId: json['rideRequestId'] as int,
      vehicleNumber: json['vehicleNumber'] as String?, // nullable
      id: json['id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'mobileNo': mobileNo,
      'minToReach': minToReach,
      'vehicleBrand': vehicleBrand,
      'proposedPrice': proposedPrice,
      'vehicleType': vehicleType,
      'rideRequestId': rideRequestId,
      'vehicleNumber': vehicleNumber,
      'id': id,
    };
  }
}
