import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddRecipeScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  
  

  final TextEditingController nameController = TextEditingController();  
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar receta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la receta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),              
              const SizedBox(height: 16),
              Obx(
                () => ListTile(
                  title: const Text('Hora de la Medicación'),
                  subtitle: Text(
                    '${selectedTime.value.hour}:${selectedTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime.value,
                    );
                    if (time != null) {
                      selectedTime.value = time;
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final now = DateTime.now();
                    final medicationTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.value.hour,
                      selectedTime.value.minute,
                    );                    
                    Get.back();
                  }
                },
                child: const Text('Guardar Receta'),
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}
