import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_session.dart';

class StorageService {
  late Box<ChatSession> _sessionsBox;

  StorageService() {
    _sessionsBox = Hive.box<ChatSession>('sessions');
  }

  List<ChatSession> getSessions() {
    final list = _sessionsBox.values.toList();
    // Sort by creation time descending (newest first)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveSession(ChatSession session) async {
    await _sessionsBox.put(session.id, session);
    // Note: Since Hive objects are mutable and we are modifying them directly in the provider,
    // calling .save() on the HiveObject itself is also an option if it's already in the box.
    // e.g. session.save();
  }

  Future<void> deleteSession(String id) async {
    await _sessionsBox.delete(id);
  }
}
