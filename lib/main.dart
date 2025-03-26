import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/rutas.dart';
import 'controllers/usuario_controller.dart';

const supabaseUrl = 'https://kdhjapdnkxatvkrfxsii.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkaGphcGRua3hhdHZrcmZ4c2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5MjkzMjQsImV4cCI6MjA1ODUwNTMyNH0.O5bR9j3OGAAIisqNP5WFrO1BWenNZv7FaT0EdSlDz4w';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  Get.put(UsuarioController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Red Social de Viajeros',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: rutas,
    );
  }
}
