import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/us_states.dart';

class ClaimGuideScreen extends StatefulWidget {
  final String plate;
  final String state;

  const ClaimGuideScreen({
    super.key,
    required this.plate,
    required this.state,
  });

  @override
  State<ClaimGuideScreen> createState() => _ClaimGuideScreenState();
}

class _ClaimGuideScreenState extends State<ClaimGuideScreen> {
  Map<String, dynamic>? _claimInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClaimInfo();
  }

  Future<void> _loadClaimInfo() async {
    try {
      final info = await ApiService.getClaimInfo(widget.state);
      if (!mounted) return;
      setState(() {
        _claimInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateName = usStates[widget.state] ?? widget.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Claim Your Plate'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Plate display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              stateName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.plate,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                                color: Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_claimInfo != null) ...[
                        // Fee info
                        _buildInfoCard(
                          icon: Icons.payments,
                          title: 'Fees',
                          children: [
                            _buildInfoRow('Initial fee', _claimInfo!['fee_initial'] ?? 'Contact DMV'),
                            _buildInfoRow('Annual renewal', _claimInfo!['fee_renewal'] ?? 'Contact DMV'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // How to apply
                        _buildInfoCard(
                          icon: Icons.assignment,
                          title: 'How to Apply',
                          children: [
                            _buildInfoRow('Method', _claimInfo!['apply_method'] ?? 'Contact DMV'),
                            if (_claimInfo!['form'] != null && _claimInfo!['form'].toString().isNotEmpty)
                              _buildInfoRow('Form', _claimInfo!['form']),
                            _buildInfoRow('Processing time', _claimInfo!['processing_time'] ?? '4-6 weeks'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // What to bring
                        _buildInfoCard(
                          icon: Icons.checklist,
                          title: 'What to Bring',
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _claimInfo!['what_to_bring'] ?? 'Current registration, valid ID, payment',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Step by step
                        _buildInfoCard(
                          icon: Icons.format_list_numbered,
                          title: 'Steps',
                          children: [
                            if (_claimInfo!['steps'] != null)
                              ...(_claimInfo!['steps'] as List).asMap().entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[700],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value.toString(),
                                          style: const TextStyle(fontSize: 14, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Apply now button
                        if (_claimInfo!['apply_url'] != null)
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: widget.plate));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${widget.plate} copied — paste it on the DMV site'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                                final url = Uri.parse(_claimInfo!['apply_url']);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: Text('Apply at $stateName DMV'),
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
                      ] else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('Could not load claim info. Check your connection.'),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[700], size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
