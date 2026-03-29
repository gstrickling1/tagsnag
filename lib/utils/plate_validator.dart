class PlateValidationResult {
  final bool isValid;
  final String message;

  const PlateValidationResult({required this.isValid, required this.message});
}

class PlateValidator {
  static const int maxLength = 7;
  static final RegExp _pattern = RegExp(r'^[A-Z0-9 ]{1,7}$');

  static PlateValidationResult validate(String plate) {
    final upper = plate.toUpperCase().trim();

    if (upper.isEmpty) {
      return const PlateValidationResult(
        isValid: false,
        message: 'Plate cannot be empty.',
      );
    }

    if (upper.length > maxLength) {
      return PlateValidationResult(
        isValid: false,
        message: 'Too long: max $maxLength characters (got ${upper.length}).',
      );
    }

    if (!_pattern.hasMatch(upper)) {
      return const PlateValidationResult(
        isValid: false,
        message: 'Only letters A-Z, numbers 0-9, and spaces allowed.',
      );
    }

    return const PlateValidationResult(
      isValid: true,
      message: 'Valid plate format.',
    );
  }
}
