class ForgotPasswordResponse {
  final String phnum;
  final String otp;
  final int fid;
  final DateTime date;

  ForgotPasswordResponse({
    required this.phnum,
    required this.otp,
    required this.fid,
    required this.date,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      phnum: json['phnum'] ?? '',
      otp: json['otp'] ?? '',
      fid: json['fid'] ?? 0,
      date: _parseDateTimeList(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phnum': phnum,
      'otp': otp,
      'fid': fid,
      'date': [
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
        date.microsecond,
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
