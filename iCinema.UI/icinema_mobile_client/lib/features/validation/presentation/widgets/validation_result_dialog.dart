import 'package:flutter/material.dart';
import '../../data/models/validation_result.dart';

class ValidationResultDialog extends StatelessWidget {
  final ValidationResult result;
  final VoidCallback onClose;
  final VoidCallback onScanAnother;

  const ValidationResultDialog({
    required this.result,
    required this.onClose,
    required this.onScanAnother,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (result.status) {
      case ValidationStatus.valid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Validna';
        break;
      case ValidationStatus.used:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Iskorištena';
        break;
      case ValidationStatus.expired:
        statusColor = Colors.red;
        statusIcon = Icons.event_busy;
        statusText = 'Nevažeća';
        break;
      case ValidationStatus.invalid:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Nevažeća';
        break;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 64,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 24),

          // Status Text
          Text(
            statusText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            result.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          // Ticket Info
          if (result.ticketInfo != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.movie,
                    'Film',
                    result.ticketInfo!.movieTitle,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    'Kino',
                    '${result.ticketInfo!.cinemaName} - ${result.ticketInfo!.hallName}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.event_seat,
                    'Sjedište',
                    result.ticketInfo!.seatNumber,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time,
                    'Vrijeme',
                    _formatDateTime(result.ticketInfo!.startTime),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Cijena',
                    '${result.ticketInfo!.price.toStringAsFixed(2)} KM',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Zatvori'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onScanAnother,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Validiraj novo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
