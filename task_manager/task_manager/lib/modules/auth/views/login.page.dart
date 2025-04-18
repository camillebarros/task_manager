import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/routes/routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offNamed(Routes.HOME),
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.REGISTER),
              child: const Text('Criar uma conta'),
            ),
          ],
        ),
      ),
    );
  }
}