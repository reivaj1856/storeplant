// lib/screens/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  // La función _cancelOrder no cambia.
  Future<void> _cancelOrder(BuildContext context, String orderId, List<dynamic> products) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final orderRef = firestore.collection('Pedidos').doc(orderId);
        for (var product in products) {
          final productRef = firestore.collection('Productos').doc(product['productoId']);
          final productSnapshot = await transaction.get(productRef);
          if (productSnapshot.exists) {
            final currentStock = productSnapshot.data()!['stock'] as int;
            transaction.update(productRef, {'stock': currentStock + product['cantidad']});
          }
        }
        transaction.update(orderRef, {'estado': 'Cancelado'});
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado y stock devuelto.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar el pedido: ${e.toString()}')),
      );
    }
  }

  // --- NUEVA FUNCIÓN PARA ELIMINAR UN PEDIDO ---
  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    try {
      // Simplemente borra el documento de la colección 'Pedidos'.
      await FirebaseFirestore.instance.collection('Pedidos').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido eliminado permanentemente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el pedido: ${e.toString()}')),
      );
    }
  }
  // --- FIN DE LA NUEVA FUNCIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Pedidos').orderBy('fecha', descending: true).snapshots(),
        builder: (ctx, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No has realizado ningún pedido.'));
          }

          final orderDocs = orderSnapshot.data!.docs;

          return ListView.builder(
            itemCount: orderDocs.length,
            itemBuilder: (ctx, i) {
              final orderData = orderDocs[i].data() as Map<String, dynamic>;
              final products = orderData['productos'] as List<dynamic>? ?? [];
              final date = (orderData['fecha'] as Timestamp? ?? Timestamp.now()).toDate();
              final estado = orderData['estado'] ?? 'Desconocido';
              final total = (orderData['total'] ?? 0.0).toDouble();
              // --- CAMBIO DE DISEÑO AQUÍ ---
              return Card(
                elevation: 3, // Una pequeña sombra para que resalte
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  // Damos un color de fondo cuando está expandido
                  backgroundColor: Colors.green.shade50,
                  collapsedBackgroundColor: Colors.green.shade50, // Y un color cuando está cerrado
                  shape: const Border(), // Quitamos el borde por defecto al expandir
                  title: Text('Pedido - \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd MMMM yyyy, HH:mm').format(date)),
                  trailing: Text(
                    estado,
                    style: TextStyle(
                      color: estado == 'Pendiente' ? Colors.orange.shade700 : (estado == 'Cancelado' ? Colors.red.shade700 : Colors.green.shade700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    ...products.map((prod) {
                      return ListTile(
                        title: Text(prod['nombre'] ?? 'Sin nombre'),
                        subtitle: Text('Precio: \$${(prod['precioUnitario'] ?? 0.0).toStringAsFixed(2)}'),
                        trailing: Text('Cantidad: ${prod['cantidad'] ?? 0}'),
                      );
                    }).toList(),
                    // Mostramos los botones de acción en una fila
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botón para cancelar (solo si está pendiente)
                          if (estado == 'Pendiente')
                            TextButton.icon(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                              label: const Text('Cancelar', style: TextStyle(color: Colors.orange)),
                              onPressed: () => _cancelOrder(context, orderDocs[i].id, products),
                            ),
                          // Botón para eliminar (solo si NO está pendiente)
                          if (estado != 'Pendiente')
                            TextButton.icon(
                              icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                              label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                // Mostramos diálogo de confirmación antes de borrar
                                showDialog(
                                  context: context,
                                  builder: (dlgCtx) => AlertDialog(
                                    title: const Text('¿Estás seguro?'),
                                    content: const Text('Esta acción eliminará el pedido permanentemente y no se puede deshacer.'),
                                    actions: [
                                      TextButton(child: const Text('No'), onPressed: () => Navigator.of(dlgCtx).pop()),
                                      TextButton(
                                        child: const Text('Sí, eliminar'),
                                        onPressed: () {
                                          Navigator.of(dlgCtx).pop();
                                          _deleteOrder(context, orderDocs[i].id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}