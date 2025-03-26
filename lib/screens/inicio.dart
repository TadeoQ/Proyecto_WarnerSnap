import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/database_service.dart';
import '../services/gps_service.dart';
import '../helpers/geofiltro.dart';
import '../widgets/carrusel_fotos.dart';
import '../widgets/modal_detalle.dart';
import '../models/fotografia.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<Fotografia> _lugaresCercanos = [];
  List<Fotografia> _lugaresRecomendados = [];

  @override
  void initState() {
    super.initState();
    _cargarYFiltrarPublicaciones();
  }

  Future<void> _cargarYFiltrarPublicaciones() async {
    final posicion = await GpsService.obtenerUbicacionActual();
    if (posicion == null) return;

    final todas = await DatabaseService.obtenerPublicaciones();

    final cercanos = GeoFiltro.filtrarPorDistancia<Fotografia>(
      posicion,
      todas,
      (p) => p.latitud,
      (p) => p.longitud,
    );

    final recomendados = cercanos.where((p) => p.cantidadLikes >= 1).toList();

    setState(() {
      _lugaresCercanos = cercanos;
      _lugaresRecomendados = recomendados;
    });
  }

  void _abrirDetalle(Fotografia foto) {
    showDialog(
      context: context,
      builder: (_) => ModalDetalle(
        urlImagen: foto.urlImagen,
        titulo: foto.titulo,
        descripcion: foto.descripcion,
        nombreUsuario: foto.nombreUsuario,
        publicacionId: foto.id,
        cantidadLikes: foto.cantidadLikes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) {
            _cargarYFiltrarPublicaciones();
            Get.toNamed('/mapa');
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explora', style: TextStyle(fontSize: 18, color: Colors.black54)),
                    const Text('Conoce la Ciudad', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CarruselFotos(
                              titulo: 'Popular',
                              publicaciones: _lugaresRecomendados,
                              onTap: _abrirDetalle,
                            ),
                            const SizedBox(height: 20),
                            CarruselFotos(
                              titulo: 'Cerca de ti',
                              publicaciones: _lugaresCercanos,
                              onTap: _abrirDetalle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botones en la esquina superior derecha
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.black87),
                      tooltip: 'Perfil',
                      onPressed: () => Get.toNamed('/perfil'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black87),
                      tooltip: 'Cerrar sesión',
                      onPressed: () => Get.offAllNamed('/login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'encuentrame',
              onPressed: _cargarYFiltrarPublicaciones,
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.my_location),
              label: const Text('Encuéntrame'),
            ),
            FloatingActionButton.extended(
              heroTag: 'publicar',
              onPressed: () => Get.toNamed('/publicar'),
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
