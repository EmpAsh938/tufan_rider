import 'package:tufan_rider/core/constants/api_constants.dart';

class ApiEndpoints {
  static String baseUrl = '${ApiConstants.baseUrl}/api/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOTP = '/auth/verify';
  static const String forgotPassword = '/auth/forgetpw';
  static const String updatePassword = '/auth/update-password';
  static const String uploadProfile = '/users/file/upload';

  static String getImage(String imagePath) => '/users/image/$imagePath';
  static String updateProfile(String userId) => '/users/$userId';

  static String requestOTP(emailOrPhone) => '/auth/send?input=$emailOrPhone';

  // map
  static String currentLocation(String userId) =>
      '/users/$userId/currentLocation';

  // rides
  static String getFare(String userId, String categoryId) =>
      '/auth/ride/price?userId=$userId&categoryId=$categoryId';
  static String createRideRequest(String userId, String categoryId) =>
      '/ride-requests/user/$userId/category/$categoryId';

  // static String approveRide(String offerId, String rideId) =>
  //     '/ride-requests/approve/$offerId/riderequest/$rideId';
  static String showRiders(String rideId) =>
      '/riderAppReq/$rideId/pending-riders';
  static String showRideHistory = '/ride-requests/';

  static String approveByPassenger(String approveId, String rideRequestId) =>
      '/ride-requests/approve/$approveId/riderequest/$rideRequestId';
  static String rejectRideRequest(String rideRequestId) =>
      '/ride-requests/$rideRequestId/reject';

  // riders
  static String createRider(String userId, String categoryId) =>
      '/user/$userId/category/$categoryId/riders';
  static String createVehicle(String userId, String categoryId) =>
      '/vehicles/user/$userId/category/$categoryId';

  static String getRiderByUser(String userId) => '/user/$userId/riders';
  static String proposePriceForRide(String rideRequestId, String userId) =>
      '/riderAppReq/$rideRequestId/user/$userId';

  static const String getAllRideRequests = '/ride-requests/';

  // upload vehicle docs
  static String uploadVehicleBillbookFront(String vehicleId) =>
      '/vehicles/bluebook1/upload/$vehicleId';
  static String uploadVehicleBillbookBack(String vehicleId) =>
      '/vehicles/bluebook2/upload/$vehicleId';
  static String uploadVehiclePicture(String vehicleId) =>
      '/vehicles/image/upload/$vehicleId';
  // upload riders docs
  static String uploadRiderDocuments(String userId) =>
      '/rider/file/upload/$userId';
}
