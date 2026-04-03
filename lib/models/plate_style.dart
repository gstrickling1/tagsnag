import 'dart:ui';

class PlateStyle {
  final String id;
  final String name;
  final String category;
  final bool supportsVanity;
  final int maxLength;
  final int? motorcycleMaxLength;
  final String? extraFee;
  final List<String> colors;

  const PlateStyle({
    required this.id,
    required this.name,
    required this.category,
    required this.supportsVanity,
    required this.maxLength,
    this.motorcycleMaxLength,
    this.extraFee,
    this.colors = const [],
  });

  factory PlateStyle.fromJson(Map<String, dynamic> json) {
    return PlateStyle(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      supportsVanity: json['supports_vanity'] as bool,
      maxLength: json['max_length'] as int,
      motorcycleMaxLength: json['motorcycle_max_length'] as int?,
      extraFee: json['extra_fee'] as String?,
      colors: (json['colors'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Color get primaryColor {
    if (colors.isNotEmpty) {
      return _parseColor(colors[0]);
    }
    return const Color(0xFF1565C0);
  }

  Color get secondaryColor {
    if (colors.length > 1) {
      return _parseColor(colors[1]);
    }
    return const Color(0xFFFFFFFF);
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class PlateStylesResponse {
  final bool supported;
  final List<PlateStyle> styles;

  const PlateStylesResponse({required this.supported, required this.styles});

  factory PlateStylesResponse.fromJson(Map<String, dynamic> json) {
    return PlateStylesResponse(
      supported: json['supported'] as bool,
      styles: (json['styles'] as List<dynamic>)
          .map((s) => PlateStyle.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
