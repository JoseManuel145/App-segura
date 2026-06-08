abstract class LocationService {
  /// Devuelve true si se detecta Fake GPS o si el servicio está deshabilitado.
  Future<bool> isFakeGps();
}
