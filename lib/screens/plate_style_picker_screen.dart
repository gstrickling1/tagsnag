import 'package:flutter/material.dart';
import '../models/plate_style.dart';
import '../utils/us_states.dart';

class PlateStylePickerScreen extends StatelessWidget {
  final String plate;
  final String state;
  final String vehicleType;
  final List<PlateStyle> styles;

  const PlateStylePickerScreen({
    super.key,
    required this.plate,
    required this.state,
    required this.vehicleType,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    final stateName = usStates[state] ?? state;

    // Group by category
    final categories = <String, List<PlateStyle>>{};
    for (final style in styles) {
      categories.putIfAbsent(style.category, () => []).add(style);
    }

    // Order: standard first, then alphabetical
    final categoryOrder = categories.keys.toList()
      ..sort((a, b) {
        if (a == 'standard') return -1;
        if (b == 'standard') return 1;
        return a.compareTo(b);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('$stateName Plate Styles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plate text display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Checking: $plate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a plate style, then we\'ll check availability',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),

                for (final category in categoryOrder) ...[
                  _buildCategoryHeader(category),
                  const SizedBox(height: 8),
                  _buildStyleGrid(context, categories[category]!),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    final label = switch (category) {
      'standard' => 'Standard Plates',
      'specialty' => 'Specialty Plates',
      'collegiate' => 'Collegiate',
      'sports' => 'Sports Teams',
      'military' => 'Military & Veteran',
      _ => category[0].toUpperCase() + category.substring(1),
    };

    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF37474F),
      ),
    );
  }

  Widget _buildStyleGrid(BuildContext context, List<PlateStyle> styles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        final tooLong = plate.length > style.maxLength;

        return GestureDetector(
          onTap: tooLong
              ? null
              : () => Navigator.pop(context, style),
          child: Opacity(
            opacity: tooLong ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Column(
                  children: [
                    // Plate preview area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              style.primaryColor,
                              style.primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (usStates[state] ?? state).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: style.secondaryColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plate,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: style.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Label area
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      child: Column(
                        children: [
                          Text(
                            style.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (tooLong)
                            Text(
                              'Max ${style.maxLength} chars',
                              style: TextStyle(fontSize: 9, color: Colors.red[700]),
                            )
                          else if (style.extraFee != null)
                            Text(
                              style.extraFee!,
                              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
