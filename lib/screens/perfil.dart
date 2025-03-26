import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/usuario_controller.dart';
import '../services/database_service.dart';
import '../services/cloudinary_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(source: source);

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = imagen;
      });

      final usuarioCtrl = Get.find<UsuarioController>();
      final bytes = await imagen.readAsBytes();
      final nombreArchivo = 'perfil_${usuarioCtrl.id.value}';

      final url = await CloudinaryService.subirImagen(bytes, nombreArchivo);

      if (url != null) {
        await DatabaseService.actualizarUrlPerfil(usuarioCtrl.id.value, url);
        usuarioCtrl.actualizarFotoPerfil(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen actualizada correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen')),
        );
      }
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioCtrl = Get.find<UsuarioController>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Mi Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Obx(() {
                final tieneUrl = usuarioCtrl.urlImagenPerfil.value.isNotEmpty;
                final url = usuarioCtrl.urlImagenPerfil.value;
                final urlConBypass = '$url?timestamp=${DateTime.now().millisecondsSinceEpoch}';

                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _imagenSeleccionada != null
                          ? (kIsWeb
                              ? NetworkImage(_imagenSeleccionada!.path)
                              : FileImage(File(_imagenSeleccionada!.path)) as ImageProvider)
                          : (tieneUrl
                              ? NetworkImage(urlConBypass)
                              : const NetworkImage('https://via.placeholder.com/150')),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                      onPressed: _mostrarOpcionesImagen,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 30),
              Obx(() => Text(
                    usuarioCtrl.nombreUsuario.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
