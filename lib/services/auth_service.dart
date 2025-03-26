import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../controllers/usuario_controller.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static String _cifrarContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

static Future<bool> login(String nombreUsuario, String contrasena) async {
  try {
    final hash = _cifrarContrasena(contrasena);
    final usuario = await _supabase
        .from('usuarios')
        .select()
        .eq('nombre_usuario', nombreUsuario)
        .eq('contrasena', hash)
        .maybeSingle();

    if (usuario != null) {
      final usuarioCtrl = Get.find<UsuarioController>();
      usuarioCtrl.iniciarSesion(
        usuario['id'],
        usuario['nombre_usuario'],
        usuario['url_imagen_perfil'] ?? '',
      );
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}

  static Future<bool> registrar(String correo, String telefono, String nombreUsuario, String contrasena) async {
    try {
      final hash = _cifrarContrasena(contrasena);
      await _supabase.from('usuarios').insert({
        'correo': correo,
        'telefono': telefono,
        'nombre_usuario': nombreUsuario,
        'contrasena': hash,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'ultimo_acceso': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Registro error: $e');
      return false;
    }
  }
  
}

