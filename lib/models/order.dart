// lib/models/order.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Representa un producto dentro de un pedido
class OrderItem {
  final String productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;

  OrderItem({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
  });
}

// Representa el pedido completo
class Order {
  final String id;
  final double total;
  final DateTime fecha;
  final String estado;
  final List<OrderItem> productos;

  Order({
    required this.id,
    required this.total,
    required this.fecha,
    required this.estado,
    required this.productos,
  });

  // En lib/models/order.dart

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // --- CORRECCIÓN AQUÍ ---
    // Usamos '?? []' para proveer una lista vacía si el campo 'productos' es nulo.
    // Esto evita el error de casteo.
    final List<dynamic> productsList = data['productos'] ?? [];

    // Ahora mapeamos de forma segura sobre productsList, que nunca será nula.
    final List<OrderItem> fetchedProducts = productsList.map((item) {
      return OrderItem(
        productoId: item['productoId'] ?? '',
        nombre: item['nombre'] ?? 'Producto no encontrado',
        cantidad: item['cantidad'] ?? 0,
        precioUnitario: (item['precioUnitario'] ?? 0.0).toDouble(),
      );
    }).toList();

    return Order(
      id: doc.id,
      total: (data['total'] ?? 0.0).toDouble(),
      fecha: (data['fecha'] as Timestamp? ?? Timestamp.now()).toDate(), // También hacemos la fecha más segura
      estado: data['estado'] ?? 'Desconocido',
      productos: fetchedProducts,
    );
  }
}