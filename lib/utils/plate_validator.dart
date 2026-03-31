class PlateValidationResult {
  final bool isValid;
  final String message;

  const PlateValidationResult({required this.isValid, required this.message});
}

class StateRule {
  final int maxLength;
  final int motorcycleMaxLength;
  final int minLength;
  final String allowedChars;
  final String notes;

  const StateRule({
    required this.maxLength,
    required this.motorcycleMaxLength,
    this.minLength = 2,
    required this.allowedChars,
    required this.notes,
  });

  int maxLengthFor(String vehicleType) =>
      vehicleType == 'motorcycle' ? motorcycleMaxLength : maxLength;
}

// State rules matching backend — researched from PlateMonitor.com
final Map<String, StateRule> stateRules = {
  'AL': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Alabama: 2-7 characters.'),
  'AK': const StateRule(maxLength: 6, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Alaska: 2-6 characters.'),
  'AZ': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Arizona: 2-7 characters.'),
  'AR': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Arkansas: 2-7 characters.'),
  'CA': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'California: 2-7 characters.'),
  'CO': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Colorado: 2-7 characters.'),
  'CT': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Connecticut: 2-7 characters.'),
  'DE': const StateRule(maxLength: 7, motorcycleMaxLength: 5, minLength: 1, allowedChars: 'Letters, numbers, and spaces', notes: 'Delaware: 1-7 characters.'),
  'FL': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, spaces, and hyphens', notes: 'Florida: 2-7 characters.'),
  'GA': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters, numbers, and spaces', notes: 'Georgia: 1-7 characters.'),
  'HI': const StateRule(maxLength: 6, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, spaces, and one hyphen', notes: 'Hawaii: 2-6 characters.'),
  'ID': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters (except O), numbers, and spaces', notes: 'Idaho: 1-7 characters.'),
  'IL': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters, numbers, and spaces', notes: 'Illinois: 1-7 characters.'),
  'IN': const StateRule(maxLength: 8, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Indiana: 2-8 characters.'),
  'IA': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Iowa: 2-7 characters.'),
  'KS': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Kansas: 2-7 characters.'),
  'KY': const StateRule(maxLength: 6, motorcycleMaxLength: 5, allowedChars: 'Letters (except I, Q, U), numbers, and spaces', notes: 'Kentucky: 2-6 characters.'),
  'LA': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Louisiana: 2-7 characters.'),
  'ME': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, spaces, dash, and ampersand', notes: 'Maine: 2-7 characters. Must begin with a letter.'),
  'MD': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Maryland: 2-7 characters.'),
  'MA': const StateRule(maxLength: 6, motorcycleMaxLength: 5, allowedChars: 'Letters required first, numbers only at end', notes: 'Massachusetts: 2-6 characters.'),
  'MI': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Michigan: 2-7 characters.'),
  'MN': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Minnesota: 2-7 characters.'),
  'MS': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Mississippi: 2-7 characters. One space max.'),
  'MO': const StateRule(maxLength: 6, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, space, dash, or apostrophe', notes: 'Missouri: 2-6 characters.'),
  'MT': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Montana: 2-7 characters.'),
  'NE': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and one space', notes: 'Nebraska: 2-7 characters.'),
  'NV': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters, numbers, and spaces', notes: 'Nevada: 1-7 characters.'),
  'NH': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, spaces, plus, minus, ampersand', notes: 'New Hampshire: 2-7 characters.'),
  'NJ': const StateRule(maxLength: 7, motorcycleMaxLength: 5, minLength: 3, allowedChars: 'Letters and numbers only', notes: 'New Jersey: 3-7 characters. No spaces.'),
  'NM': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters and numbers only', notes: 'New Mexico: 1-7 characters.'),
  'NY': const StateRule(maxLength: 8, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'New York: 2-8 characters.'),
  'NC': const StateRule(maxLength: 8, motorcycleMaxLength: 7, allowedChars: 'Letters, numbers, and spaces', notes: 'North Carolina: 2-8 characters.'),
  'ND': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'North Dakota: 2-7 characters.'),
  'OH': const StateRule(maxLength: 7, motorcycleMaxLength: 5, minLength: 4, allowedChars: 'Letters, numbers, and spaces', notes: 'Ohio: 4-7 characters.'),
  'OK': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 4, allowedChars: 'Letters, numbers, spaces, and hyphens', notes: 'Oklahoma: 4-7 characters.'),
  'OR': const StateRule(maxLength: 6, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Oregon: 2-6 characters.'),
  'PA': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, spaces, and hyphens', notes: 'Pennsylvania: 2-7 characters.'),
  'RI': const StateRule(maxLength: 6, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Rhode Island: 2-6 characters.'),
  'SC': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, spaces, and ampersand', notes: 'South Carolina: 2-7 characters.'),
  'SD': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters and numbers only', notes: 'South Dakota: 2-7 characters.'),
  'TN': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'Tennessee: 2-7 characters.'),
  'TX': const StateRule(maxLength: 7, motorcycleMaxLength: 4, allowedChars: 'Letters, numbers, and spaces', notes: 'Texas: 2-7 characters.'),
  'UT': const StateRule(maxLength: 7, motorcycleMaxLength: 4, allowedChars: 'Letters (except O), numbers, and spaces', notes: 'Utah: 2-7 characters.'),
  'VT': const StateRule(maxLength: 7, motorcycleMaxLength: 6, allowedChars: 'Letters and numbers only', notes: 'Vermont: 2-7 characters. Max 2 numbers.'),
  'VA': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters, numbers, spaces, and hyphens', notes: 'Virginia: 1-7 characters.'),
  'WA': const StateRule(maxLength: 7, motorcycleMaxLength: 6, minLength: 1, allowedChars: 'Letters, numbers, hyphens, and spaces', notes: 'Washington: 1-7 characters.'),
  'WV': const StateRule(maxLength: 8, motorcycleMaxLength: 6, allowedChars: 'Letters, numbers, and spaces', notes: 'West Virginia: 2-8 characters.'),
  'WI': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Wisconsin: 2-7 characters.'),
  'WY': const StateRule(maxLength: 5, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'Wyoming: 2-5 characters.'),
  'DC': const StateRule(maxLength: 7, motorcycleMaxLength: 5, allowedChars: 'Letters, numbers, and spaces', notes: 'District of Columbia: 2-7 characters.'),
};

class PlateValidator {
  static PlateValidationResult validate(String plate, {String? state, String vehicleType = 'car'}) {
    final upper = plate.toUpperCase().trim();

    if (upper.isEmpty) {
      return const PlateValidationResult(
        isValid: false,
        message: 'Plate cannot be empty.',
      );
    }

    final rule = state != null ? stateRules[state] : null;
    final maxLen = rule?.maxLengthFor(vehicleType) ?? 8;
    final minLen = rule?.minLength ?? 1;

    if (upper.length > maxLen) {
      return PlateValidationResult(
        isValid: false,
        message: 'Too long: max $maxLen characters (got ${upper.length}).',
      );
    }

    if (upper.length < minLen) {
      return PlateValidationResult(
        isValid: false,
        message: 'Too short: min $minLen characters (got ${upper.length}).',
      );
    }

    // Basic character check — backend does stricter per-state validation
    if (!RegExp(r"^[A-Z0-9 &\-+']+$").hasMatch(upper)) {
      return PlateValidationResult(
        isValid: false,
        message: 'Invalid characters. Allowed: ${rule?.allowedChars ?? "letters, numbers, and spaces"}.',
      );
    }

    return const PlateValidationResult(
      isValid: true,
      message: 'Valid plate format.',
    );
  }
}
