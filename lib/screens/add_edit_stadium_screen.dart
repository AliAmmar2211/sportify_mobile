import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/providers/stadium_provider.dart';
import 'package:sportify_mobile/providers/auth_provider.dart';
import 'package:sportify_mobile/widgets/custom_text_field.dart';
import 'package:sportify_mobile/models/stadium.dart';

class AddEditStadiumScreen extends StatefulWidget {
  const AddEditStadiumScreen({super.key});

  @override
  State<AddEditStadiumScreen> createState() => _AddEditStadiumScreenState();
}

class _AddEditStadiumScreenState extends State<AddEditStadiumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  Stadium? _editingStadium;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _editingStadium = ModalRoute.of(context)!.settings.arguments as Stadium?;
    if (_editingStadium != null) {
      _nameController.text = _editingStadium!.name;
      _locationController.text = _editingStadium!.location;
      _descriptionController.text = _editingStadium!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingStadium == null ? 'Add Stadium' : 'Edit Stadium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Stadium Name',
                icon: Icons.stadium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Save Stadium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final stadium = Stadium(
        id: _editingStadium?.id,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        ownerId: user?.id,
      );

      Provider.of<StadiumProvider>(context, listen: false).addStadium(stadium, user?.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingStadium == null
                ? 'Stadium added successfully!'
                : 'Stadium updated successfully!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}