import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/logger.dart';
import '../models/models.dart';
import 'vehicles/vehicles_list_screen.dart';
import 'vehicles/add_vehicle_screen.dart';
import 'profile_screen.dart';
import 'maintenance/maintenance_schedule_screen.dart';
import 'reports/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firebaseService = FirebaseService();
  AppUser? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _firebaseService.currentUserId;
      if (userId != null) {
        final user = await _firebaseService.getUserData(userId);
        setState(() => _userData = user);
        Logger.success('Datos de usuario cargados', tag: '[HomeScreen]');
      }
    } catch (e) {
      Logger.error('Error cargando datos: $e', tag: '[HomeScreen]');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firebaseService.signOut();
                Logger.success('Sesión cerrada', tag: '[HomeScreen]');
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                Logger.error('Error logout: $e', tag: '[HomeScreen]');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('AutoCare')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userId = _firebaseService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCare'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _userData?.displayName ?? 'Usuario',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A73E8),
                      const Color(0xFF1A73E8).withAlpha(200),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${_userData?.displayName}! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dashboard de Mantenimiento',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Resumen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (userId != null)
                FutureBuilder<Map<String, dynamic>>(
                  future: _firebaseService.getDashboardStats(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final stats = snapshot.data ?? {};
                    final totalVehicles = stats['totalVehicles'] as int? ?? 0;
                    final totalMaintenances = stats['totalMaintenances'] as int? ?? 0;
                    final totalCost = stats['totalCost'] as double? ?? 0.0;
                    final averageCost = stats['averageCostPerMaintenance'] as double? ?? 0.0;
                    final daysLastMaintenance = stats['daysLastMaintenance'] as int?;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.directions_car,
                                label: 'Vehículos',
                                value: '$totalVehicles',
                                onTap: () => _navigateToVehicles(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.build_circle_outlined,
                                label: 'Mantenimientos',
                                value: '$totalMaintenances',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.attach_money,
                                label: 'Gasto Total',
                                value: '\$${totalCost.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.trending_down,
                                label: 'Promedio',
                                value: '\$${averageCost.toStringAsFixed(0)}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.calendar_today,
                                label: 'Último Mtto',
                                value: daysLastMaintenance != null ? '${daysLastMaintenance}d' : '-',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
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
                                    const Icon(Icons.info, size: 20, color: Color(0xFF1A73E8)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${(totalMaintenances / (totalVehicles > 0 ? totalVehicles : 1)).toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Promedio/Auto',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 32),
              Text(
                'Acciones Rápidas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _navigateToVehicles,
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Ver Vehículos'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _addVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Vehículo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _navigateToSchedules,
                  icon: const Icon(Icons.alarm),
                  label: const Text('Configurar Alertas'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _navigateToReports,
                  icon: const Icon(Icons.assessment),
                  label: const Text('Generar Reportes'),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _userData != null ? _editProfile : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1A73E8).withAlpha(50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 20),
                              const SizedBox(width: 12),
                              const Text(
                                'Información de Perfil',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Icon(Icons.edit, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Nombre', _userData?.name ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Email', _userData?.email ?? 'N/A'),
                      if (_userData?.phone != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Teléfono', _userData!.phone!),
                      ],
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Miembro desde',
                        '${_userData?.createdAt.day}/${_userData?.createdAt.month}/${_userData?.createdAt.year}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF5F6368),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF202124),
          ),
        ),
      ],
    );
  }

  void _navigateToVehicles() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VehiclesListScreen(),
      ),
    );
  }

  void _addVehicle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    );
  }

  void _navigateToSchedules() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MaintenanceScheduleScreen(),
      ),
    );
  }

  void _navigateToReports() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportsScreen(),
      ),
    );
  }

  void _editProfile() {
    if (_userData != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(user: _userData!),
        ),
      ).then((_) {
        _loadUserData();
      });
    }
  }
}
