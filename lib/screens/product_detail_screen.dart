import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int desiredQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final stock = widget.productData['stock'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productData['nombre']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.green[200],
              child: Center(
                child: Icon(Icons.local_florist, size: 150, color: Colors.green[800]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.productData['nombre'],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.productData['precio'].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Disponibles: $stock',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(
              widget.productData['descripcion'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (stock > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (desiredQuantity > 1) {
                        setState(() => desiredQuantity--);
                      }
                    },
                  ),
                  Text(
                    '$desiredQuantity',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      if (desiredQuantity < stock) {
                        setState(() => desiredQuantity++);
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Añadir al carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                // ... (resto del código de ProductDetailScreen)

                onPressed: stock <= 0
                    ? null
                    : () {
                        Provider.of<CartProvider>(context, listen: false).addItem(
                          widget.productId,
                          widget.productData['nombre'],
                          // --- CORRECCIÓN AQUÍ ---
                          // Aseguramos que el precio sea tratado como double
                          (widget.productData['precio'] as num).toDouble(),
                          // -----------------------
                          desiredQuantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Añadido al carrito!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop();
                      },

                // ... (resto del código)
              ),
            ),
            if (stock <= 0)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'Producto agotado',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}