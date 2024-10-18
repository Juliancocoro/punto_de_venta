import 'package:flutter/material.dart';
import 'package:punto_de_venta/main.dart';
import 'productos_page.dart';
import 'categorias_page.dart';
import 'ventas_page.dart';
import 'carrito_page.dart'; // Importa la página de Carrito

class MenuPage extends StatelessWidget {
  final String rol;

  const MenuPage({super.key, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Ventas'),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VentasPage(rol: rol)),
              );
            },
          ),
          ListTile(
            title: const Text('Categorías'),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriasPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Productos'),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductosPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Carrito'), // Nueva opción del menú
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarritoPage(carrito: [],)), // Navegar a CarritoPage
              );
            },
          ),
          const Spacer(), // Espaciador para empujar el botón "Salir" hacia abajo
          ListTile(
            title: Container(
              decoration: BoxDecoration(
                color: Colors.red, // Color de fondo del botón Salir
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
              ),
              padding: const EdgeInsets.all(16), // Espaciado dentro del botón
              child: const Center(
                child: Text('Salir', style: TextStyle(color: Colors.white)),
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()), // Navega a LoginPage
              );
            },
          ),
        ],
      ),
    );
  }
}
