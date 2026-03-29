class PlateResult {
  final String plate;
  final bool valid;
  final String status; // "not_found", "assigned", "unknown", "invalid"
  final String message;
  final String officialCheckUrl;

  const PlateResult({
    required this.plate,
    required this.valid,
    required this.status,
    required this.message,
    this.officialCheckUrl = '',
  });

  factory PlateResult.fromJson(Map<String, dynamic> json) {
    return PlateResult(
      plate: json['plate'] as String,
      valid: json['valid'] as bool,
      status: json['status'] as String,
      message: json['message'] as String,
      officialCheckUrl: json['official_check_url'] as String? ?? '',
    );
  }
}
