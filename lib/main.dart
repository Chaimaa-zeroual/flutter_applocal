import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart'; // Ton widget racine MyApp ici
import 'providers/favorites_provider.dart'; // Provider pour favoris
import 'providers/cart_provider.dart'; // Provider pour cart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD_znyn7Om1dpz_Y7xfm7vLDt_UMyGUCnY",
        authDomain: "ecommerce-app-local-9c17f.firebaseapp.com",
        projectId: "ecommerce-app-local-9c17f",
        storageBucket: "ecommerce-app-local-9c17f.appspot.com",
        messagingSenderId: "24261551067",
        appId: "1:24261551067:web:f797463895e3c74eb63dfe",
        measurementId: "G-NYGCS154FY",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}
