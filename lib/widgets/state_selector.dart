import 'package:flutter/material.dart';
import '../utils/us_states.dart';

class StateSelector extends StatelessWidget {
  final String selectedState;
  final ValueChanged<String> onChanged;

  const StateSelector({
    super.key,
    required this.selectedState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<MapEntry<String, String>>(
      initialValue: TextEditingValue(
        text: '$selectedState - ${usStates[selectedState] ?? ''}',
      ),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return usStates.entries;
        return usStates.entries.where((entry) =>
            entry.key.toLowerCase().contains(query) ||
            entry.value.toLowerCase().contains(query));
      },
      displayStringForOption: (entry) => '${entry.key} - ${entry.value}',
      onSelected: (entry) => onChanged(entry.key),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'State',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onTap: () {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final entry = options.elementAt(index);
                  final isSelected = entry.key == selectedState;
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    title: Text(
                      '${entry.key} - ${entry.value}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => onSelected(entry),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
