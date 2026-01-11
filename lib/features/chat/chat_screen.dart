<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../sidebar/sessions_drawer.dart';
import '../settings/settings_screen.dart';
import 'widgets/message_bubble.dart';
import '../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final session = chatProvider.currentSession;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SessionsDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(session?.title ?? "AI Chat", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Global Background
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              if (settings.settings.backgroundImagePath != null) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(settings.settings.backgroundImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Add a slight dark overlay to ensure text readability
                  child: Container(color: Colors.black.withOpacity(0.3)),
                );
              }
              return Container(
                 decoration: const BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                     colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                   ),
                 ),
              );
            }
          ),
          
          Column(
            children: [
              Expanded(
                child: session == null 
                  ? const Center(child: Text("Loading...", style: TextStyle(color: Colors.white))) 
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                      itemCount: session.messages.length + (chatProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        final userAvatarPath = Provider.of<SettingsProvider>(context, listen: false).settings.userAvatarPath;
                        
                        if (index < session.messages.length) {
                          return MessageBubble(
                            message: session.messages[index],
                            userAvatarPath: userAvatarPath,
                          );
                        } else {
                          // Streaming partial message
                          return MessageBubble(
                            message: ChatMessage(
                              role: Role.assistant,
                              content: chatProvider.streamingContent,
                              timestamp: DateTime.now()
                            ),
                            isStreaming: true,
                            userAvatarPath: userAvatarPath,
                          );
                        }
                      },
                    ),
              ),
              
              // Input Area
              _buildInputArea(context, chatProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider provider) {
     return GlassContainer(
       margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       color: Colors.black,
       opacity: 0.3,
       child: Row(
         children: [
           Expanded(
             child: TextField(
               controller: _controller,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(
                 hintText: "发送消息...",
                 hintStyle: TextStyle(color: Colors.white54),
                 border: InputBorder.none,
               ),
               maxLines: null,
             ),
           ),
           IconButton(
             icon: Icon(
               provider.isLoading ? Icons.stop_circle_outlined : Icons.send_rounded, 
               color: Colors.blueAccent
             ),
             onPressed: () {
               if (provider.isLoading) {
                 // Implement cancellation if needed
               } else {
                 if (_controller.text.trim().isNotEmpty) {
                   final text = _controller.text;
                   _controller.clear();
                   provider.sendMessage(text);
                   
                   // Auto scroll to bottom
                   WidgetsBinding.instance.addPostFrameCallback((_) {
                     if (_scrollController.hasClients) {
                       _scrollController.animateTo(
                         _scrollController.position.maxScrollExtent + 100,
                         duration: const Duration(milliseconds: 300),
                         curve: Curves.easeOut,
                       );
                     }
                   });
                 }
               }
             },
           ),
         ],
       ),
     );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../sidebar/sessions_drawer.dart';
import '../settings/settings_screen.dart';
import 'widgets/message_bubble.dart';
import '../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final session = chatProvider.currentSession;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SessionsDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(session?.title ?? "AI Chat", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Global Background (Mesh Gradient)
          Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
               ),
             ),
          ),
          
          Column(
            children: [
              Expanded(
                child: session == null 
                  ? const Center(child: Text("Loading...", style: TextStyle(color: Colors.white))) 
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                      itemCount: session.messages.length + (chatProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < session.messages.length) {
                          return MessageBubble(message: session.messages[index]);
                        } else {
                          // Streaming partial message
                          return MessageBubble(
                            message: ChatMessage(
                              role: Role.assistant, 
                              content: chatProvider.streamingContent,
                              timestamp: DateTime.now()
                            ),
                            isStreaming: true,
                          );
                        }
                      },
                    ),
              ),
              
              // Input Area
              _buildInputArea(context, chatProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider provider) {
     return GlassContainer(
       margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       color: Colors.black,
       opacity: 0.3,
       child: Row(
         children: [
           Expanded(
             child: TextField(
               controller: _controller,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(
                 hintText: "发送消息...",
                 hintStyle: TextStyle(color: Colors.white54),
                 border: InputBorder.none,
               ),
               maxLines: null,
             ),
           ),
           IconButton(
             icon: Icon(
               provider.isLoading ? Icons.stop_circle_outlined : Icons.send_rounded, 
               color: Colors.blueAccent
             ),
             onPressed: () {
               if (provider.isLoading) {
                 // Implement cancellation if needed
               } else {
                 if (_controller.text.trim().isNotEmpty) {
                   final text = _controller.text;
                   _controller.clear();
                   provider.sendMessage(text);
                   
                   // Auto scroll to bottom
                   WidgetsBinding.instance.addPostFrameCallback((_) {
                     if (_scrollController.hasClients) {
                       _scrollController.animateTo(
                         _scrollController.position.maxScrollExtent + 100,
                         duration: const Duration(milliseconds: 300),
                         curve: Curves.easeOut,
                       );
                     }
                   });
                 }
               }
             },
           ),
         ],
       ),
     );
  }
}
>>>>>>> bab8979a3a7f0e9d4103bf81c095be0ce584c4d5
