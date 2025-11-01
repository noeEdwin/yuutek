import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Wrapper.dart'; // Importamos el Wrapper para reiniciar el flujo

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // 1. Crear instancia de storage
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = "jwt_token"; // La misma clave que en el Wrapper

  // 2. Nueva función signout (cerrar sesión)
  Future<void> _signOut() async {
    try {
      // Borrar el token del almacenamiento
      await _storage.delete(key: _tokenKey);

      // Navegar de vuelta al Wrapper.
      // El Wrapper re-evaluará y, al no encontrar token, mostrará la pantalla de Login.
      // Usamos pushAndRemoveUntil para limpiar el historial de navegación.
      if (mounted) {
        // mounted es true si el widget está en el arbol de widgets
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Wrapper()),
          (Route<dynamic> route) =>
              false, // Esta línea elimina todas las rutas anteriores
        );
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir al borrar el storage
      debugPrint('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Principal"),
        // 3. Añadí un botón de "salir" en la barra superior (es más común)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _signOut, // Llama a nuestra nueva función
          ),
        ],
      ),
      body: const Center(
        // 4. Reemplazamos el texto del email
        child: Text(
          '¡Bienvenido! Estás autenticado.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      // 5. Quité el FloatingActionButton para no tener dos botones de logout
    );
  }
}
