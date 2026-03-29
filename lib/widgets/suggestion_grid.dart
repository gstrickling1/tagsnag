import 'package:flutter/material.dart';
import 'plate_chip.dart';

class SuggestionGrid extends StatelessWidget {
  final List<String> suggestions;
  final Map<String, String> checkedStatuses; // plate -> status
  final Function(String plate) onPlateTap;

  const SuggestionGrid({
    super.key,
    required this.suggestions,
    required this.checkedStatuses,
    required this.onPlateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: suggestions.map((plate) {
        return PlateChip(
          plate: plate,
          status: checkedStatuses[plate],
          onTap: () => onPlateTap(plate),
        );
      }).toList(),
    );
  }
}
