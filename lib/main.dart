import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Este archivo es generado por FlutterFire CLI

import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // Asegúrate de que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider hace que el CartProvider esté disponible en toda la app
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
        title: 'VentPlant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF0FFF0), // Verde muy suave (Honeydew)
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF66BB6A), // Un verde suave
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}