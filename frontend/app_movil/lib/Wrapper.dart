import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- ¡IMPORTANTE! ---
// He actualizado los imports y nombres de widgets basándome en tus archivos.

// Importa tu pantalla de login
import 'login.dart'; 
// Importa tu pantalla principal
import 'homepage.dart'; 

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  // 1. Creamos una instancia del almacenamiento seguro
  final _storage = const FlutterSecureStorage();

  // 2. Esta es la clave donde guardarás tu token.
  //    Debe ser la MISMA clave que uses en tu pantalla de login
  //    cuando recibas el token del backend.
  final String _tokenKey = "jwt_token";

  // 3. Este es el Future que el FutureBuilder escuchará.
  //    Intenta leer el token del almacenamiento.
  Future<String?> _checkAuthStatus() async {
    // Lee el token. Devuelve el token si existe, o 'null' si no.
    return await _storage.read(key: _tokenKey);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un FutureBuilder en lugar de StreamBuilder
    return FutureBuilder<String?>(
      future: _checkAuthStatus(), // 4. Le pasamos nuestro Future
      builder: (context, snapshot) {
        
        // --- Caso 1: El Future se está ejecutando ---
        // Mientras leemos el almacenamiento, mostramos un spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // --- Caso 2: El Future terminó y SÍ tenemos un token ---
        // (snapshot.hasData && snapshot.data != null) significa que
        // _checkAuthStatus() devolvió un token y no 'null'.
        if (snapshot.hasData && snapshot.data != null) {
          // El usuario está autenticado, lo mandamos al Home
          // CORREGIDO: Ahora usa tu widget Homepage
          return const Homepage(); 
        }
        
        // --- Caso 3: El Future terminó y NO tenemos token ---
        // (snapshot.data == null) significa que no hay token guardado.
        // El usuario no está autenticado, lo mandamos al Login/Registro.
        else {
          // CORREGIDO: Ahora usa tu widget Login
          // (Asegúrate de que tu archivo 'login.dart' tenga un widget llamado 'Login')
          return const Login(); 
        }
      },
    );
  }
}

