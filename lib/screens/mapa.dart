import 'package:flutter/material.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/fotografia.dart';
import '../services/gps_service.dart';
import '../services/database_service.dart';
import '../helpers/geofiltro.dart';
import '../widgets/modal_detalle.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _posicionInicial;
  List<Fotografia> _publicacionesCercanas = [];

  @override
  void initState() {
    super.initState();
    _cargarMapa();
  }

  Future<void> _cargarMapa() async {
    final posicion = await GpsService.obtenerUbicacionActual();
    if (posicion == null) return;

    final publicaciones = await DatabaseService.obtenerPublicaciones();

    final cercanas = GeoFiltro.filtrarPorDistancia<Fotografia>(
      posicion,
      publicaciones,
      (p) => p.latitud,
      (p) => p.longitud,
    );

    setState(() {
      _posicionInicial = LatLng(posicion.latitude, posicion.longitude);
      _publicacionesCercanas = cercanas;
    });
  }

  void _abrirDetalle(Fotografia publicacion) {
    showDialog(
      context: context,
      builder: (_) => ModalDetalle(
        urlImagen: publicacion.urlImagen,
        titulo: publicacion.titulo,
        descripcion: publicacion.descripcion,
        nombreUsuario: publicacion.nombreUsuario,
        publicacionId: publicacion.id,
        cantidadLikes: publicacion.cantidadLikes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: _posicionInicial == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _posicionInicial!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: _publicacionesCercanas.map((foto) {
                    return Marker(
                      point: LatLng(foto.latitud, foto.longitud),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _abrirDetalle(foto),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
