import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/app_settings.dart';
import '../models/chat_message.dart';
import 'llm_service.dart';

class GeminiService implements LLMService {
  @override
  Stream<String> streamResponse(
    String prompt, {
    required List<ChatMessage> history,
    required AppSettings settings,
  }) async* {
    final model = GenerativeModel(
      model: settings.selectedModel.isEmpty ? 'gemini-pro' : settings.selectedModel,
      apiKey: settings.apiKey,
    );

    final chatHistory = history.map((e) {
      if (e.role == 'user') {
        return Content.text(e.content);
      } else {
        return Content.model([TextPart(e.content)]);
      }
    }).toList();

    final chat = model.startChat(history: chatHistory);
    final stream = chat.sendMessageStream(Content.text(prompt));

    await for (final response in stream) {
      if (response.text != null) {
        yield response.text!;
      }
    }
  }
}
