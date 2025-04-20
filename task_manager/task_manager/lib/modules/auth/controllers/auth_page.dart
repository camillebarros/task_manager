import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final AuthController _controller = Get.find();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => _controller.signIn(
                    _emailController.text,
                    _passwordController.text,
                  ),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
