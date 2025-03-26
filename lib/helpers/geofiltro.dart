import 'package:geolocator/geolocator.dart';

class Publicacion {
  final double latitud;
  final double longitud;

  Publicacion({
    required this.latitud,
    required this.longitud,
  });
}

class GeoFiltro {
  static List<T> filtrarPorDistancia<T>(
    Position origen,
    List<T> publicaciones,
    double Function(T) getLatitud,
    double Function(T) getLongitud,
  ) {
    return publicaciones.where((p) {
      final distancia = Geolocator.distanceBetween(
        origen.latitude,
        origen.longitude,
        getLatitud(p),
        getLongitud(p),
      );
      return distancia <= 500;
    }).toList();
  }
}
