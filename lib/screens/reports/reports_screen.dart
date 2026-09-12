import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../services/logger.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firebaseService = FirebaseService();
  late Future<List<Vehicle>> _vehiclesFuture;

  Vehicle? _selectedVehicle;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final userId = _firebaseService.currentUserId;
    if (userId != null) {
      _vehiclesFuture = _firebaseService.getUserVehicles(userId);
    }
    _startDate = DateTime.now().subtract(const Duration(days: 90));
    _endDate = DateTime.now();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _generatePDF() async {
    if (_selectedVehicle == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final maintenances = await _firebaseService.getVehicleMaintenances(_selectedVehicle!.id);

      final filtered = maintenances
          .where((m) => m.date.isAfter(_startDate!) && m.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();

      filtered.sort((a, b) => b.date.compareTo(a.date));

      final pdf = pw.Document();
      final totalCost = filtered.fold<double>(0, (sum, m) => sum + m.cost);
      final avgCost = filtered.isNotEmpty ? totalCost / filtered.length : 0;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE MANTENIMIENTO',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '${_selectedVehicle!.brand} ${_selectedVehicle!.model}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Placa: ${_selectedVehicle!.plate}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Período: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'RESUMEN',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total de Mantenimientos:', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('${filtered.length}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Gasto Total:', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('\$${totalCost.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Promedio:', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('\$${avgCost.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                if (filtered.isNotEmpty) ...[
                  pw.Text(
                    'HISTORIAL DE MANTENIMIENTOS',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.TableHelper.fromTextArray(
                    headers: ['Fecha', 'Tipo', 'Km', 'Costo'],
                    data: filtered.map((m) => [
                      '${m.date.day}/${m.date.month}/${m.date.year}',
                      m.type.shortName,
                      '${m.km}',
                      '\$${m.cost.toStringAsFixed(2)}',
                    ]).toList(),
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ] else
                  pw.Text(
                    'Sin mantenimientos en este período',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF999999)),
                  ),
                pw.Spacer(),
                pw.Text(
                  'Generado por AutoCare - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
      );

      Logger.success('PDF generado exitosamente');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte generado exitosamente')),
        );
      }
    } catch (e) {
      Logger.error('Error generando PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes vehículos',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generar Reporte',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Selecciona el Vehículo',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<Vehicle>(
                    isExpanded: true,
                    value: _selectedVehicle,
                    hint: const Text('Selecciona un vehículo'),
                    underline: const SizedBox(),
                    items: vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text('${vehicle.brand} ${vehicle.model} (${vehicle.plate})'),
                      );
                    }).toList(),
                    onChanged: (vehicle) {
                      setState(() => _selectedVehicle = vehicle);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Período de Tiempo',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Desde',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _startDate != null
                                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                    : 'Seleccionar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectEndDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasta',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endDate != null
                                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Seleccionar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePDF,
                    icon: const Icon(Icons.file_download),
                    label: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generar Reporte PDF'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
