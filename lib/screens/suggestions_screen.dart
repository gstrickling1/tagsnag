import 'package:flutter/material.dart';
import '../widgets/suggestion_grid.dart';
import '../services/api_service.dart';
import 'chat_refine_screen.dart';
import 'results_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  final String interest;
  final List<String> initialSuggestions;
  final String state;
  final String vehicleType;

  const SuggestionsScreen({
    super.key,
    required this.interest,
    required this.initialSuggestions,
    this.state = 'GA',
    this.vehicleType = 'car',
  });

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  late List<String> _suggestions;
  final Map<String, String> _checkedStatuses = {};
  String? _checkingPlate;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _suggestions = List.from(widget.initialSuggestions);
  }

  Future<void> _checkPlate(String plate) async {
    if (_checkingPlate != null) return;

    setState(() => _checkingPlate = plate);

    try {
      final result = await ApiService.checkPlate(plate, state: widget.state, vehicleType: widget.vehicleType);
      if (!mounted) return;

      setState(() {
        _checkedStatuses[plate] = result.status;
        _checkingPlate = null;
      });

      // Also navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(result: result, state: widget.state)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingPlate = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check $plate'), backgroundColor: Colors.red[700]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Plate Ideas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Interest label
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ideas for: "${widget.interest}"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap any plate to check availability',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),

                // Loading indicator for checking
                if (_checkingPlate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text('Checking $_checkingPlate...'),
                      ],
                    ),
                  ),

                // Suggestion grid
                if (_suggestions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No suggestions were generated. Try a different interest.'),
                    ),
                  )
                else
                  SuggestionGrid(
                    suggestions: _suggestions,
                    checkedStatuses: _checkedStatuses,
                    onPlateTap: _checkPlate,
                  ),

                const SizedBox(height: 16),

                // More Ideas button
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _loadingMore
                        ? null
                        : () async {
                            setState(() => _loadingMore = true);
                            try {
                              final more = await ApiService.getSuggestions(
                                widget.interest,
                                state: widget.state,
                                vehicleType: widget.vehicleType,
                              );
                              if (!mounted) return;
                              setState(() {
                                for (final s in more) {
                                  if (!_suggestions.contains(s)) {
                                    _suggestions.add(s);
                                  }
                                }
                                _loadingMore = false;
                              });
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _loadingMore = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Could not load more ideas'),
                                  backgroundColor: Colors.red[700],
                                ),
                              );
                            }
                          },
                    icon: _loadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_loadingMore ? 'Loading...' : 'More Ideas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Refine with AI Chat button
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRefineScreen(
                            interest: widget.interest,
                            existingSuggestions: _suggestions,
                            state: widget.state,
                            vehicleType: widget.vehicleType,
                          ),
                        ),
                      ).then((newSuggestions) {
                        if (newSuggestions != null && newSuggestions is List<String>) {
                          setState(() {
                            for (final s in newSuggestions) {
                              if (!_suggestions.contains(s)) {
                                _suggestions.add(s);
                              }
                            }
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Refine with AI Chat'),
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
        ),
      ),
    );
  }
}
