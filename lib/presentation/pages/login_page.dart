import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/presentation/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              Obx(() {
                if (authController.isLoading.value) {
                  return CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: Text('Iniciar Sesión'),
                );
              }),
              TextButton(
                onPressed: () => Get.to(() => RegisterPage()),
                child: Text('¿No tienes cuenta? Regístrate'),
              ),
              Obx(() {
                if (authController.error.value.isNotEmpty) {
                  return Text(
                    authController.error.value,
                    style: TextStyle(color: Colors.red),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
