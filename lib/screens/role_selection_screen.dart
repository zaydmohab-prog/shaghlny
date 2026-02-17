import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'worker_dashboard.dart';
import 'worker_registration_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Worker Registration")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Register as Worker"),
          onPressed: () async {
            await auth.updateRole("worker");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const WorkerRegistrationScreen()),
            );
          },
        ),
      ),
    );
  }
}
