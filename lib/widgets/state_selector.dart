import 'package:flutter/material.dart';
import '../utils/us_states.dart';

class StateSelector extends StatelessWidget {
  final String? selectedState;
  final ValueChanged<String> onChanged;

  const StateSelector({
    super.key,
    required this.selectedState,
    required this.onChanged,
  });

  void _showStatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _StatePickerSheet(
        selectedState: selectedState,
        onSelected: (state) {
          onChanged(state);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedState != null && usStates.containsKey(selectedState);

    return GestureDetector(
      onTap: () => _showStatePicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'State',
          prefixIcon: const Icon(Icons.location_on),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(
          hasSelection
              ? '$selectedState - ${usStates[selectedState]}'
              : 'Select your state',
          style: TextStyle(
            fontSize: 16,
            color: hasSelection ? Colors.black87 : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

class _StatePickerSheet extends StatefulWidget {
  final String? selectedState;
  final ValueChanged<String> onSelected;

  const _StatePickerSheet({
    required this.selectedState,
    required this.onSelected,
  });

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    // Scroll to selected state after build
    if (widget.selectedState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    final entries = usStates.entries.toList();
    final index = entries.indexWhere((e) => e.key == widget.selectedState);
    if (index >= 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        index * 52.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<MapEntry<String, String>> get _filteredStates {
    if (_filter.isEmpty) return usStates.entries.toList();
    return usStates.entries.where((entry) =>
        entry.key.toLowerCase().contains(_filter) ||
        entry.value.toLowerCase().contains(_filter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final states = _filteredStates;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search states...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() => _filter = value.toLowerCase()),
              ),
            ),
            // State list
            Expanded(
              child: ListView.builder(
                controller: _filter.isEmpty ? _scrollController : scrollController,
                itemCount: states.length,
                itemExtent: 52,
                itemBuilder: (context, index) {
                  final entry = states[index];
                  final isSelected = entry.key == widget.selectedState;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    title: Text(
                      '${entry.key} - ${entry.value}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue[800] : null,
                      ),
                    ),
                    onTap: () => widget.onSelected(entry.key),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
