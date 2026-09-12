import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'add_driver_screen.dart';

class DriverDetailScreen extends StatelessWidget {
  final Driver driver;

  const DriverDetailScreen({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(driver.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AddDriverScreen(driver: driver),
                    ),
                  )
                  .then((_) => Navigator.pop(context));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driver.photoUrl != null && driver.photoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  driver.photoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPhotoPlaceholder('Foto del Conductor');
                  },
                ),
              )
            else
              _buildPhotoPlaceholder('Foto del Conductor'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1A73E8).withAlpha(50),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        driver.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Conductor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Contacto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (driver.phone != null) ...[
              _buildInfoRow('Teléfono', driver.phone!),
              const SizedBox(height: 12),
            ],
            if (driver.email != null) ...[
              _buildInfoRow('Email', driver.email!),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
            Text(
              'Licencia de Conducción',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (driver.licenseNumber != null)
              _buildInfoRow('Número de Licencia', driver.licenseNumber!)
            else
              _buildInfoRow('Número de Licencia', 'No especificado'),
            const SizedBox(height: 12),
            if (driver.licenseExpiry != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: driver.isLicenseExpired
                      ? Colors.red.withAlpha(13)
                      : Colors.green.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: driver.isLicenseExpired
                        ? Colors.red.withAlpha(100)
                        : Colors.green.withAlpha(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vencimiento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${driver.licenseExpiry!.day}/${driver.licenseExpiry!.month}/${driver.licenseExpiry!.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      driver.isLicenseExpired
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: driver.isLicenseExpired ? Colors.red : Colors.green,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ] else
              _buildInfoRow('Vencimiento', 'No especificado'),
            const SizedBox(height: 24),
            Text(
              'Foto de la Licencia',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (driver.licensePhotoUrl != null && driver.licensePhotoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  driver.licensePhotoUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPhotoPlaceholder('Foto de Licencia');
                  },
                ),
              )
            else
              _buildPhotoPlaceholder('Foto de Licencia'),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String label) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label.contains('Licencia') ? Icons.document_scanner : Icons.image_not_supported,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              '$label no disponible',
              style: TextStyle(color: Colors.grey[600]),
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
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF202124),
            ),
          ),
        ),
      ],
    );
  }
}
