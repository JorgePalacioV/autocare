import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';
import 'add_driver_screen.dart';
import 'driver_detail_screen.dart';

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({Key? key}) : super(key: key);

  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
  final _firebaseService = FirebaseService();
  late Future<List<Driver>> _driversFuture;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    final userId = _firebaseService.currentUserId;
    if (userId != null) {
      _driversFuture = _firebaseService.getUserDrivers(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductores'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Driver>>(
        future: _driversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final drivers = snapshot.data ?? [];

          if (drivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Sin conductores registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addDriver,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Conductor'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Conductores (${drivers.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...drivers.map((driver) => _buildDriverCard(driver)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addDriver,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Conductor'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return GestureDetector(
      onTap: () => _editDriver(driver),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (driver.phone != null)
                    Text(
                      driver.phone!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (driver.licenseNumber != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Licencia: ${driver.licenseNumber}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        if (driver.isLicenseExpired)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(13),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.withAlpha(100)),
                            ),
                            child: const Text(
                              'Vencida',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _addDriver() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddDriverScreen()))
        .then((_) {
      setState(() => _loadDrivers());
    });
  }

  void _editDriver(Driver driver) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => DriverDetailScreen(driver: driver),
          ),
        )
        .then((_) {
      setState(() => _loadDrivers());
    });
  }
}
