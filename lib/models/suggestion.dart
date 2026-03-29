class SuggestResponse {
  final List<String> suggestions;

  const SuggestResponse({required this.suggestions});

  factory SuggestResponse.fromJson(Map<String, dynamic> json) {
    return SuggestResponse(
      suggestions: (json['suggestions'] as List).cast<String>(),
    );
  }
}

class ChatRefineResponse {
  final List<String> suggestions;
  final String message;

  const ChatRefineResponse({required this.suggestions, required this.message});

  factory ChatRefineResponse.fromJson(Map<String, dynamic> json) {
    return ChatRefineResponse(
      suggestions: (json['suggestions'] as List).cast<String>(),
      message: json['message'] as String,
    );
  }
}
