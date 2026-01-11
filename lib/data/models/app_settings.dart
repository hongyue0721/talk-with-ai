import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  String apiKey;

  @HiveField(1)
  String baseUrl;

  @HiveField(2)
  String model;

  @HiveField(3)
  double temperature;

  @HiveField(4)
  double fontSize;

  @HiveField(5)
  String? backgroundImagePath;

  @HiveField(6)
  String? userAvatarPath;

  @HiveField(7)
  String systemPrompt;

  @HiveField(8)
  int historyCount;

  AppSettings({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.temperature,
    required this.fontSize,
    this.backgroundImagePath,
    this.userAvatarPath,
    this.systemPrompt = "你是一个智能助手。",
    this.historyCount = 10,
  });
}
