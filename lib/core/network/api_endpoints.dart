class ApiEndpoints {
  static const String baseUrl =
      'https://rideshare-production-4e50.up.railway.app/api/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOTP = '/auth/verify';
  static const String forgotPassword = '/auth/forgetpw';
  static const String updatePassword = '/auth/update-password';
  static const String userProfile = '/user/profile';
  static const String uploadProfile = '/users/file/upload';

  static String requestOTP(emailOrPhone) => '/auth/send?input=$emailOrPhone';

  // map
  static String currentLocation(String userId) =>
      '/users/$userId/currentLocation';
  static String getFare(String userId, String categoryId) =>
      '/auth/ride/price?userId=$userId&categoryId=$categoryId';
  static String createRideRequest(String userId, String categoryId) =>
      '/ride-requests/user/$userId/category/$categoryId';
}
