import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 3)
enum Role {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  Role role;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;

  // Optional: Token usage, latency, etc. for future
  @HiveField(3)
  int? tokens;

  @HiveField(4)
  int? latencyMs;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.tokens,
    this.latencyMs,
  });
}
