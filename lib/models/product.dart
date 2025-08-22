// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
  });

  // Un "factory constructor" para crear una instancia de Product desde un documento de Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nombre: data['name'] ?? '',
      descripcion: data['description'] ?? '',
      precio: (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
    );
  }
}