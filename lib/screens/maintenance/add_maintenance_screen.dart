import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final String vehicleId;
  final Maintenance? maintenance;

  const AddMaintenanceScreen({
    Key? key,
    required this.vehicleId,
    this.maintenance,
  }) : super(key: key);

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  late TextEditingController _kmController;
  late TextEditingController _costController;
  late TextEditingController _workshopController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late MaintenanceType _selectedType;

  @override
  void initState() {
    super.initState();
    _kmController = TextEditingController(text: widget.maintenance?.km.toString() ?? '');
    _costController = TextEditingController(text: widget.maintenance?.cost.toString() ?? '');
    _workshopController = TextEditingController(text: widget.maintenance?.workshop ?? '');
    _notesController = TextEditingController(text: widget.maintenance?.notes ?? '');
    _selectedDate = widget.maintenance?.date ?? DateTime.now();
    _selectedType = widget.maintenance?.type ?? MaintenanceType.oil;
  }

  @override
  void dispose() {
    _kmController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.maintenance != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento'),
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
                'Información del Mantenimiento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _kmController,
                      label: 'Kilómetros',
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _costController,
                      label: 'Costo (\$)',
                      hint: '150.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _workshopController,
                label: 'Taller (Opcional)',
                hint: 'ej: Taller Juan',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _notesController,
                label: 'Notas (Opcional)',
                hint: 'Comentarios adicionales',
                maxLines: 3,
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
                      : Text(isEditing ? 'Guardar Cambios' : 'Registrar Mantenimiento'),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _deleteMaintenance,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Eliminar Mantenimiento'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<MaintenanceType>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo de Mantenimiento',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: MaintenanceType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un tipo';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: const TextStyle(fontSize: 16),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
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

      final km = int.parse(_kmController.text);
      final cost = double.parse(_costController.text);

      if (widget.maintenance == null) {
        final newMaintenance = Maintenance(
          id: _firebaseService.generateId(),
          vehicleId: widget.vehicleId,
          userId: userId,
          type: _selectedType,
          date: _selectedDate,
          km: km,
          cost: cost,
          workshop: _workshopController.text.trim().isEmpty ? null : _workshopController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: DateTime.now(),
        );

        await _firebaseService.addMaintenance(newMaintenance);
        Logger.success('Mantenimiento registrado: ${_selectedType.displayName}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mantenimiento registrado exitosamente')),
          );
        }
      } else {
        final updatedMaintenance = widget.maintenance!.copyWith(
          type: _selectedType,
          date: _selectedDate,
          km: km,
          cost: cost,
          workshop: _workshopController.text.trim().isEmpty ? null : _workshopController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateMaintenance(updatedMaintenance);
        Logger.success('Mantenimiento actualizado: ${_selectedType.displayName}');

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mantenimiento actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      Logger.error('Error al guardar mantenimiento: $e');
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

  void _deleteMaintenance() async {
    if (widget.maintenance == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mantenimiento'),
        content: const Text('¿Estás seguro de que quieres eliminar este mantenimiento?'),
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
      await _firebaseService.deleteMaintenance(widget.maintenance!.id);
      Logger.success('Mantenimiento eliminado');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mantenimiento eliminado exitosamente')),
        );
      }
    } catch (e) {
      Logger.error('Error al eliminar mantenimiento: $e');
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
