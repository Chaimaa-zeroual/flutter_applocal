import 'package:flutter/material.dart';
import 'pages/auth/auth_gate.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(
  primaryColor: Color(0xFF855386), // Violet personnalisé
),

      home: AuthGate(),
    );
  }
}
