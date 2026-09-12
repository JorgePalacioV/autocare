import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleName;

  const MaintenanceHistoryScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
  }) : super(key: key);

  @override
  State<MaintenanceHistoryScreen> createState() => _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  final _firebaseService = FirebaseService();
  late Future<List<Maintenance>> _maintenancesFuture;
  String _searchQuery = '';
  MaintenanceType? _selectedType;
  List<Maintenance> _filteredMaintenances = [];

  @override
  void initState() {
    super.initState();
    _maintenancesFuture = _firebaseService.getVehicleMaintenances(widget.vehicleId);
  }

  List<Maintenance> _applyFilters(List<Maintenance> maintenances) {
    var filtered = maintenances;

    if (_selectedType != null) {
      filtered = filtered.where((m) => m.type == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final query = _searchQuery.toLowerCase();
        return m.type.displayName.toLowerCase().contains(query) ||
            (m.workshop?.toLowerCase().contains(query) ?? false) ||
            (m.notes?.toLowerCase().contains(query) ?? false) ||
            m.cost.toString().contains(query) ||
            m.km.toString().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Map<String, dynamic> _calculateStats(List<Maintenance> maintenances) {
    if (maintenances.isEmpty) {
      return {
        'total': 0,
        'totalCost': 0.0,
        'averageCost': 0.0,
        'mostExpensive': null,
        'cheapest': null,
      };
    }

    double totalCost = maintenances.fold(0.0, (sum, m) => sum + m.cost);
    Maintenance mostExpensive =
        maintenances.reduce((a, b) => a.cost > b.cost ? a : b);
    Maintenance cheapest =
        maintenances.reduce((a, b) => a.cost < b.cost ? a : b);

    return {
      'total': maintenances.length,
      'totalCost': totalCost,
      'averageCost': totalCost / maintenances.length,
      'mostExpensive': mostExpensive,
      'cheapest': cheapest,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial: ${widget.vehicleName}'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Maintenance>>(
        future: _maintenancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final maintenances = snapshot.data ?? [];
          _filteredMaintenances = _applyFilters(maintenances);
          final stats = _calculateStats(_filteredMaintenances);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(stats),
                const SizedBox(height: 24),
                _buildSearchAndFilters(maintenances),
                const SizedBox(height: 24),
                if (_filteredMaintenances.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Sin mantenimientos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial (${_filteredMaintenances.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ..._filteredMaintenances.map((m) => _buildMaintenanceCard(m)),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8).withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A73E8).withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.build,
                  label: 'Total',
                  value: '${stats['total']}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.attach_money,
                  label: 'Gasto Total',
                  value: '\$${(stats['totalCost'] as double).toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_down,
                  label: 'Promedio',
                  value: '\$${(stats['averageCost'] as double).toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_upward,
                  label: 'Mayor',
                  value: stats['mostExpensive'] != null
                      ? '\$${(stats['mostExpensive'] as Maintenance).cost.toStringAsFixed(0)}'
                      : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1A73E8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(List<Maintenance> maintenances) {
    final types = maintenances.map((m) => m.type).toSet().toList();
    types.sort((a, b) => a.displayName.compareTo(b.displayName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por tipo, taller, notas...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 16),
        if (types.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por tipo:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedType == null,
                    onSelected: (_) {
                      setState(() => _selectedType = null);
                    },
                  ),
                  ...types.map((type) {
                    return FilterChip(
                      label: Text(type.shortName),
                      selected: _selectedType == type,
                      onSelected: (_) {
                        setState(() => _selectedType = _selectedType == type ? null : type);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMaintenanceCard(Maintenance maintenance) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maintenance.type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maintenance.formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                maintenance.formattedCost,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.speed, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${maintenance.km} km',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              if (maintenance.workshop != null) ...[
                Icon(Icons.place, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    maintenance.workshop!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (maintenance.notes != null && maintenance.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              maintenance.notes!,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
