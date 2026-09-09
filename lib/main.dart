import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';

void main() async {
  // Asegura la inicialización de bindings para procesos asíncronos en main
  WidgetsFlutterBinding.ensureInitialized();

  // Carga obligatoria del archivo de variables de entorno (.env) antes de iniciar la app
  await dotenv.load(fileName: "assets/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StorePro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
        useMaterial3: true,
      ),
      // Punto de arranque: Inicia en LoginScreen y fluye hacia PerfilScreen
      home: const LoginScreen(),
    );
  }
}