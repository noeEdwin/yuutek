import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Wrapper.dart'; // Para navegar al wrapper después del login
import 'dart:convert'; // Para codificar/decodificar JSON
import 'package:http/http.dart' as http; // Para llamadas API

class Login extends StatefulWidget {
  const Login({super.key}); // Constructor corregido

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // 1. Controladores y llave para el formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 2. Instancia de storage
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = "jwt_token"; // La misma clave que en el Wrapper

  // 3. Estado de carga
  bool _isLoading = false;

  // 4. Función signIn (reemplaza a signTn y FirebaseAuth)
  Future<void> _signIn() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return; // Si no es válido, no hacer nada
    }

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // --- ¡AQUÍ VA LA LÓGICA DE API REAL! ---
      // Habla con tu amigo del backend para obtener la URL
      final url = Uri.parse('http://TU_IP_O_DOMINIO:8000/api/v1/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'contrasena': _passwordController.text, // Asegúrate que el backend espere 'contrasena'
        }),
      );

      if (response.statusCode == 200) {
        // Éxito
        final responseData = json.decode(response.body);
        final token = responseData['token']; // Asume que el token viene en una clave 'token'

        // Guardar el token de forma segura
        await _storage.write(key: _tokenKey, value: token);

        // Navegar al Wrapper.
        // El Wrapper verá el token y mostrará la Homepage.
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Wrapper()),
            (route) => false,
          );
        }
      } else {
        // Error (ej. 401 Credenciales incorrectas)
        final errorData = json.decode(response.body);
        _showError('Error: ${errorData['detail'] ?? 'Credenciales incorrectas'}');
      }
      // --- FIN DE LA LÓGICA DE API ---

    } catch (e) {
      // Error de red o al parsear JSON
      _showError('Error de conexión. Inténtalo de nuevo. $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ocultar indicador de carga
        });
      }
    }
  }

  // Helper para mostrar errores
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Limpiar controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        // 6. Usar Form y SingleChildScrollView para evitar overflow
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Asignar la llave al Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 7. Usar TextFormField para validación
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // 8. Botón con estado de carga
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signIn, // Llamar a la función _signIn
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Entrar"),
                      ),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    // TODO: Navegar a la pantalla de Registro
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistroScreen()));
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

