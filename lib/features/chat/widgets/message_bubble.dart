import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../core/widgets/glass_container.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  final String? userAvatarPath;

  const MessageBubble({
    super.key, 
    required this.message, 
    this.isStreaming = false,
    this.userAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Align avatar at bottom
        children: [
          // AI Avatar (Left side)
          if (!isUser) ...[
            _buildAvatar(null, isUser),
            const SizedBox(width: 8),
          ],

          // Message Content
          Flexible(
            child: GlassContainer(
              color: isUser ? Colors.blueAccent : Colors.grey[800],
              opacity: isUser ? 0.3 : 0.3,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 5),
                bottomRight: Radius.circular(isUser ? 5 : 20),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                   MarkdownBody(
                     data: message.content + (isStreaming ? " ▋" : ""),
                     selectable: true,
                     styleSheet: MarkdownStyleSheet(
                       p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                       code: const TextStyle(
                         backgroundColor: Colors.black45, 
                         color: Colors.amberAccent,
                         fontFamily: 'monospace'
                       ),
                       codeblockDecoration: BoxDecoration(
                         color: Colors.black54,
                         borderRadius: BorderRadius.circular(8),
                       ),
                     ),
                   ),
                   const SizedBox(height: 4),
                   Align(
                     alignment: Alignment.bottomRight,
                     child: Text(
                       "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2,'0')}",
                       style: const TextStyle(color: Colors.white38, fontSize: 10),
                     ),
                   )
                ],
              ),
            ),
          ),

          // User Avatar (Right side)
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(userAvatarPath, isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? path, bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
        image: path != null 
          ? DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            )
          : null,
        color: isUser ? Colors.blueAccent.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.5),
      ),
      alignment: Alignment.center,
      child: path == null 
        ? Icon(
            isUser ? Icons.person : Icons.smart_toy,
            size: 20,
            color: Colors.white,
          )
        : null,
    );
  }
}
