import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tufan_rider/core/network/dio_exceptions.dart';
import 'package:tufan_rider/features/auth/models/registration_request.dart';
import 'package:tufan_rider/features/map/models/location_model.dart';
import 'package:tufan_rider/features/rider/map/models/create_rider_model.dart';
import 'package:tufan_rider/features/rider/map/models/create_vehicle_model.dart';
import 'dio_client.dart';
import 'api_endpoints.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'username': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> requestOTP(String mobileNo) async {
    try {
      final response = await _dio.post(ApiEndpoints.requestOTP(mobileNo));
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> verifyOTP(String mobileNo, String otp) async {
    try {
      final response = await _dio.post(ApiEndpoints.verifyOTP, data: {
        'emailOrMobile': mobileNo,
        'otp': otp,
      });
      print(response.data);
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> forgotPassword(String mobileNo) async {
    try {
      final response = await _dio.post(ApiEndpoints.forgotPassword, data: {
        'emailOrMobile': mobileNo,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updatePassword(
      String mobileNo, String otp, String newPassword) async {
    try {
      final response = await _dio.post(ApiEndpoints.updatePassword, data: {
        'emailOrMobile': mobileNo,
        'otp': otp,
        'newPassword': newPassword,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updateProfile(String userId, String token, String name,
      String email, String phone, String password) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateProfile(userId),
        data: {
          'name': name,
          'email': email,
          'mobileNo': phone,
          'password': password,
        },
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.updateProfile(userId));
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> changeMode(String userId, String token) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.modeChanger(userId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> uploadProfile(
      File profileImage, String userId, String token) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(profileImage.path,
            filename: profileImage.uri.pathSegments.last),
      });

      // Send the POST request with userId in the URL and the form data
      final response = await _dio.post(
        '${ApiEndpoints.uploadProfile}/$userId', // Append userId in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> completeRegistration(
      RegistrationRequest registrationRequest) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: registrationRequest,
      );
      print(response);
      return response;
    } on DioException catch (e) {
      print(registrationRequest.toJson());
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updateCurrentLocation(
      LocationModel location, String userId, String token) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.currentLocation(userId),
        data: {
          'currentLocation': location.toJson(),
        },
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getFare(LocationModel location, String userId,
      String categoryId, String token) async {
    try {
      final response = await _dio.post(ApiEndpoints.getFare(userId, categoryId),
          options: Options(
            headers: {
              'Authorization': 'Sandip $token',
            },
          ),
          data: {
            'd_latitude': location.latitude,
            'd_longitude': location.longitude,
          });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> createRideRequest(
      LocationModel location,
      String price,
      String userId,
      String categoryId,
      String destinationName,
      String token) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.createRideRequest(userId, categoryId),
              options: Options(
                headers: {
                  'Authorization': 'Sandip $token',
                },
              ),
              data: {
            'actualPrice': price,
            'd_latitude': location.latitude,
            'd_longitude': location.longitude,
            'd_Name': destinationName,
          });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updateRideRequest(LocationModel location, String price,
      String rideRequestId, String destinationName, String token) async {
    try {
      final response =
          await _dio.put(ApiEndpoints.updateRideRequest(rideRequestId),
              options: Options(
                headers: {
                  'Authorization': 'Sandip $token',
                },
              ),
              data: {
            'actualPrice': price,
            'd_latitude': location.latitude,
            'd_longitude': location.longitude,
            'd_Name': destinationName,
          });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> completeRide(String rideRequestId, String token) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.completeRide(rideRequestId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> showRiders(String rideId) async {
    try {
      final response = _dio.get(ApiEndpoints.showRiders(rideId));
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> showRideHistory() async {
    try {
      final response = _dio.get(ApiEndpoints.showRideHistory);
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  // Future<Response> approveRide(
  //     String offerId, String rideId, String token) async {
  //   try {
  //     final response = _dio.put(
  //       ApiEndpoints.approveRide(offerId, rideId),
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Sandip $token',
  //         },
  //       ),
  //     );
  //     return response;
  //   } on DioException catch (e) {
  //     throw DioExceptions.fromDioError(e);
  //   }
  // }

  Future<Response> createRider(String userId, String categoryId, String token,
      CreateRiderModel riderModel) async {
    try {
      final response = _dio.post(
        ApiEndpoints.createRider(userId, categoryId),
        data: riderModel.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> createVehicle(String userId, String categoryId, String token,
      CreateVehicleModel vehicleModel) async {
    try {
      final response = _dio.post(
        ApiEndpoints.createVehicle(userId, categoryId),
        data: vehicleModel.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getRiderByUser(String userId) async {
    try {
      final response = _dio.get(ApiEndpoints.getRiderByUser(userId));
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getAllRideRequests() async {
    try {
      final response = _dio.get(ApiEndpoints.getAllRideRequests);
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> proposePriceForRide(
    String rideRequestId,
    String userId,
    String token,
    String proposedPrice,
  ) async {
    try {
      final response = _dio.post(
        ApiEndpoints.proposePriceForRide(
          rideRequestId,
          userId,
        ),
        data: {
          'proposed_price': proposedPrice,
        },
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> approveByPassenger(
    String approveId,
    String rideRequestId,
    String token,
  ) async {
    try {
      final response = _dio.put(
        ApiEndpoints.approveByPassenger(approveId, rideRequestId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> rejectRideRequest(
    String rideRequestId,
    String token,
  ) async {
    try {
      final response = _dio.put(
        ApiEndpoints.rejectRideRequest(rideRequestId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> rejectRideApproval(
    String approveId,
    String token,
  ) async {
    try {
      final response = _dio.put(
        ApiEndpoints.rejectRideApproval(approveId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> pickupPassenger(
    String rideRequestId,
    String token,
  ) async {
    try {
      final response = _dio.put(
        ApiEndpoints.pickupPassenger(rideRequestId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> uploadRiderDocuments(
    File uploadedFile,
    String userId,
    String token,
    String fileType,
  ) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadedFile.path,
            filename: uploadedFile.uri.pathSegments.last),
        'fileType': fileType,
      });

      // Send the POST request with userId in the URL and the form data
      final response = await _dio.post(
        ApiEndpoints.uploadRiderDocuments(userId), // Append userId in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> uploadVehiclePhoto(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadedFile.path,
            filename: uploadedFile.uri.pathSegments.last),
      });

      // Send the POST request with vehicleId in the URL and the form data
      final response = await _dio.post(
        ApiEndpoints.uploadVehiclePicture(
            vehicleId), // Append vehicleId in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> uploadBillbookFront(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadedFile.path,
            filename: uploadedFile.uri.pathSegments.last),
      });

      // Send the POST request with vehicleId in the URL and the form data
      final response = await _dio.post(
        ApiEndpoints.uploadVehicleBillbookFront(
            vehicleId), // Append vehicleId in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> uploadBillbookBack(
    File uploadedFile,
    String vehicleId,
    String token,
  ) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadedFile.path,
            filename: uploadedFile.uri.pathSegments.last),
      });

      // Send the POST request with vehicleId in the URL and the form data
      final response = await _dio.post(
        ApiEndpoints.uploadVehicleBillbookBack(
            vehicleId), // Append vehicleId in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getPassengerHistory(String userId) async {
    try {
      final response = _dio.get(
        ApiEndpoints.fetchPassengerHistory(userId),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getRiderHistory(String userId) async {
    try {
      final response = _dio.get(
        ApiEndpoints.fetchRiderHistory(userId),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getAllEmergencyContacts(String token) async {
    try {
      final response = _dio.get(
        ApiEndpoints.getEmergencyContacts,
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getEmergencyContactsbyUser(
      String userId, String token) async {
    try {
      final response = _dio.get(
        ApiEndpoints.getEmergencyContactById(userId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> addEmergencyContact(
      String userId, String token, String name, String mobile) async {
    try {
      final response = _dio.post(
        ApiEndpoints.addEmergencyContact(userId),
        data: {
          'name': name,
          'mobile': mobile,
        },
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> deleteEmergencyContact(
      String emergencyId, String token) async {
    try {
      final response = _dio.delete(
        ApiEndpoints.deleteEmergencyContact(emergencyId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getTransactionHistory(
    String riderId,
    String token,
  ) async {
    try {
      final response = _dio.get(
        ApiEndpoints.getTransactionHistory(riderId),
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updateFcmToken(
      String userId, String token, String fcmToken) async {
    try {
      final response = _dio.put(
        ApiEndpoints.updateFcmToken(userId),
        data: {
          "deviceToken": fcmToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> createRating(
      String userId, String riderId, String token, int star) async {
    try {
      final response = _dio.post(
        ApiEndpoints.createRating(userId, riderId),
        data: {"star": star, "feedback": "good"},
        options: Options(
          headers: {
            'Authorization': 'Sandip $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> averageRating(String riderId) async {
    try {
      final response = _dio.get(
        ApiEndpoints.averageRating(riderId),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getRider(String riderId) async {
    try {
      final response = _dio.get(
        ApiEndpoints.getRiderById(riderId),
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }
}
