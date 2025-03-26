import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';

typedef ImagenUbicacion = ({XFile? imagen, Position? ubicacion});

class SelectorImagen {
  static Future<ImagenUbicacion?> mostrar(BuildContext context) async {
    final picker = ImagePicker();
    return showModalBottomSheet<ImagenUbicacion>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                final imagen = await picker.pickImage(source: ImageSource.gallery);
                final ubicacion = await GpsService.obtenerUbicacionActual();
                Navigator.pop(context, (imagen: imagen, ubicacion: ubicacion));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () async {
                final imagen = await picker.pickImage(source: ImageSource.camera);
                final ubicacion = await GpsService.obtenerUbicacionActual();
                Navigator.pop(context, (imagen: imagen, ubicacion: ubicacion));
              },
            ),
          ],
        );
      },
    );
  }
}
