import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_session.dart';
import '../data/models/chat_message.dart';
import '../data/services/llm_service.dart';
import '../data/services/storage_service.dart';
import 'settings_provider.dart';

class ChatProvider extends ChangeNotifier {
  final SettingsProvider settingsProvider;
  final LLMService _llmService = LLMService();
  final StorageService _storageService = StorageService();

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String _streamingContent = "";

  ChatProvider({required this.settingsProvider}) {
    _loadSessions();
  }

  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String get streamingContent => _streamingContent;

  void _loadSessions() {
    _sessions = _storageService.getSessions();
    if (_sessions.isNotEmpty) {
      _currentSession = _sessions.first;
    } else {
      createNewSession();
    }
    notifyListeners();
  }

  void createNewSession() {
    final newSession = ChatSession(
      id: const Uuid().v4(),
      title: "新对话",
      createdAt: DateTime.now(),
      messages: [],
    );
    _sessions.insert(0, newSession);
    _currentSession = newSession;
    _storageService.saveSession(newSession);
    notifyListeners();
  }

  void switchSession(String sessionId) {
    _currentSession = _sessions.firstWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    _storageService.deleteSession(sessionId);
    if (_currentSession?.id == sessionId) {
      if (_sessions.isNotEmpty) {
        _currentSession = _sessions.first;
      } else {
        createNewSession();
      }
    }
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_currentSession == null || content.trim().isEmpty) return;

    final userMsg = ChatMessage(
      role: Role.user,
      content: content,
      timestamp: DateTime.now(),
    );

    _currentSession!.messages.add(userMsg);
    _storageService.saveSession(_currentSession!);
    notifyListeners();

    _isLoading = true;
    _streamingContent = "";
    notifyListeners();

    try {
      final settings = settingsProvider.settings;
      
      // Construct context for LLM
      List<ChatMessage> messagesToSend = [];
      
      // 1. Add System Prompt
      if (settings.systemPrompt.isNotEmpty) {
        messagesToSend.add(ChatMessage(
          role: Role.system,
          content: settings.systemPrompt,
          timestamp: DateTime.now(),
        ));
      }
      
      // 2. Add History (Recent N messages, excluding the latest one we just added)
      if (_currentSession!.messages.length > 1) {
        final historyMessages = _currentSession!.messages.sublist(0, _currentSession!.messages.length - 1);
        final int start = (historyMessages.length - settings.historyCount).clamp(0, historyMessages.length);
        final recentHistory = historyMessages.sublist(start);
        messagesToSend.addAll(recentHistory);
      }
      
      // 3. Add the latest user message
      if (_currentSession!.messages.isNotEmpty) {
        messagesToSend.add(_currentSession!.messages.last);
      }

      // Simple heuristic to detect if the user wants to use Gemini format
      // Ideally this should be an explicit toggle in settings
      final isGemini = settings.model.toLowerCase().contains("gemini");
      
      final stream = _llmService.streamChat(
        apiKey: settings.apiKey,
        baseUrl: settings.baseUrl,
        model: settings.model,
        history: messagesToSend,
        temperature: settings.temperature,
        isGemini: isGemini,
      );

      await for (final chunk in stream) {
        _streamingContent += chunk;
        notifyListeners();
      }

      // Save the complete AI message
      final aiMsg = ChatMessage(
        role: Role.assistant,
        content: _streamingContent,
        timestamp: DateTime.now(),
      );
      
      _currentSession!.messages.add(aiMsg);
      
      // Update title if it's the first exchange
      if (_currentSession!.messages.length <= 2) {
        _currentSession!.title = content.length > 20 
            ? "${content.substring(0, 20)}..." 
            : content;
      }
      
      _storageService.saveSession(_currentSession!);

    } catch (e) {
      _currentSession!.messages.add(ChatMessage(
        role: Role.assistant,
        content: "Error: $e",
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _streamingContent = "";
      notifyListeners();
    }
  }
}
