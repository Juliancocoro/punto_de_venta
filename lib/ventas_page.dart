import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'menu_page.dart';
import 'carrito_page.dart'; // Importa la página del carrito

class VentasPage extends StatefulWidget {
  final String rol;

  const VentasPage({super.key, required this.rol});

  @override
  // ignore: library_private_types_in_public_api
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  Box? _categoriasBox;
  Box? _productosBox;
  String? _categoriaSeleccionada;
  String? _productoSeleccionado;
  final List<Map<String, dynamic>> _carrito = []; // Almacena nombre, precio y cantidad

  @override
  void initState() {
    super.initState();
    _categoriasBox = Hive.box('categorias_page'); // Accede a la caja de categorías
    _productosBox = Hive.box('Productos_page');  // Accede a la caja de productos
  }

  void agregarAlCarrito() {
    if (_productoSeleccionado != null) {
      final producto = _productosBox!.values.firstWhere((p) => p['nombre'] == _productoSeleccionado);
      final existingProductIndex = _carrito.indexWhere((item) => item['nombre'] == producto['nombre']);

      if (existingProductIndex >= 0) {
        int totalCantidad = _carrito[existingProductIndex]['cantidad'] ?? 0;
        if (totalCantidad < producto['cantidad']) {
          _carrito[existingProductIndex]['cantidad'] += 1;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se puede agregar más de ${producto['cantidad']} unidades de ${producto['nombre']}')),
          );
        }
      } else {
        _carrito.add({
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'cantidad': 1,
        });
      }
      setState(() {});
    }
  }

  void aumentarCantidad(int index) {
    if (_carrito[index]['cantidad'] < _productosBox!.values.firstWhere((p) => p['nombre'] == _carrito[index]['nombre'])['cantidad']) {
      setState(() {
        _carrito[index]['cantidad'] += 1;
      });
    }
  }

  void disminuirCantidad(int index) {
    if (_carrito[index]['cantidad'] > 1) {
      setState(() {
        _carrito[index]['cantidad'] -= 1;
      });
    } else {
      setState(() {
        _carrito.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas - ${widget.rol}'),
      ),
      drawer: Drawer(
        child: MenuPage(rol: widget.rol),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Pestaña superior con curvas de color naranja
              ClipPath(
                clipper: CurvedTopClipper(),
                child: Container(
                  color: Colors.orange,
                  height: 80,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona una categoría:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        value: _categoriaSeleccionada,
                        items: _categoriasBox!.values.map((categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (categoria) {
                          setState(() {
                            _categoriaSeleccionada = categoria;
                            _productoSeleccionado = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_categoriaSeleccionada != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selecciona un producto:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Producto',
                                border: OutlineInputBorder(),
                              ),
                              value: _productoSeleccionado,
                              items: _productosBox!.values
                                  .where((producto) => producto['categoria'] == _categoriaSeleccionada)
                                  .map((producto) {
                                return DropdownMenuItem<String>(
                                  value: producto['nombre'],
                                  child: Text('${producto['nombre']} - \$${producto['precio']}'),
                                );
                              }).toList(),
                              onChanged: (producto) {
                                setState(() {
                                  _productoSeleccionado = producto;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: agregarAlCarrito,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 25,
                                ),
                              ),
                              child: const Text('Seleccionar'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Carrito:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _carrito.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_carrito[index]['nombre']} - \$${_carrito[index]['precio']}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cantidad: ${_carrito[index]['cantidad']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.red),
                                    onPressed: () => disminuirCantidad(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.green),
                                    onPressed: () => aumentarCantidad(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Pestaña inferior con curvas de color naranja
              ClipPath(
                clipper: CurvedBottomClipper(),
                child: Container(
                  color: Colors.orange,
                  height: 80,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarritoPage(
                        carrito: _carrito,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 25,
                  ),
                ),
                child: const Text('Añadir al carrito'),
              ),
            ),
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
