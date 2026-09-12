import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import 'add_vehicle_screen.dart';
import '../maintenance/add_maintenance_screen.dart';
import '../maintenance/maintenance_history_screen.dart';
import '../drivers/drivers_list_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _firebaseService = FirebaseService();
  late Vehicle _currentVehicle;
  late Future<Map<String, dynamic>> _vehicleStatsFuture;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
    _vehicleStatsFuture = _firebaseService.getVehicleStats(_currentVehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentVehicle.brand} ${_currentVehicle.model}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editVehicle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            if (_currentVehicle.photoUrl != null && _currentVehicle.photoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _currentVehicle.photoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            if (_currentVehicle.photoUrl != null && _currentVehicle.photoUrl!.isNotEmpty)
              const SizedBox(height: 24),
            _buildVehicleCard(),
            const SizedBox(height: 24),
            _buildDriverSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildAlertsSection(),
            const SizedBox(height: 24),
            _buildMaintenanceSection(),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Marca', '${_currentVehicle.brand} ${_currentVehicle.model}'),
            const Divider(),
            _buildInfoRow('Placa', _currentVehicle.plate),
            const Divider(),
            _buildInfoRow('Año', '${_currentVehicle.year}'),
            const Divider(),
            _buildInfoRow('Kilómetros', '${_currentVehicle.currentKm} km'),
            const Divider(),
            _buildInfoRow(
              'Agregado',
              _formatDate(_currentVehicle.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conductor Asignado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (_currentVehicle.primaryDriverId == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sin conductor asignado',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selecciona un conductor para este vehículo',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _changeDriver,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              )
            else
              FutureBuilder<Driver?>(
                future: _firebaseService.getDriver(
                  _firebaseService.currentUserId ?? '',
                  _currentVehicle.primaryDriverId ?? '',
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final driver = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withAlpha(13),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF1A73E8).withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                driver.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (driver.phone != null)
                                  Text(
                                    driver.phone!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _changeDriver,
                            icon: const Icon(Icons.edit),
                            iconSize: 18,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _vehicleStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data ?? {};
        final totalCount = stats['totalCount'] as int? ?? 0;
        final totalCost = stats['totalCost'] as double? ?? 0.0;
        final averageCost = stats['averageCost'] as double? ?? 0.0;
        final daysLastMaintenance = stats['daysLastMaintenance'] as int?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.build,
                    label: 'Mantenimientos',
                    value: '$totalCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Costo Total',
                    value: '\$${totalCost.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_down,
                    label: 'Promedio',
                    value: '\$${averageCost.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: 'Hace',
                    value: daysLastMaintenance != null ? '${daysLastMaintenance}d' : '-',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8).withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1A73E8).withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A73E8)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _firebaseService.getVehicleAlerts(_currentVehicle.id, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data ?? {};

        if (alerts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Todo al día',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No hay mantenimientos vencidos',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de Mantenimiento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...alerts.entries.map((entry) {
              final type = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final status = data['status'] as AlertStatus;
              final reason = data['reason'] as String?;

              return _buildAlertCard(status, type, reason);
            }),
          ],
        );
      },
    );
  }

  Widget _buildAlertCard(AlertStatus status, String type, String? reason) {
    final colors = {
      AlertStatus.ok: (Color(0xFF34A853), Color(0xFF34A853).withAlpha(13)),
      AlertStatus.warning: (Color(0xFFFBBC04), Color(0xFFFBBC04).withAlpha(13)),
      AlertStatus.overdue: (Colors.red, Colors.red.withAlpha(13)),
    };

    final (borderColor, bgColor) = colors[status] ?? (Colors.grey, Colors.grey.withAlpha(13));

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            status.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (reason != null)
                  Text(
                    reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              status.label,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              'Mantenimientos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 0,
              children: [
                TextButton.icon(
                  onPressed: _viewHistory,
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('Historial', style: TextStyle(fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: _addMaintenance,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Maintenance>>(
          stream: _firebaseService.getVehicleMaintenancesStream(
            _currentVehicle.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final maintenances = snapshot.data ?? [];

            if (maintenances.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.build,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sin mantenimientos registrados',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: maintenances.length,
              itemBuilder: (context, index) {
                final maintenance = maintenances[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      _getMaintenanceIcon(maintenance.type),
                      color: Colors.blue,
                    ),
                    title: Text(maintenance.type.displayName),
                    subtitle: Text(
                      '${_formatDate(maintenance.date)} • ${maintenance.km} km',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Editar'),
                          onTap: () => _editMaintenance(maintenance),
                        ),
                        PopupMenuItem(
                          child: const Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                          onTap: () => _deleteMaintenance(maintenance),
                        ),
                      ],
                      child: Text(
                        '\$${maintenance.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  IconData _getMaintenanceIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oil:
        return Icons.opacity;
      case MaintenanceType.filter:
        return Icons.filter_alt;
      case MaintenanceType.tires:
        return Icons.tire_repair;
      case MaintenanceType.inspection:
        return Icons.checklist;
      case MaintenanceType.brakes:
        return Icons.stop_circle;
      case MaintenanceType.battery:
        return Icons.battery_full;
      case MaintenanceType.transmission:
        return Icons.settings;
      case MaintenanceType.suspension:
        return Icons.auto_fix_high;
      case MaintenanceType.electrical:
        return Icons.electrical_services;
      case MaintenanceType.bodywork:
        return Icons.handyman;
      case MaintenanceType.other:
        return Icons.build;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editVehicle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddVehicleScreen(vehicle: _currentVehicle),
      ),
    ).then((_) {
      setState(() {
        _refreshVehicleData();
      });
    });
  }

  void _refreshVehicleData() async {
    final updated = await _firebaseService.getVehicle(_currentVehicle.id);
    if (updated != null) {
      setState(() {
        _currentVehicle = updated;
      });
    }
  }

  void _addMaintenance() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMaintenanceScreen(
          vehicleId: _currentVehicle.id,
        ),
      ),
    );
  }

  void _editMaintenance(Maintenance maintenance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMaintenanceScreen(
          vehicleId: _currentVehicle.id,
          maintenance: maintenance,
        ),
      ),
    );
  }

  void _deleteMaintenance(Maintenance maintenance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mantenimiento'),
        content: const Text('¿Estás seguro de que quieres eliminar este mantenimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _firebaseService.deleteMaintenance(maintenance.id).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mantenimiento eliminado')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              });
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceHistoryScreen(
          vehicleId: _currentVehicle.id,
          vehicleName: '${_currentVehicle.brand} ${_currentVehicle.model}',
        ),
      ),
    );
  }

  void _changeDriver() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) return;

    final drivers = await _firebaseService.getUserDrivers(userId);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Conductor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Sin conductor'),
                  onTap: () {
                    _updateDriver(null);
                    Navigator.pop(context);
                  },
                ),
                ...drivers.map((driver) {
                  return ListTile(
                    title: Text(driver.name),
                    subtitle: Text(driver.phone ?? 'Sin teléfono'),
                    onTap: () {
                      _updateDriver(driver.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DriversListScreen(),
                  ),
                );
              },
              child: const Text('Agregar Conductor'),
            ),
          ],
        ),
      );
    }
  }

  void _updateDriver(String? driverId) async {
    try {
      final updatedVehicle = _currentVehicle.copyWith(
        primaryDriverId: driverId,
      );

      await _firebaseService.updateVehicle(updatedVehicle);
      setState(() {
        _currentVehicle = updatedVehicle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conductor asignado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
