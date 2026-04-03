import 'package:flutter/material.dart';
import '../models/plate_style.dart';
import '../widgets/plate_input.dart';
import '../widgets/state_selector.dart';
import '../utils/plate_validator.dart';
import '../services/api_service.dart';
import 'plate_style_picker_screen.dart';
import 'results_screen.dart';
import 'suggestions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _plateController = TextEditingController();
  final _interestController = TextEditingController();
  String? _selectedState;
  String _vehicleType = 'car';
  bool _isCheckingPlate = false;
  bool _isLoadingSuggestions = false;
  // Plate history: list of {plate, status} where status is 'checked', 'unavailable', or 'available'
  final List<Map<String, String>> _plateHistory = [];

  @override
  void dispose() {
    _plateController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _checkPlate() async {
    if (_selectedState == null) {
      _showError('Please select your state first.');
      return;
    }

    final plate = _plateController.text.trim().toUpperCase();
    final validation = PlateValidator.validate(plate, state: _selectedState, vehicleType: _vehicleType);

    if (!validation.isValid) {
      _showError(validation.message);
      return;
    }

    setState(() => _isCheckingPlate = true);

    try {
      // Try to load plate styles for this state
      PlateStyle? pickedStyle;
      try {
        final stylesResponse = await ApiService.getPlateStyles(
          _selectedState!,
          vehicleType: _vehicleType,
        );

        if (!mounted) return;

        if (stylesResponse.supported && stylesResponse.styles.isNotEmpty) {
          // Show plate style picker
          pickedStyle = await Navigator.push<PlateStyle>(
            context,
            MaterialPageRoute(
              builder: (_) => PlateStylePickerScreen(
                plate: plate,
                state: _selectedState!,
                vehicleType: _vehicleType,
                styles: stylesResponse.styles,
              ),
            ),
          );

          if (!mounted || pickedStyle == null) {
            setState(() => _isCheckingPlate = false);
            return;
          }
        }
      } catch (_) {
        // Plate styles endpoint not available — skip style picker
      }

      if (!mounted) return;

      // Check the plate
      final result = await ApiService.checkPlate(plate, state: _selectedState!, vehicleType: _vehicleType);
      if (!mounted) return;
      final outcome = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(
          result: result,
          state: _selectedState!,
          selectedStyle: pickedStyle,
        )),
      );

      if (!mounted) return;
      // Add to history
      final status = outcome == 'unavailable' ? 'unavailable' : 'checked';
      setState(() {
        // Remove if already in history, then add at top
        _plateHistory.removeWhere((h) => h['plate'] == plate);
        _plateHistory.insert(0, {'plate': plate, 'status': status});
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Could not check plate. Is the server running?');
    } finally {
      if (mounted) setState(() => _isCheckingPlate = false);
    }
  }

  Future<void> _getSuggestions() async {
    if (_selectedState == null) {
      _showError('Please select your state first.');
      return;
    }

    final interest = _interestController.text.trim();
    if (interest.isEmpty) {
      _showError('Please enter an area of interest.');
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    try {
      final suggestions = await ApiService.getSuggestions(interest, state: _selectedState!, vehicleType: _vehicleType);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuggestionsScreen(
            interest: interest,
            initialSuggestions: suggestions,
            state: _selectedState!,
            vehicleType: _vehicleType,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not get suggestions. Is the server running?');
    } finally {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Header
                  const Icon(Icons.directions_car, size: 64, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'TagSnag',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Snag Your Perfect Plate',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // State Selector
                  StateSelector(
                    selectedState: _selectedState,
                    onChanged: (state) => setState(() => _selectedState = state),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _vehicleType = 'car'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _vehicleType == 'car' ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _vehicleType == 'car'
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.directions_car, size: 20,
                                      color: _vehicleType == 'car' ? Colors.blue[700] : Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text('Car / Truck',
                                      style: TextStyle(
                                        fontWeight: _vehicleType == 'car' ? FontWeight.w600 : FontWeight.normal,
                                        color: _vehicleType == 'car' ? Colors.blue[700] : Colors.grey[600],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _vehicleType = 'motorcycle'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _vehicleType == 'motorcycle' ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _vehicleType == 'motorcycle'
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.two_wheeler, size: 20,
                                      color: _vehicleType == 'motorcycle' ? Colors.blue[700] : Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text('Motorcycle',
                                      style: TextStyle(
                                        fontWeight: _vehicleType == 'motorcycle' ? FontWeight.w600 : FontWeight.normal,
                                        color: _vehicleType == 'motorcycle' ? Colors.blue[700] : Colors.grey[600],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Check a Plate section
                  _buildSectionCard(
                    title: 'Check a Plate',
                    subtitle: 'See if a specific plate is already taken',
                    child: Column(
                      children: [
                        PlateInput(
                          controller: _plateController,
                          hintText: 'GOJKTS',
                          onSubmit: _checkPlate,
                          maxLength: _selectedState != null && stateRules.containsKey(_selectedState)
                              ? stateRules[_selectedState]!.maxLengthFor(_vehicleType)
                              : 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedState != null && stateRules.containsKey(_selectedState)
                              ? '${stateRules[_selectedState]!.notes}${_vehicleType == 'motorcycle' ? ' Motorcycle: max ${stateRules[_selectedState]!.motorcycleMaxLength} characters.' : ''}'
                              : 'Select a state to see plate rules',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isCheckingPlate ? null : _checkPlate,
                            icon: _isCheckingPlate
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            label: Text(_isCheckingPlate ? 'Checking...' : 'Check Availability'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Plate history
                  if (_plateHistory.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
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
                              Icon(Icons.history, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text('Plates You\'ve Checked',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  )),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _plateHistory.clear()),
                                child: Text('Clear',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _plateHistory.map((entry) {
                              final isUnavailable = entry['status'] == 'unavailable';
                              return GestureDetector(
                                onTap: () {
                                  // Toggle unavailable status on tap
                                  setState(() {
                                    entry['status'] = isUnavailable ? 'checked' : 'unavailable';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isUnavailable ? Colors.red[50] : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isUnavailable ? Colors.red[200]! : Colors.blue[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isUnavailable)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Icon(Icons.close, size: 16, color: Colors.red[700]),
                                        ),
                                      Text(
                                        entry['plate']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          color: isUnavailable ? Colors.red[400] : Colors.blue[800],
                                          decoration: isUnavailable
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: Colors.red[700],
                                          decorationThickness: 2.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap a plate to toggle unavailable',
                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AI Suggestions section
                  _buildSectionCard(
                    title: 'Get AI Plate Ideas',
                    subtitle: 'Tell us your interest and we\'ll suggest plates',
                    child: Column(
                      children: [
                        TextField(
                          controller: _interestController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'e.g. Georgia Bulldogs, fishing, my church...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onSubmitted: (_) => _getSuggestions(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoadingSuggestions ? null : _getSuggestions,
                            icon: _isLoadingSuggestions
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isLoadingSuggestions ? 'Generating...' : 'Suggest Plates'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
