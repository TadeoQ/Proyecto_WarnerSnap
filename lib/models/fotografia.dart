class Fotografia {
  final String id;
  final String urlImagen;
  final String titulo;
  final String descripcion;
  final int cantidadLikes;
  final double latitud;
  final double longitud;
  final String nombreUsuario;

  Fotografia({
    required this.id,
    required this.urlImagen,
    required this.titulo,
    required this.descripcion,
    required this.cantidadLikes,
    required this.latitud,
    required this.longitud,
    required this.nombreUsuario,
  });

  factory Fotografia.fromMap(Map<String, dynamic> data) {
    final ubicacion = data['ubicacion'];
    final coordenadas = ubicacion['coordinates'];
    return Fotografia(
      id: data['id'],
      urlImagen: data['url_imagen'],
      titulo: data['titulo'],
      descripcion: data['descripcion'],
      cantidadLikes: data['cantidad_likes'] ?? 0,
      latitud: coordenadas[1],
      longitud: coordenadas[0],
      nombreUsuario: data['usuarios']['nombre_usuario'],
    );
  }
}
