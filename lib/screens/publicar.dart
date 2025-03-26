import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';
import '../services/cloudinary_service.dart';
import '../services/database_service.dart';
import '../controllers/usuario_controller.dart';

class PublicarScreen extends StatefulWidget {
  const PublicarScreen({super.key});

  @override
  State<PublicarScreen> createState() => _PublicarScreenState();
}

class _PublicarScreenState extends State<PublicarScreen> {
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  XFile? _imagen;
  Position? _ubicacion;
  bool _yaLlamado = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_yaLlamado) {
      _yaLlamado = true;
      Future.microtask(() => _mostrarSelectorImagen());
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Nueva Publicación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Imagen
              if (_imagen != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      child: kIsWeb
                          ? Image.network(_imagen!.path, fit: BoxFit.cover)
                          : Image.file(File(_imagen!.path), fit: BoxFit.cover),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Título
              TextField(
                controller: _tituloCtrl,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Botón publicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _publicar,
                  icon: const Icon(Icons.upload),
                  label: const Text('Publicar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarSelectorImagen() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Seleccionar de galería'),
            onTap: () async {
              Navigator.pop(context);
              await _seleccionarImagen(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tomar una foto'),
            onTap: () async {
              Navigator.pop(context);
              await _seleccionarImagen(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: source);
    if (imagen != null) {
      final ubicacion = await GpsService.obtenerUbicacionActual();
      setState(() {
        _imagen = imagen;
        _ubicacion = ubicacion;
      });
    } else {
      Get.back();
    }
  }

  Future<void> _publicar() async {
    if (_imagen == null || _ubicacion == null || _tituloCtrl.text.isEmpty || _descripcionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    final usuarioCtrl = Get.find<UsuarioController>();
    final bytes = await _imagen!.readAsBytes();
    final nombreArchivo = 'publicacion_${DateTime.now().millisecondsSinceEpoch}';

    final url = await CloudinaryService.subirImagen(bytes, nombreArchivo);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir imagen.')),
      );
      return;
    }

    final exito = await DatabaseService.guardarPublicacion(
      usuarioId: usuarioCtrl.id.value,
      urlImagen: url,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      latitud: _ubicacion!.latitude,
      longitud: _ubicacion!.longitude,
    );

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación guardada correctamente')),
      );
      Get.offNamed('/inicio');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la publicación')),
      );
    }
  }
}

