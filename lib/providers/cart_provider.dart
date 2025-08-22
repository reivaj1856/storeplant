// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.precio * cartItem.cantidad;
    });
    return total;
  }

  void addItem(String productId, String nombre, double precio, int cantidad) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          nombre: existingCartItem.nombre,
          precio: existingCartItem.precio,
          cantidad: existingCartItem.cantidad + cantidad,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          nombre: nombre,
          precio: precio,
          cantidad: cantidad,
        ),
      );
    }
    notifyListeners();
  }

  void increaseItemQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
            id: existing.id,
            productId: existing.productId,
            nombre: existing.nombre,
            precio: existing.precio,
            cantidad: existing.cantidad + 1),
      );
      notifyListeners();
    }
  }

  // --- LÓGICA MODIFICADA AQUÍ ---
  void decreaseItemQuantity(String productId) {
    if (!_items.containsKey(productId)) {
      return; // Si el item no existe, no hagas nada.
    }

    // Solo reduce la cantidad si es MAYOR que 1.
    // Si es 1, esta condición será falsa y la función terminará sin hacer nada.
    if (_items[productId]!.cantidad > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
            id: existing.id,
            productId: existing.productId,
            nombre: existing.nombre,
            precio: existing.precio,
            cantidad: existing.cantidad - 1),
      );
      notifyListeners();
    }
  }
  // --- FIN DE LA MODIFICACIÓN ---

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}