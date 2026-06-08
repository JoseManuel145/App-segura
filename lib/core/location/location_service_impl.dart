import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isFakeGps() async {
    // Verificar que el servicio de ubicación esté activo
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return true;
    }

    // Pedir permisos si no los tenemos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return true;
      }
    }

    // Obtener posición actual y revisar la bandera isMocked
    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return pos.isMocked;
  }
}
