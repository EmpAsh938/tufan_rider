class OtpResponse {
  final String mobileNo;
  final String otp;
  final dynamic
      user; // You can replace `dynamic` with a proper User model later
  final int id;
  final DateTime otpValidUntil;

  OtpResponse({
    required this.mobileNo,
    required this.otp,
    required this.user,
    required this.id,
    required this.otpValidUntil,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      mobileNo: json['mobileNo'] ?? '',
      otp: json['otp'] ?? '',
      user: json['user'], // You can parse this if user is not null
      id: json['id'] ?? 0,
      otpValidUntil: _parseDateTimeList(json['otpValidUntil']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobileNo': mobileNo,
      'otp': otp,
      'user': user,
      'id': id,
      'otpValidUntil': [
        otpValidUntil.year,
        otpValidUntil.month,
        otpValidUntil.day,
        otpValidUntil.hour,
        otpValidUntil.minute,
        otpValidUntil.second,
        otpValidUntil.microsecond,
      ],
    };
  }

  static DateTime _parseDateTimeList(List<dynamic> list) {
    return DateTime(
      list[0], // year
      list[1], // month
      list[2], // day
      list[3], // hour
      list[4], // minute
      list[5], // second
      list[6] ~/ 1000, // microsecond
    );
  }
}
