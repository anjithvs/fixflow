import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const FixFlowApp());
}

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const StartupGate(),
    );
  }
}

/// Decides which screen to show first: home (if already logged in) or login.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late final Future<UserSession?> _sessionFuture = authService.restoreSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.data;
        return session == null ? const LoginScreen() : HomeScreen(session: session);
      },
    );
  }
}