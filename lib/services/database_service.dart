import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fotografia.dart';

class DatabaseService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> subirImagenPerfil(XFile imagen, String usuarioId) async {
    try {
      final nombreArchivo = 'perfil_$usuarioId.jpg';
      final bytes = await imagen.readAsBytes();

      await _supabase.storage
          .from('perfiles')
          .uploadBinary(nombreArchivo, bytes, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage.from('perfiles').getPublicUrl(nombreArchivo);
      return url;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  static Future<void> actualizarUrlPerfil(String usuarioId, String url) async {
    await _supabase
        .from('usuarios')
        .update({'url_imagen_perfil': url})
        .eq('id', usuarioId);
  }

  static Future<bool> guardarPublicacion({
    required String usuarioId,
    required String urlImagen,
    required String titulo,
    required String descripcion,
    required double latitud,
    required double longitud,
  }) async {
    try {
      await _supabase.from('publicaciones').insert({
        'usuario_id': usuarioId,
        'url_imagen': urlImagen,
        'titulo': titulo,
        'descripcion': descripcion,
        'ubicacion': 'POINT($longitud $latitud)',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error al guardar publicación: $e');
      return false;
    }
  }

static Future<List<Fotografia>> obtenerPublicaciones() async {
  final res = await _supabase
      .from('publicaciones')
      .select('*, usuarios(nombre_usuario)')
      .order('fecha_creacion', ascending: false);

  return (res as List).map((p) => Fotografia.fromMap(p)).toList();
}

static Future<bool> usuarioYaDioLike(String publicacionId, String usuarioId) async {
  final res = await _supabase
      .from('likes')
      .select()
      .eq('publicacion_id', publicacionId)
      .eq('usuario_id', usuarioId);

  return res.isNotEmpty;
}

static Future<bool> darLike(String publicacionId, String usuarioId) async {
  try {
    // Insertar en tabla likes
    await _supabase.from('likes').insert({
      'publicacion_id': publicacionId,
      'usuario_id': usuarioId,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });

    // Actualizar contador
    await _supabase.rpc('incrementar_likes', params: {'pid': publicacionId});
    return true;
  } catch (e) {
    print('Error al dar like: $e');
    return false;
  }
}

static Future<bool> quitarLike(String publicacionId, String usuarioId) async {
  try {
    // Elimina el registro de la tabla likes
    await _supabase
        .from('likes')
        .delete()
        .match({
          'publicacion_id': publicacionId,
          'usuario_id': usuarioId,
        });

    // Llama a la función SQL para disminuir el contador
    await _supabase.rpc('quitar_like', params: {
      'pid': publicacionId,
    });

    return true;
  } catch (e) {
    print('Error al quitar like: $e');
    return false;
  }
}


}
