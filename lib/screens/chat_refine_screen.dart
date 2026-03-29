import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/suggestion_grid.dart';
import 'results_screen.dart';

class ChatRefineScreen extends StatefulWidget {
  final String interest;
  final List<String> existingSuggestions;
  final String state;

  const ChatRefineScreen({
    super.key,
    required this.interest,
    required this.existingSuggestions,
    this.state = 'GA',
  });

  @override
  State<ChatRefineScreen> createState() => _ChatRefineScreenState();
}

class _ChatMessage {
  final String role; // "user" or "assistant"
  final String text;
  final List<String> suggestions;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.suggestions = const [],
  });
}

class _ChatRefineScreenState extends State<ChatRefineScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _apiHistory = [];
  final List<String> _allNewSuggestions = [];
  final Map<String, String> _checkedStatuses = {};
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await ApiService.chatRefine(
        interest: widget.interest,
        message: text,
        history: _apiHistory,
        state: widget.state,
      );

      _apiHistory.add({'role': 'user', 'content': text});
      _apiHistory.add({'role': 'assistant', 'content': response.message});

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          text: response.message,
          suggestions: response.suggestions,
        ));
        _allNewSuggestions.addAll(response.suggestions);
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(const _ChatMessage(
          role: 'assistant',
          text: 'Sorry, something went wrong. Please try again.',
        ));
        _isSending = false;
      });
    }
  }

  Future<void> _checkPlate(String plate) async {
    try {
      final result = await ApiService.checkPlate(plate, state: widget.state);
      if (!mounted) return;
      setState(() => _checkedStatuses[plate] = result.status);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check $plate'), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _allNewSuggestions.isNotEmpty) {
          // Pass new suggestions back
          Navigator.of(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('Refine: "${widget.interest}"'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _allNewSuggestions),
          ),
        ),
        body: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isSending) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Thinking...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final msg = _messages[index];
                  final isUser = msg.role == 'user';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[700] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (msg.suggestions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SuggestionGrid(
                            suggestions: msg.suggestions,
                            checkedStatuses: _checkedStatuses,
                            onPlateTap: _checkPlate,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'e.g. "more aggressive" or "include numbers"',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
