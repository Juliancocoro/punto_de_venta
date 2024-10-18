import 'package:flutter/material.dart';

class CarritoPage extends StatefulWidget {
  final List<Map<String, dynamic>> carrito; // Recibe el carrito desde VentasPage

  const CarritoPage({super.key, required this.carrito}); // Constructor

  @override
  // ignore: library_private_types_in_public_api
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<Map<String, dynamic>> _carrito = [];

  @override
  void initState() {
    super.initState();
    _carrito = widget.carrito; // Inicializa el carrito con los productos recibidos
  }

  double calcularTotal() {
    double total = 0.0;
    for (var item in _carrito) {
      total += item['precio'] * item['cantidad'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos en el carrito:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _carrito.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('${_carrito[index]['nombre']} - \$${_carrito[index]['precio']}'),
                      subtitle: Text('Cantidad: ${_carrito[index]['cantidad']}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la funcionalidad para proceder al pago
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
              child: const Text('Proceder al Pago'),
            ),
          ],
        ),
      ),
    );
  }
}
