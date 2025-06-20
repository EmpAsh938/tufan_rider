class RiderBargainModel {
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
  final double riderLati;
  final double riderLong;
  final String riderImage;

  RiderBargainModel({
    required this.userId,
    required this.name,
    required this.mobileNo,
    required this.minToReach,
    required this.vehicleBrand,
    required this.proposedPrice,
    required this.vehicleType,
    required this.rideRequestId,
    required this.vehicleNumber,
    required this.id,
    required this.riderLati,
    required this.riderLong,
    required this.riderImage,
  });

  factory RiderBargainModel.fromJson(Map<String, dynamic> json) {
    return RiderBargainModel(
      userId: json['userId'],
      name: json['name'],
      mobileNo: json['mobileNo'],
      minToReach: (json['minToReach'] as num).toDouble(),
      vehicleBrand: json['vehicleBrand'],
      proposedPrice: (json['proposedPrice'] as num).toDouble(),
      vehicleType: json['vehicleType'],
      rideRequestId: json['rideRequestId'],
      vehicleNumber: json['vehicleNumber'],
      id: json['id'],
      riderLati: (json['riderLati'] as num).toDouble(),
      riderLong: (json['riderLong'] as num).toDouble(),
      riderImage: json['riderImage'],
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
