import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'menu_page.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  _CategoriasPageState createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final TextEditingController _categoriaController = TextEditingController();
  late Box _categoriasBox; // Caja de Hive para categorías

  @override
  void initState() {
    super.initState();
    // Abrir la caja de categorías
    _categoriasBox = Hive.box('categorias_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Categorías'),
      ),
      drawer: const MenuPage(rol: 'Administrador'), // Menú deslizante
      body: Column(
        children: [
          // Pestaña superior azul con curva hacia abajo
          ClipPath(
            clipper: UpperCurveClipper(),
            child: Container(
              color: Colors.blue, // Color azul
              height: 100, // Altura de la pestaña superior
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _categoriaController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Categoría',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_categoriaController.text.isNotEmpty) {
                        _categoriasBox.add(_categoriaController.text);
                        _categoriaController.clear();
                        setState(() {}); // Actualiza la vista
                      }
                    },
                    child: const Text('Agregar Categoría'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _categoriasBox.listenable(),
                      builder: (context, Box box, _) {
                        if (box.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay categorías disponibles',
                              style: TextStyle(color: Colors.black), // Texto negro
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: box.length,
                            itemBuilder: (context, index) {
                              final categoria = box.getAt(index);
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300], // Color de fondo gris
                                  borderRadius: BorderRadius.circular(20), // Bordes redondeados
                                ),
                                padding: const EdgeInsets.all(16.0), // Espaciado interno
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        categoria,
                                        style: const TextStyle(
                                          color: Colors.black, // Color del texto
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        box.deleteAt(index); // Eliminar categoría
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pestaña inferior azul con curva hacia arriba
          ClipPath(
            clipper: LowerCurveClipper(),
            child: Container(
              color: Colors.blue, // Color azul
              height: 100, // Altura de la pestaña inferior
            ),
          ),
        ],
      ),
    );
  }
}

// Clase personalizada para la curva hacia abajo
class UpperCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30); // Baja la curva
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30); // Curva
    path.lineTo(size.width, 0); // Cierra la forma
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

// Clase personalizada para la curva hacia arriba
class LowerCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 30); // Sube la curva
    path.quadraticBezierTo(size.width / 2, 0, size.width, 30); // Curva
    path.lineTo(size.width, size.height); // Cierra la forma
    path.lineTo(0, size.height); // Cierra la forma
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
