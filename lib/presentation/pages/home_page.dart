import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:users_auth/controllers/auth_controller.dart';
import 'package:users_auth/controllers/user_controller.dart';
import 'package:users_auth/model/user_model.dart';

class HomePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  HomePage({super.key});

  void _submitUser(UserController controller) {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        id: '',
        username: _usernameController.text,
        email: _emailController.text,
      );

      controller.addUser(user);

      _usernameController.clear();
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios con Appwrite'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: GetX<UserController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      ElevatedButton(
                        onPressed: () => _submitUser(controller),
                        child: Text('Agregar Usuario'),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.error.value.isNotEmpty)
                Text(
                  'Error: ${controller.error.value}',
                  style: TextStyle(color: Colors.red),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    /* return ListTile(
                      title: Text(user.username),
                      subtitle: Text(user.email),
                    ); */

                    return ListTile(
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _emailController.text = user.email;
                              _usernameController.text = user.username;
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Actualizar Usuario'),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller: _usernameController,
                                              decoration: InputDecoration(
                                                labelText: 'Username',
                                              ),
                                              validator:
                                                  (value) =>
                                                      value!.isEmpty
                                                          ? 'Campo requerido'
                                                          : null,
                                            ),
                                            TextFormField(
                                              controller: _emailController,
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                              ),
                                              validator:
                                                  (value) =>
                                                      value!.isEmpty
                                                          ? 'Campo requerido'
                                                          : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              controller.updateUser(
                                                user.id,
                                                UserModel(
                                                  id: user.id,
                                                  username:
                                                      _usernameController.text,
                                                  email: _emailController.text,
                                                ),
                                              );
                                              Navigator.pop(context);
                                              _usernameController.clear();
                                              _emailController.clear();
                                            }
                                          },
                                          child: Text('Actualizar'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Confirmar eliminación'),
                                      content: Text(
                                        '¿Está seguro de eliminar este usuario?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.deleteUser(user.id);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
