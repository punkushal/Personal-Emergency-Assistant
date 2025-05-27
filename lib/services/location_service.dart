import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class LocationService {
  //Get current location with address
  Future<LocationResult> getCurrentLocation() async {
    try {
      //Check if location permission is granted
      final permissionStatus = await permission.Permission.location.status;

      if (permissionStatus.isDenied) {
        //Request permission
        final requestResult = await permission.Permission.location.request();
        if (requestResult.isDenied || requestResult.isPermanentlyDenied) {
          return LocationResult(errorMessage: 'Location permission denied');
        }
      }

      //Get current position
      final position = await Geolocator.getCurrentPosition();

      //Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Unknown location';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return LocationResult(position: position, addressString: address);
    } catch (e) {
      return LocationResult(errorMessage: 'Error getting location: $e');
    }
  }

  //Check if location services are enabled
  Future<bool> checkLocationServices() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get location permission status
  Future<permission.PermissionStatus> getLocationPermission() async {
    return await permission.Permission.location.status;
  }
}

class LocationResult {
  final Position? position;
  final String? addressString;
  final String? errorMessage;

  LocationResult({this.position, this.addressString, this.errorMessage});

  bool get hasError => errorMessage != null;
  bool get hasLocation => position != null;
}
