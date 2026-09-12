import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class AddDriverScreen extends StatefulWidget {
  final Driver? driver;

  const AddDriverScreen({Key? key, this.driver}) : super(key: key);

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _licenseNumberController;
  DateTime? _licenseExpiry;
  File? _driverPhoto;
  File? _licensePhoto;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phone ?? '');
    _emailController = TextEditingController(text: widget.driver?.email ?? '');
    _licenseNumberController = TextEditingController(text: widget.driver?.licenseNumber ?? '');
    _licenseExpiry = widget.driver?.licenseExpiry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _licenseExpiry = picked);
    }
  }

  Future<void> _pickDriverPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _driverPhoto = File(pickedFile.path));
      }
    } catch (e) {
      Logger.error('Error picking photo: $e');
    }
  }

  Future<void> _pickLicensePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _licensePhoto = File(pickedFile.path));
      }
    } catch (e) {
      Logger.error('Error picking photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.driver != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Conductor' : 'Nuevo Conductor'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto del Conductor',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDriverPhoto,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: _driverPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_driverPhoto!, fit: BoxFit.cover),
                        )
                      : widget.driver?.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.driver!.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, size: 48, color: Colors.grey[600]),
                                        const SizedBox(height: 8),
                                        const Text('Tap para cambiar foto'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add, size: 48, color: Colors.grey[600]),
                                  const SizedBox(height: 8),
                                  const Text('Tap para agregar foto'),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Información Personal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _nameController,
                label: 'Nombre Completo',
                hint: 'ej: Juan Pérez',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _phoneController,
                label: 'Teléfono',
                hint: '+57 310 123 4567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email',
                hint: 'conductor@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              Text(
                'Licencia de Conducción',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _licenseNumberController,
                label: 'Número de Licencia',
                hint: 'ej: 1234567890',
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vencimiento de Licencia',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _licenseExpiry != null
                                ? '${_licenseExpiry!.day}/${_licenseExpiry!.month}/${_licenseExpiry!.year}'
                                : 'Seleccionar fecha',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF1A73E8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Foto de la Licencia',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickLicensePhoto,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: _licensePhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_licensePhoto!, fit: BoxFit.cover),
                        )
                      : widget.driver?.licensePhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.driver!.licensePhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.document_scanner, size: 36, color: Colors.grey[600]),
                                        const SizedBox(height: 4),
                                        const Text('Tap para cambiar', style: TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.document_scanner, size: 36, color: Colors.grey[600]),
                                  const SizedBox(height: 4),
                                  const Text('Tap para agregar foto', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Guardar Cambios' : 'Agregar Conductor'),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _deleteDriver,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Eliminar Conductor'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      String? driverPhotoUrl;
      String? licensePhotoUrl;

      if (_driverPhoto != null) {
        driverPhotoUrl = await _firebaseService.uploadDriverPhoto(userId, _driverPhoto!);
      } else if (widget.driver != null) {
        driverPhotoUrl = widget.driver!.photoUrl;
      }

      if (_licensePhoto != null) {
        licensePhotoUrl = await _firebaseService.uploadLicensePhoto(userId, _licensePhoto!);
      } else if (widget.driver != null) {
        licensePhotoUrl = widget.driver!.licensePhotoUrl;
      }

      if (widget.driver == null) {
        final newDriver = Driver(
          id: _firebaseService.generateId(),
          userId: userId,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim().isEmpty
              ? null
              : _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiry,
          photoUrl: driverPhotoUrl,
          licensePhotoUrl: licensePhotoUrl,
          createdAt: DateTime.now(),
        );

        await _firebaseService.addDriver(newDriver);
        Logger.success('Conductor agregado: ${newDriver.name}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conductor agregado exitosamente')),
          );
        }
      } else {
        final updatedDriver = widget.driver!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim().isEmpty
              ? null
              : _licenseNumberController.text.trim(),
          licenseExpiry: _licenseExpiry,
          photoUrl: driverPhotoUrl,
          licensePhotoUrl: licensePhotoUrl,
        );

        await _firebaseService.updateDriver(updatedDriver);
        Logger.success('Conductor actualizado: ${updatedDriver.name}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conductor actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      Logger.error('Error al guardar conductor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteDriver() async {
    if (widget.driver == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conductor'),
        content: Text('¿Estás seguro de que quieres eliminar ${widget.driver!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _firebaseService.deleteDriver(userId, widget.driver!.id);
      Logger.success('Conductor eliminado: ${widget.driver!.name}');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conductor eliminado exitosamente')),
        );
      }
    } catch (e) {
      Logger.error('Error al eliminar conductor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
