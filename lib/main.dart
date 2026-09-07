import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';

void main() {
  runApp(const StoreProApp());
}

class StoreProApp extends StatelessWidget {
  const StoreProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StorePro Fake API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CatalogoScreen(),
    );
  }
}