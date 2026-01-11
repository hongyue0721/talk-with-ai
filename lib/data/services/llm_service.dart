import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';

class LLMService {
  final Dio _dio = Dio();

  // Simple connection test
  Future<String> testConnection({
    required String apiKey,
    required String baseUrl,
    required String model,
    required bool isGemini,
  }) async {
    try {
      if (isGemini) {
        // Gemini Test
        final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        final url = "$cleanBaseUrl/v1beta/models/$model:generateContent?key=$apiKey";
        final response = await _dio.post(
           url,
           options: Options(headers: {"Content-Type": "application/json"}),
           data: jsonEncode({"contents": [{"parts": [{"text": "hi"}]}]}),
        );
        if (response.statusCode == 200) return "连接成功";
        return "连接失败: ${response.statusCode}";
      } else {
        // OpenAI Test
        String url = baseUrl;
        if (!url.endsWith('/v1') && !url.contains('/v1/')) {
          final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
          url = "$cleanBaseUrl/v1/chat/completions";
        } else if (!url.endsWith('/chat/completions')) {
           final cleanBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
           url = "$cleanBaseUrl/chat/completions";
        }

        final response = await _dio.post(
          url,
          options: Options(headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          }),
          data: jsonEncode({
            "model": model,
            "messages": [{"role": "user", "content": "hi"}],
            "max_tokens": 5
          }),
        );
        if (response.statusCode == 200) return "连接成功";
        return "连接失败: ${response.statusCode}";
      }
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data?['error']?['message'] ?? e.message;
        return "连接错误: $msg";
      }
      return "错误: $e";
    }
  }

  // General streaming chat interface
  Stream<String> streamChat({
    required String apiKey,
    required String baseUrl,
    required String model,
    required List<ChatMessage> history,
    required double temperature,
    required bool isGemini, // Distinguish between OpenAI and Gemini formats
  }) async* {
    try {
      if (isGemini) {
        yield* _streamGemini(apiKey, baseUrl, model, history, temperature);
      } else {
        yield* _streamOpenAI(apiKey, baseUrl, model, history, temperature);
      }
    } catch (e) {
      yield "Error: ${e.toString()}";
    }
  }

  // OpenAI format streaming request
  Stream<String> _streamOpenAI(
    String apiKey,
    String baseUrl,
    String model,
    List<ChatMessage> history,
    double temperature,
  ) async* {
    // Smart URL construction
    String url = baseUrl;
    // If user provided base host (e.g. api.openai.com), append /v1/chat/completions
    // If user provided /v1 (e.g. proxy.com/v1), append /chat/completions
    // If user provided full path, use as is.
    
    if (!url.endsWith('/chat/completions')) {
       final cleanBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
       if (!cleanBaseUrl.endsWith('/v1')) {
          url = "$cleanBaseUrl/v1/chat/completions";
       } else {
          url = "$cleanBaseUrl/chat/completions";
       }
    }
    
    final messages = history.map((msg) => {
      "role": msg.role == Role.user ? "user" : (msg.role == Role.system ? "system" : "assistant"),
      "content": msg.content
    }).toList();

    final body = {
      "model": model,
      "messages": messages,
      "temperature": temperature,
      "stream": true,
    };

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          responseType: ResponseType.stream,
        ),
        data: jsonEncode(body),
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        final String chunkStr = utf8.decode(chunk);
        final lines = chunkStr.split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') return;
            
            try {
              final data = jsonDecode(dataStr);
              final choices = data['choices'];
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'];
                if (delta != null && delta['content'] != null) {
                  yield delta['content'];
                }
              }
            } catch (e) {
              // Ignore parse errors for partial chunks or keepalives
            }
          }
        }
      }
    } catch (e) {
      if (e is DioException) {
         String errorMsg = "${e.response?.statusCode} - ${e.response?.statusMessage}";
         try {
            // Try to parse detailed error message from JSON body
            if (e.response?.data is Map) {
                final data = e.response?.data;
                if (data['error'] != null) {
                    if (data['error'] is Map) {
                        errorMsg = data['error']['message'] ?? errorMsg;
                    } else if (data['error'] is String) {
                        errorMsg = data['error'];
                    }
                }
            } else if (e.response?.data is String) {
               // sometimes error is just a string body
               errorMsg = e.response!.data;
            }
         } catch (_) {}
         
         yield "API Error: $errorMsg";
      } else {
         yield "Network Error: $e";
      }
    }
  }

  // Gemini format streaming request (REST API)
  Stream<String> _streamGemini(
    String apiKey,
    String baseUrl,
    String model,
    List<ChatMessage> history,
    double temperature,
  ) async* {
    // Compatible with Google AI Studio or Vertex AI REST format
    // Assuming baseUrl is like https://generativelanguage.googleapis.com
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final url = "$cleanBaseUrl/v1beta/models/$model:streamGenerateContent?key=$apiKey";

    final contents = history.where((msg) => msg.role != Role.system).map((msg) => {
      "role": msg.role == Role.user ? "user" : "model",
      "parts": [{"text": msg.content}]
    }).toList();
    
    // Add system instruction if present (Gemini 1.5 Pro/Flash supports system_instruction)
    // For simplicity in this version, we might prepend it to the first user message or ignore it depending on exact model version support.
    // We'll skip specific system_instruction field for broad compatibility unless requested.

    final body = {
      "contents": contents,
      "generationConfig": {
        "temperature": temperature,
      }
    };

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {"Content-Type": "application/json"},
          responseType: ResponseType.stream,
        ),
        data: jsonEncode(body),
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        // Gemini REST API returns a JSON array of objects, often formatted as:
        // [{ ... }]
        // or
        // ,{ ... }]
        // Streaming chunks might come in parts. This is a naive parser.
        // A robust implementation would buffer the stream and parse complete JSON objects.
        
        final String chunkStr = utf8.decode(chunk);
        
        // This is a simplified extraction logic. 
        // In reality, you should use a proper JSON stream parser.
        // We look for the "text" field inside "candidates" -> "content" -> "parts".
        
        // Regex fallback for loose streaming data
        // Pattern: "text": "..."
        final RegExp textRegex = RegExp(r'"text":\s*"(.*?)"');
        final matches = textRegex.allMatches(chunkStr);
        
        for (final match in matches) {
          if (match.groupCount >= 1) {
            String text = match.group(1)!;
            // Unescape JSON string
            text = text.replaceAll(r'\n', '\n').replaceAll(r'\"', '"'); 
            yield text;
          }
        }
      }
    } catch (e) {
       if (e is DioException) {
         yield "Gemini API Error: ${e.response?.statusCode}";
      } else {
         yield "Gemini Error: $e";
      }
    }
  }
}
