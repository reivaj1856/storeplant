// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  // La función _placeOrder no cambia.
  Future<void> _placeOrder(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final newOrderRef = firestore.collection('Pedidos').doc();
        final List<Map<String, dynamic>> productsInOrder = [];
        for (var item in cart.items.entries) {
          final productId = item.key;
          final cartItem = item.value;
          final productRef = firestore.collection('Productos').doc(productId);
          final productSnapshot = await transaction.get(productRef);
          if (!productSnapshot.exists) throw Exception("Producto no encontrado: ${cartItem.nombre}");
          final currentStock = productSnapshot.data()!['stock'] as int;
          if (currentStock < cartItem.cantidad) throw Exception("Stock insuficiente para: ${cartItem.nombre}");
          transaction.update(productRef, {'stock': currentStock - cartItem.cantidad});
          productsInOrder.add({
            'productoId': productId,
            'nombre': cartItem.nombre,
            'cantidad': cartItem.cantidad,
            'precioUnitario': cartItem.precio,
          });
        }
        transaction.set(newOrderRef, {
          'productos': productsInOrder,
          'total': cart.totalAmount,
          'fecha': Timestamp.now(),
          'estado': 'Pendiente',
        });
      });
      cart.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Pedido realizado con éxito!')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al realizar el pedido: ${error.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  // El ListView.builder no necesita cambios.
                  child: cart.items.isEmpty
                      ? const Center(
                          child: Text('Tu carrito está vacío.'),
                        )
                      : ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (ctx, i) {
                            final productId = cart.items.keys.toList()[i];
                            final cartItem = cart.items.values.toList()[i];
                            return Dismissible(
                              key: ValueKey(cartItem.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) => cart.removeItem(productId),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white, size: 40),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green[100],
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: FittedBox(child: Text('\$${cartItem.precio.toStringAsFixed(2)}')),
                                      ),
                                    ),
                                    title: Text(cartItem.nombre),
                                    subtitle: Text('Total: \$${(cartItem.precio * cartItem.cantidad).toStringAsFixed(2)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('¿Estás seguro?'),
                                              content: Text('¿Quieres eliminar "${cartItem.nombre}" del carrito?'),
                                              actions: <Widget>[
                                                TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop()),
                                                TextButton(
                                                    child: const Text('Sí, eliminar'),
                                                    onPressed: () {
                                                      Navigator.of(ctx).pop();
                                                      cart.removeItem(productId);
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => cart.decreaseItemQuantity(productId)),
                                        Text('${cartItem.cantidad}', style: const TextStyle(fontSize: 16)),
                                        IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => cart.increaseItemQuantity(productId)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // --- CAMBIOS DE DISEÑO EN ESTA SECCIÓN ---
                Card(
                  margin: const EdgeInsets.all(15),
                  color: Colors.green[300], // Fondo del card en verde claro
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Total', style: TextStyle(fontSize: 20)),
                        const Spacer(),
                        Chip(
                          label: Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white, // Texto del chip en blanco
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Le damos un color de fondo verde oscuro y personalizado
                          backgroundColor: Colors.green[800],
                        ),
                        const SizedBox(width: 8), // Un pequeño espacio
                        // Convertimos el TextButton en un ElevatedButton para darle más estilo
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700], // Fondo del botón verde
                            foregroundColor: Colors.white, // Texto del botón en blanco
                          ),
                          onPressed: (cart.totalAmount <= 0 || _isLoading)
                              ? null
                              : () => _placeOrder(cart),
                          child: const Text('COMPRAR AHORA'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}