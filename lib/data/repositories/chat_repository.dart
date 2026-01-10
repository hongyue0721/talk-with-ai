import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../data/services/llm_service.dart';
import '../data/services/openai_service.dart';
import '../data/services/gemini_service.dart';
import '../providers/settings_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final settings = ref.watch(settingsProvider);
  return ChatRepository(settings);
});

class ChatRepository {
  final AppSettings settings;

  ChatRepository(this.settings);

  LLMService _getService() {
    if (settings.provider == 'gemini') {
      return GeminiService();
    } else {
      return OpenAIService();
    }
  }

  Stream<String> streamResponse(String prompt, List<dynamic> history) {
    return _getService().streamResponse(
      prompt,
      history: history.cast(),
      settings: settings,
    );
  }
}
