import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VentPlant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const OrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuchamos los cambios en la colección 'Productos' en tiempo real
        stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
        builder: (ctx, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (productSnapshot.hasError) {
            return const Center(child: Text("Algo salió mal."));
          }
          if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay plantas a la venta."));
          }

          final productDocs = productSnapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: productDocs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              final product = productDocs[index];
              final productData = product.data() as Map<String, dynamic>;

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(
                      productData['nombre'],
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      '\$${productData['precio'].toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ProductDetailScreen(
                            productId: product.id,
                            productData: productData,
                          ),
                        ),
                      );
                    },
                    // Placeholder para imagen
                    child: Container(
                      color: Colors.green[200],
                      child: Center(
                        child: Icon(Icons.local_florist, size: 80, color: Colors.green[800]),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}