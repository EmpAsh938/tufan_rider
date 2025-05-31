import 'dart:math';

import 'package:geolocator/geolocator.dart';

class MapHelper {
  static Future<void> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  /// Checks if two coordinates are within 500 meters.
  bool isWithin500Meters({
    required double riderLat,
    required double riderLng,
    required double passengerLat,
    required double passengerLng,
  }) {
    const double earthRadius = 6371000; // in meters

    final double dLat = _degreesToRadians(passengerLat - riderLat);
    final double dLon = _degreesToRadians(passengerLng - riderLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(riderLat)) *
            cos(_degreesToRadians(passengerLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance <= 500;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

// Helper function to calculate distance between two points
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
