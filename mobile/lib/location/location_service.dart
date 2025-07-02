import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Mendapatkan lokasi pengguna
  Future<LatLng> getCurrentLocation() async {
    // Memeriksa status izin lokasi
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      // Jika izin diberikan, ambil lokasi
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } else {
      // Jika izin tidak diberikan, tampilkan pesan atau lakukan sesuatu
      throw PermissionDeniedException('Permission denied to access location.');
    }
  }
}
