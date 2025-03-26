import 'package:get/get.dart';

class UsuarioController extends GetxController {
  var id = ''.obs;
  var nombreUsuario = ''.obs;
  var urlImagenPerfil = ''.obs;

  void iniciarSesion(String uid, String nombre, [String url = '']) {
    id.value = uid;
    nombreUsuario.value = nombre;
    urlImagenPerfil.value = url;
  }

  void actualizarFotoPerfil(String nuevaUrl) {
    urlImagenPerfil.value = nuevaUrl;
  }

  void cerrarSesion() {
    id.value = '';
    nombreUsuario.value = '';
    urlImagenPerfil.value = '';
  }

  bool get estaAutenticado => id.value.isNotEmpty;
}

