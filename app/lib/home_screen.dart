import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserSession session;

  const HomeScreen({super.key, required this.session});

  Future<void> _logout(BuildContext context) async {
    await authService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
              const SizedBox(height: 16),
              const Text('You are logged in', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              Text(session.email, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Chip(label: Text(session.role)),
              const SizedBox(height: 24),
              const Text('Issue list coming soon', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}