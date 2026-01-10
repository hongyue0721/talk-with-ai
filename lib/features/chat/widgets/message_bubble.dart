import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../core/widgets/glass_container.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;

  const MessageBubble({super.key, required this.message, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
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
    );
  }
}
