import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'menu_page.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  String? _categoriaSeleccionada;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(); // Controlador para la cantidad
  late Box _productosBox; // Caja de Hive para productos
  late Box _categoriasBox; // Caja de Hive para categorías
  int? _productoEditIndex; // Índice del producto a editar (si aplica)

  @override
  void initState() {
    super.initState();
    // Abrir las cajas de Hive
    _productosBox = Hive.box('Productos_page');
    _categoriasBox = Hive.box('categorias_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Productos'),
      ),
      drawer: const MenuPage(rol: 'Administrador'), // Menú deslizante
      body: Stack(
        children: [
          Column(
            children: [
              // Pestaña superior con curvas de color morado
              ClipPath(
                clipper: CurvedTopClipper(),
                child: Container(
                  color: Colors.purple,
                  height: 80,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _categoriasBox.listenable(),
                        builder: (context, Box box, _) {
                          if (box.isEmpty) {
                            return const Center(
                              child: Text('No hay categorías disponibles, agrega una en la sección de Categorías.'),
                            );
                          } else {
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Seleccionar Categoría',
                                border: OutlineInputBorder(),
                              ),
                              value: _categoriaSeleccionada,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _categoriaSeleccionada = newValue;
                                });
                              },
                              items: box.values.map<DropdownMenuItem<String>>((categoria) {
                                return DropdownMenuItem<String>(
                                  value: categoria,
                                  child: Text(categoria),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Producto',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _cantidadController, // Campo para la cantidad
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_categoriaSeleccionada != null &&
                              _nombreController.text.isNotEmpty &&
                              _precioController.text.isNotEmpty &&
                              _cantidadController.text.isNotEmpty) {
                            double? precio;
                            int? cantidad;

                            // Manejo de errores al convertir el precio
                            try {
                              precio = double.parse(_precioController.text);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Precio inválido')),
                              );
                              return;
                            }

                            // Manejo de errores al convertir la cantidad
                            try {
                              cantidad = int.parse(_cantidadController.text);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Cantidad inválida')),
                              );
                              return;
                            }

                            final producto = {
                              'categoria': _categoriaSeleccionada,
                              'nombre': _nombreController.text,
                              'precio': precio,
                              'cantidad': cantidad,
                            };

                            if (_productoEditIndex == null) {
                              // Agregar producto
                              _productosBox.add(producto);
                            } else {
                              // Editar producto
                              _productosBox.putAt(_productoEditIndex!, producto);
                              _productoEditIndex = null;
                            }

                            setState(() {
                              _nombreController.clear();
                              _precioController.clear();
                              _cantidadController.clear();
                            });
                          }
                        },
                        child: Text(_productoEditIndex == null ? 'Agregar Producto' : 'Guardar Cambios'),
                      ),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _productosBox.listenable(),
                          builder: (context, Box box, _) {
                            if (box.isEmpty) {
                              return const Center(
                                child: Text('No hay productos disponibles'),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: box.length,
                                itemBuilder: (context, index) {
                                  final producto = box.getAt(index);
                                  return ListTile(
                                    title: Text('${producto['nombre']} - \$${producto['precio']}'),
                                    subtitle: Text('Categoría: ${producto['categoria']} - Cantidad: ${producto['cantidad']}'), // Muestra la cantidad
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            setState(() {
                                              _categoriaSeleccionada = producto['categoria'];
                                              _nombreController.text = producto['nombre'];
                                              _precioController.text = producto['precio'].toString();
                                              _cantidadController.text = producto['cantidad'].toString(); // Cargar cantidad para editar
                                              _productoEditIndex = index;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              box.deleteAt(index); // Eliminar producto
                                            });
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
              // Pestaña inferior con curvas de color morado
              ClipPath(
                clipper: CurvedBottomClipper(),
                child: Container(
                  color: Colors.purple,
                  height: 80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Clipper personalizado para la pestaña superior con curvas hacia abajo
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    var firstControlPoint = Offset(size.width / 2, size.height - 50);
    var firstEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Clipper personalizado para la pestaña inferior con curvas hacia arriba
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0.0, 0.0);
    var firstControlPoint = Offset(size.width / 2, 50);
    var firstEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
