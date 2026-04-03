import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/plate_result.dart';
import '../models/plate_style.dart';
import '../utils/us_states.dart';
import 'claim_guide_screen.dart';

class ResultsScreen extends StatelessWidget {
  final PlateResult result;
  final String state;
  final PlateStyle? selectedStyle;

  const ResultsScreen({super.key, required this.result, this.state = 'GA', this.selectedStyle});

  IconData get _statusIcon {
    switch (result.status) {
      case 'not_found':
        return Icons.check_circle;
      case 'assigned':
        return Icons.cancel;
      case 'invalid':
        return Icons.error;
      default:
        return Icons.open_in_new;
    }
  }

  Color get _statusColor {
    switch (result.status) {
      case 'not_found':
        return Colors.green;
      case 'assigned':
        return Colors.red;
      case 'invalid':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String get _statusLabel {
    switch (result.status) {
      case 'not_found':
        return 'Likely Available!';
      case 'assigned':
        return 'Already Taken';
      case 'invalid':
        return 'Invalid Format';
      default:
        return 'Check Availability';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plate display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[800]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        (usStates[state] ?? state).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.plate,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selected plate style
                if (selectedStyle != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedStyle!.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedStyle!.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 18,
                          decoration: BoxDecoration(
                            color: selectedStyle!.primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedStyle!.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selectedStyle!.primaryColor,
                          ),
                        ),
                        if (selectedStyle!.extraFee != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            selectedStyle!.extraFee!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Status icon
                Icon(_statusIcon, size: 72, color: _statusColor),
                const SizedBox(height: 16),

                // Status label
                Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Official check button (when status is unknown)
                if (result.officialCheckUrl.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: result.plate));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${result.plate} copied — paste it on the DMV site'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                        final url = Uri.parse(result.officialCheckUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text('Check on ${usStates[state] ?? state} DMV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The official site will confirm if this plate is available',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                ],

                // "It's Available" button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClaimGuideScreen(
                            plate: result.plate,
                            state: state,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.celebration),
                    label: const Text("It's Available! Help Me Get It"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Mark as Unavailable button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, 'unavailable'),
                    icon: Icon(Icons.close, color: Colors.red[700]),
                    label: Text('Not Available — Try Another',
                        style: TextStyle(color: Colors.red[700])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, 'checked'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Check Another Plate'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
