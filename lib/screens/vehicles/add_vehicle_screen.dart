import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _yearController;
  late TextEditingController _kmController;

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

      if (widget.vehicle == null) {
        // Crear nuevo vehículo
        final newVehicle = Vehicle(
          id: _firebaseService.generateId(),
          userId: userId,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          plate: _plateController.text.trim(),
          year: year,
          currentKm: km,
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
        // Editar vehículo existente
        final updatedVehicle = widget.vehicle!.copyWith(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          plate: _plateController.text.trim(),
          year: year,
          currentKm: km,
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
          SnackBar(content: Text('Error: $e')),
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
