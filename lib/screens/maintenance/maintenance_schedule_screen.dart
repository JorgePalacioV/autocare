import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class MaintenanceScheduleScreen extends StatefulWidget {
  const MaintenanceScheduleScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScheduleScreen> createState() => _MaintenanceScheduleScreenState();
}

class _MaintenanceScheduleScreenState extends State<MaintenanceScheduleScreen> {
  final _firebaseService = FirebaseService();
  bool _isLoading = true;
  Map<MaintenanceType, MaintenanceSchedule?> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId == null) return;

      final schedules = await _firebaseService.getAllMaintenanceSchedules(userId);
      final map = <MaintenanceType, MaintenanceSchedule?>{};

      for (final type in MaintenanceType.values) {
        map[type] = schedules.firstWhere(
          (s) => s.type == type,
          orElse: () => MaintenanceSchedule(
            id: _firebaseService.generateId(),
            userId: userId,
            type: type,
            recommendedIntervalKm: MaintenanceSchedule.defaultIntervalKm[type],
            recommendedIntervalDays: MaintenanceSchedule.defaultIntervalDays[type],
            createdAt: DateTime.now(),
          ),
        );
      }

      setState(() {
        _schedules = map;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error cargando horarios: $e');
      setState(() => _isLoading = false);
    }
  }

  void _editSchedule(MaintenanceType type) {
    final schedule = _schedules[type];
    if (schedule == null) return;

    final kmController = TextEditingController(text: schedule.recommendedIntervalKm?.toString() ?? '');
    final daysController = TextEditingController(text: schedule.recommendedIntervalDays?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${type.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kmController,
                decoration: const InputDecoration(
                  labelText: 'Intervalo (km)',
                  hintText: 'ej: 5000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: daysController,
                decoration: const InputDecoration(
                  labelText: 'Intervalo (días)',
                  hintText: 'ej: 365',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final kmValue = int.tryParse(kmController.text);
              final daysValue = int.tryParse(daysController.text);

              if ((kmValue ?? 0) <= 0 && (daysValue ?? 0) <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa al menos un intervalo válido')),
                );
                return;
              }

              try {
                final userId = _firebaseService.currentUserId;
                if (userId == null) throw Exception('Usuario no autenticado');

                final updated = schedule.copyWith(
                  recommendedIntervalKm: kmValue,
                  recommendedIntervalDays: daysValue,
                );

                await _firebaseService.setMaintenanceSchedule(userId, updated);
                Logger.success('Horario actualizado: ${type.displayName}');

                if (mounted) {
                  Navigator.pop(context);
                  _loadSchedules();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Horario actualizado')),
                  );
                }
              } catch (e) {
                Logger.error('Error al guardar: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Horarios de Mantenimiento')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de Mantenimiento'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1A73E8).withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, size: 20, color: Color(0xFF1A73E8)),
                  SizedBox(height: 8),
                  Text(
                    'Configura los intervalos recomendados de mantenimiento. Recibirás alertas cuando esté próximo.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._schedules.entries.map((entry) {
              final type = entry.key;
              final schedule = entry.value;

              if (schedule == null) return const SizedBox.shrink();

              return _buildScheduleCard(type, schedule);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(MaintenanceType type, MaintenanceSchedule schedule) {
    return GestureDetector(
      onTap: () => _editSchedule(type),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildIntervalText(schedule),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 18, color: Color(0xFF1A73E8)),
          ],
        ),
      ),
    );
  }

  String _buildIntervalText(MaintenanceSchedule schedule) {
    final parts = <String>[];
    if (schedule.recommendedIntervalKm != null && schedule.recommendedIntervalKm! > 0) {
      parts.add('${schedule.recommendedIntervalKm} km');
    }
    if (schedule.recommendedIntervalDays != null && schedule.recommendedIntervalDays! > 0) {
      parts.add('${schedule.recommendedIntervalDays} días');
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'No configurado';
  }
}
