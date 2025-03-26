import 'package:flutter/material.dart';
import '../models/fotografia.dart';
import 'modal_detalle.dart';

class CarruselFotos extends StatelessWidget {
  final String titulo;
  final List<Fotografia> publicaciones;
  final void Function(Fotografia) onTap;

  const CarruselFotos({
    super.key,
    required this.titulo,
    required this.publicaciones,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: publicaciones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final foto = publicaciones[index];
              return GestureDetector(
                onTap: () => onTap(foto),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    foto.urlImagen,
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
