import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ventas_page.dart'; // Importa la nueva página

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que los widgets están inicializados
  await Hive.initFlutter();
  await Hive.openBox('categorias_page');
  await Hive.openBox('Productos_page');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio de Sesión',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Clase para representar un Usuario
class Usuario {
  String nombre;
  String contrasena;
  String rol;

  Usuario(this.nombre, this.contrasena, this.rol);
}

// Clase para manejar la lógica de usuarios
class UsuarioService {
  // Lista para almacenar los usuarios
  final List<Usuario> _usuarios = [
    // Usuario predeterminado
    Usuario("Carlos", "1234", "Administrador"),
  ];

  // Método para validar las credenciales
  Usuario? validarUsuario(String nombre, String contrasena) {
    return _usuarios.firstWhere(
      (usuario) => usuario.nombre == nombre && usuario.contrasena == contrasena,
    );
  }

  // Método para obtener la lista de usuarios (opcional)
  List<Usuario> get usuarios => _usuarios;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _contrasena = '';
  String _rolSeleccionado = 'Usuario';

  final List<String> _roles = ['Usuario', 'Administrador'];

  // Instancia de UsuarioService
  final UsuarioService _usuarioService = UsuarioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          Image.asset(
            'fondo_ini.jpg',
            fit: BoxFit.cover,
          ),
          // Pestaña de bienvenida
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                color: const Color.fromARGB(255, 81, 143, 172), // Color de fondo de la pestaña
                height: 250, // Altura de la pestaña
              ),
            ),
          ),
          Positioned(
            top: -5,
            left: MediaQuery.of(context).size.width / 7 - -10,
            child: Image.asset(
              'descarga.png',
              width: 350,
              height: 300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(150.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(250),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onSaved: (value) {
                      _nombre = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _contrasena = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _rolSeleccionado = newValue!;
                      });
                    },
                    items: _roles.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Validar el usuario con UsuarioService
                        Usuario? usuario = _usuarioService.validarUsuario(_nombre, _contrasena);
                        if (usuario != null && usuario.rol == _rolSeleccionado) {
                          // Navegar a la nueva pantalla (VentasPage)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VentasPage(rol: usuario.rol),
                            ),
                          );
                        } else {
                          // Mostrar mensaje de error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usuario, contraseña o rol incorrectos')),
                          );
                        }
                      }
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Clase para crear una forma personalizada en la pestaña de bienvenida
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

