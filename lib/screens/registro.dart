import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final usuarioController = TextEditingController();
  final contrasenaController = TextEditingController();

  Future<void> registrar() async {
    final exito = await AuthService.registrar(
      correoController.text.trim(),
      telefonoController.text.trim(),
      usuarioController.text.trim(),
      contrasenaController.text.trim(),
    );
    if (exito) {
      Get.offAllNamed('/inicio'); // Cambiado para consistencia con GetX
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage('assets/auditorio.png'),
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.offAllNamed('/'), // Cambiado aquí
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Crear Cuenta',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: correoController,
                              decoration: const InputDecoration(labelText: 'Correo electrónico'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: telefonoController,
                              decoration: const InputDecoration(labelText: 'Teléfono'),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: usuarioController,
                              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: contrasenaController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Contraseña'),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: registrar,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: const Text('Registrarme'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}