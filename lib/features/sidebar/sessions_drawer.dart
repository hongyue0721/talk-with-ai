import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/chat_session.dart';

class SessionsDrawer extends StatelessWidget {
  const SessionsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: 280,
      child: GlassContainer(
        opacity: 0.15,
        blur: 20,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final sessions = chatProvider.sessions;
            
            return Column(
              children: [
                const SizedBox(height: 50),
                // New Chat Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      chatProvider.createNewSession();
                      Navigator.pop(context); // Close drawer
                    },
                    child: GlassContainer(
                      opacity: 0.2,
                      color: Colors.white,
                      borderWidth: 1.0,
                      borderColor: Colors.white.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "开启新对话",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "历史记录",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // Sessions List
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(
                          child: Text(
                            "暂无对话记录",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final isActive = session.id == chatProvider.currentSession?.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Dismissible(
                                key: Key(session.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: Colors.grey[900],
                                      title: const Text("删除对话", style: TextStyle(color: Colors.white)),
                                      content: const Text("确定要删除这条对话记录吗？", style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          child: const Text("取消"),
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text("删除", style: TextStyle(color: Colors.red)),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  chatProvider.deleteSession(session.id);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    chatProvider.switchSession(session.id);
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isActive 
                                        ? Border.all(color: Colors.white.withOpacity(0.2)) 
                                        : null,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.chat_bubble_outline, 
                                          color: Colors.white70, size: 18),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                session.title.isEmpty ? "新对话" : session.title,
                                                style: TextStyle(
                                                  color: isActive ? Colors.white : Colors.white70,
                                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(session.createdAt),
                                                style: TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
