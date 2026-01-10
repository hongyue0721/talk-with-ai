import 'package:dart_openai/dart_openai.dart';
import '../models/app_settings.dart';
import '../models/chat_message.dart';
import 'llm_service.dart';

class OpenAIService implements LLMService {
  @override
  Stream<String> streamResponse(
    String prompt, {
    required List<ChatMessage> history,
    required AppSettings settings,
  }) async* {
    OpenAI.apiKey = settings.apiKey;
    if (settings.baseUrl.isNotEmpty) {
      OpenAI.baseUrl = settings.baseUrl;
    }

    // Convert history to OpenAI format
    final messages = history.map((e) {
      if (e.role == 'user') {
        return OpenAIChatCompletionChoiceMessageModel(
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(e.content)],
          role: OpenAIChatMessageRole.user,
        );
      } else {
        return OpenAIChatCompletionChoiceMessageModel(
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(e.content)],
          role: OpenAIChatMessageRole.assistant,
        );
      }
    }).toList();

    // Add system prompt
    messages.insert(0, OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(settings.systemPrompt)],
      role: OpenAIChatMessageRole.system,
    ));

    // Add current prompt
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
      role: OpenAIChatMessageRole.user,
    ));

    final stream = OpenAI.instance.chat.createStream(
      model: settings.selectedModel,
      messages: messages,
    );

    await for (final chunk in stream) {
      final content = chunk.choices.first.delta.content;
      if (content != null) {
        for (final item in content) {
          if (item?.text != null) {
             yield item!.text!;
          }
        }
      }
    }
  }
}
