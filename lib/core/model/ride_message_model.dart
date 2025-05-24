class RideMessageModel {
  final double latitude;
  final double longitude;
  final String type;
  final int? userId;
  final int? rideRequestId;

  RideMessageModel({
    required this.latitude,
    required this.longitude,
    required this.type,
    this.userId,
    this.rideRequestId,
  });

  factory RideMessageModel.fromJson(Map<String, dynamic> json) {
    return RideMessageModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: json['type'] as String,
      userId: json['userId'] as int?,
      rideRequestId: json['rideRequestId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'userId': userId,
      'rideRequestId': rideRequestId,
    };
  }
}
