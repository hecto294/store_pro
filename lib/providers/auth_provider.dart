import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus status = AuthStatus.checking;
  Usuario? usuario;

  AuthProvider() {
    checkAuthStatus();
  }

  // 1. Comprueba la sesión activa al arrancar la app (Splash Flow)
  Future checkAuthStatus() async {
    status = AuthStatus.checking;
    notifyListeners(); // Notifica a la UI que estamos verificando

    final user = await _authService.getPerfil();
    if (user != null) {
      usuario = user;
      status = AuthStatus.authenticated;
    } else {
      usuario = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners(); // Notifica el cambio final de estado
  }

  // 2. Inicia sesión y refresca el estado
  Future login(String email, String password) async {
    bool exito = await _authService.login(email, password);
    if (exito) {
      await checkAuthStatus();
      return true;
    }
    return false;
  }

  // 3. Cierra sesión y limpia los datos en memoria
  Future logout() async {
    await _authService.logout();
    usuario = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Getter RBAC helper para consultar si el usuario actual es Admin
  bool get isAdmin => usuario?.role == 'admin';
}