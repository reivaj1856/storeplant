// lib/models/cart_item.dart

class CartItem {
  final String id; // ID único para el item en el carrito
  final String productId; // ID del producto en Firestore
  final String nombre;
  final double precio;
  int cantidad;

  CartItem({
    required this.id,
    required this.productId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });
}