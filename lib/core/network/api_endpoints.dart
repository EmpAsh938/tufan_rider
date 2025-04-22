class ApiEndpoints {
  static const String baseUrl =
      'https://rideshare-production-b786.up.railway.app/api/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String requestOTP = '/auth/get-phone-number';
  static const String forgotPassword = '/auth/forgetpw';
  static const String updatePassword = '/auth/update-password';
  static const String userProfile = '/user/profile';
  static const String uploadProfile = '/users/file/upload';
  // Add more endpoints here...
}
