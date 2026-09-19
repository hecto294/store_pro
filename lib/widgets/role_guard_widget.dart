import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // ✅ Ruta correcta

class RoleGuardWidget extends StatelessWidget {
  final List<String> allowedRoles; // ✅ Tipo genérico correcto
  final Widget child;
  final Widget fallback;

  const RoleGuardWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // ✅ Tipo genérico correcto
    final userRole = authProvider.usuario?.role ?? '';

    if (allowedRoles.contains(userRole)) {
      return child;
    }

    return fallback;
  }
}