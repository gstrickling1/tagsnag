import 'package:flutter/material.dart';

class PlateChip extends StatelessWidget {
  final String plate;
  final VoidCallback? onTap;
  final String? status; // null = not checked, "not_found", "assigned", "unknown"

  const PlateChip({
    super.key,
    required this.plate,
    this.onTap,
    this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case 'not_found':
        return Colors.green[50]!;
      case 'assigned':
        return Colors.red[50]!;
      case 'unknown':
        return Colors.orange[50]!;
      default:
        return Colors.blue[50]!;
    }
  }

  Color get _borderColor {
    switch (status) {
      case 'not_found':
        return Colors.green;
      case 'assigned':
        return Colors.red;
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData? get _icon {
    switch (status) {
      case 'not_found':
        return Icons.check_circle;
      case 'assigned':
        return Icons.cancel;
      case 'unknown':
        return Icons.help;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              plate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: _borderColor,
              ),
            ),
            if (_icon != null) ...[
              const SizedBox(width: 6),
              Icon(_icon, size: 18, color: _borderColor),
            ],
          ],
        ),
      ),
    );
  }
}
