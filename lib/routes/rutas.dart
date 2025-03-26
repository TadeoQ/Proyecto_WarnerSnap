import 'package:get/get.dart';
import '../screens/bienvenida.dart';
import '../screens/login.dart';
import '../screens/registro.dart';
import '../screens/inicio.dart';
import '../screens/perfil.dart';
import '../screens/publicar.dart';
import '../screens/mapa.dart';

final List<GetPage> rutas = [
  GetPage(name: '/', page: () => const BienvenidaScreen()),
  GetPage(name: '/login', page: () => const LoginScreen()),
  GetPage(name: '/registro', page: () => const RegistroScreen()),
  GetPage(name: '/inicio', page: () => const InicioScreen()),
  GetPage(name: '/perfil', page: () => const PerfilScreen()),
  GetPage(name: '/publicar', page: () => const PublicarScreen()),
  GetPage(name: '/mapa', page: () => const MapaScreen()),
];
