class FareResponse {
  final double totalKm;
  final double generatedPrice;
  final String state;
  final double time;

  FareResponse({
    required this.totalKm,
    required this.generatedPrice,
    required this.state,
    required this.time,
  });

  factory FareResponse.fromJson(Map<String, dynamic> json) {
    return FareResponse(
      totalKm: (json['totalKm'] as num).toDouble(),
      generatedPrice: (json['generatedPrice'] as num).toDouble(),
      state: json['state'] as String,
      time: (json['time'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalKm': totalKm,
      'generatedPrice': generatedPrice,
      'state': state,
      'time': time,
    };
  }
}
