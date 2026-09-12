import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _yearController;
  late TextEditingController _kmController;

  File? _selectedImage;
  String? _existingPhotoUrl;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _plateController = TextEditingController(text: widget.vehicle?.plate ?? '');
    _yearController =
        TextEditingController(text: widget.vehicle?.year.toString() ?? '');
    _kmController = TextEditingController(
        text: widget.vehicle?.currentKm.toString() ?? '');
    _existingPhotoUrl = widget.vehicle?.photoUrl;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vehículo' : 'Nuevo Vehículo'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 24),
              Text(
                'Información del vehículo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _brandController,
                label: 'Marca',
                hint: 'ej: Toyota, Honda, BMW',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La marca es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _modelController,
                label: 'Modelo',
                hint: 'ej: Corolla, Civic, X5',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'El modelo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _plateController,
                label: 'Placa',
                hint: 'ej: ABC-123',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La placa es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _yearController,
                      label: 'Año',
                      hint: '2020',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Requerido';
                        }
                        final year = int.tryParse(value!);
                        if (year == null || year < 1900 || year > 2100) {
                          return 'Año inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _kmController,
                      label: 'Km actuales',
                      hint: '45000',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                      : Text(isEditing ? 'Guardar Cambios' : 'Agregar Vehículo'),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _deleteVehicle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Eliminar Vehículo'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del Vehículo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1A73E8).withAlpha(50),
              ),
            ),
            child: _buildPhotoContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoContent() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _existingPhotoUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildEmptyPhotoPlaceholder();
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _existingPhotoUrl = null),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildEmptyPhotoPlaceholder();
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap para seleccionar foto',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
      maxLines: maxLines,
      validator: validator,
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _existingPhotoUrl = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _existingPhotoUrl = null;
      });
    }
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

      final year = int.parse(_yearController.text);
      final km = int.parse(_kmController.text);

      String? photoUrl = _existingPhotoUrl;

      if (_selectedImage != null) {
        Logger.info('Subiendo foto...');
        try {
          final uploadedUrl = await _firebaseService.uploadVehiclePhoto(
            userId,
            widget.vehicle?.id ?? _firebaseService.generateId(),
            _selectedImage!,
          );
          if (uploadedUrl != null) {
            photoUrl = uploadedUrl;
            Logger.success('Foto subida correctamente');
          } else {
            Logger.warning('No se pudo subir la foto, continuando sin ella');
          }
        } catch (e) {
          Logger.warning('Error al subir foto: $e, continuando sin ella');
        }
      }

      if (widget.vehicle == null) {
        final newVehicle = Vehicle(
          id: _firebaseService.generateId(),
          userId: userId,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          plate: _plateController.text.trim(),
          year: year,
          currentKm: km,
          photoUrl: photoUrl,
          createdAt: DateTime.now(),
        );

        await _firebaseService.addVehicle(newVehicle);
        Logger.success('Vehículo agregado: ${newVehicle.plate}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo agregado exitosamente')),
          );
        }
      } else {
        final updatedVehicle = widget.vehicle!.copyWith(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          plate: _plateController.text.trim(),
          year: year,
          currentKm: km,
          photoUrl: photoUrl,
        );

        await _firebaseService.updateVehicle(updatedVehicle);
        Logger.success('Vehículo actualizado: ${updatedVehicle.plate}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      Logger.error('Error al guardar vehículo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteVehicle() async {
    if (widget.vehicle == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${widget.vehicle!.brand} ${widget.vehicle!.model}?',
        ),
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
      await _firebaseService.deleteVehicle(widget.vehicle!.id);
      Logger.success('Vehículo eliminado: ${widget.vehicle!.plate}');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo eliminado exitosamente')),
        );
      }
    } catch (e) {
      Logger.error('Error al eliminar vehículo: $e');
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
