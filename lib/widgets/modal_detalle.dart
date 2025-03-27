import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/usuario_controller.dart';
import '../services/database_service.dart';

class ModalDetalle extends StatefulWidget {
  final String urlImagen;
  final String titulo;
  final String descripcion;
  final String nombreUsuario;
  final String publicacionId;
  final int cantidadLikes;

  const ModalDetalle({
    super.key,
    required this.urlImagen,
    required this.titulo,
    required this.descripcion,
    required this.nombreUsuario,
    required this.publicacionId,
    required this.cantidadLikes,
  });

  @override
  State<ModalDetalle> createState() => _ModalDetalleState();
}

class _ModalDetalleState extends State<ModalDetalle> {
  late int _likes;
  bool _yaDioLike = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.cantidadLikes;
    _verificarSiDioLike();
  }

  Future<void> _verificarSiDioLike() async {
    final usuarioId = Get.find<UsuarioController>().id.value;
    final yaDioLike = await DatabaseService.usuarioYaDioLike(widget.publicacionId, usuarioId);
    setState(() {
      _yaDioLike = yaDioLike;
    });
  }

  Future<void> _alternarLike() async {
    final usuarioId = Get.find<UsuarioController>().id.value;

    if (_yaDioLike) {
      final exito = await DatabaseService.quitarLike(widget.publicacionId, usuarioId);
      if (exito) {
        setState(() {
          _likes -= 1;
          _yaDioLike = false;
        });
      }
    } else {
      final exito = await DatabaseService.darLike(widget.publicacionId, usuarioId);
      if (exito) {
        setState(() {
          _likes += 1;
          _yaDioLike = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxImageHeight = screenHeight * 0.4;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onDoubleTap: _alternarLike,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxImageHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.urlImagen,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.titulo, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.descripcion,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Publicado por: ${widget.nombreUsuario}', 
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_yaDioLike ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
                    onPressed: _alternarLike,
                  ),
                  const SizedBox(width: 6),
                  Text('$_likes Me gusta'),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}