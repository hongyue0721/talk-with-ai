import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("设置", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Global Background would be here
          Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
               ),
             ),
          ),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("API 配置"),
                _buildGlassInput(
                  context, 
                  label: "API Key", 
                  obscure: true,
                  onChanged: (val) => context.read<SettingsProvider>().updateApiKey(val),
                  value: context.watch<SettingsProvider>().settings.apiKey,
                ),
                const SizedBox(height: 10),
                _buildGlassInput(
                  context, 
                  label: "Base URL", 
                  onChanged: (val) => context.read<SettingsProvider>().updateBaseUrl(val),
                  value: context.watch<SettingsProvider>().settings.baseUrl,
                ),
                const SizedBox(height: 10),
                _buildGlassInput(
                  context,
                  label: "模型名称 (e.g. gpt-4, gemini-pro)",
                  onChanged: (val) => context.read<SettingsProvider>().updateModel(val),
                  value: context.watch<SettingsProvider>().settings.model,
                ),
                const SizedBox(height: 10),
                _buildGlassInput(
                  context,
                  label: "预设提示词 (System Prompt)",
                  onChanged: (val) => context.read<SettingsProvider>().updateSystemPrompt(val),
                  value: context.watch<SettingsProvider>().settings.systemPrompt,
                  maxLines: 3,
                ),

                const SizedBox(height: 30),
                _buildSectionHeader("模型参数"),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("温度 (Temperature)", style: TextStyle(color: Colors.white)),
                          Text(
                            context.watch<SettingsProvider>().settings.temperature.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Slider(
                        value: context.watch<SettingsProvider>().settings.temperature,
                        min: 0.0,
                        max: 2.0,
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.white10,
                        onChanged: (val) => context.read<SettingsProvider>().updateTemperature(val),
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("附带历史消息数", style: TextStyle(color: Colors.white)),
                          Text(
                            "${context.watch<SettingsProvider>().settings.historyCount} 条",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Slider(
                        value: context.watch<SettingsProvider>().settings.historyCount.toDouble(),
                        min: 0.0,
                        max: 50.0,
                        divisions: 50,
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.white10,
                        onChanged: (val) => context.read<SettingsProvider>().updateHistoryCount(val.toInt()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                _buildSectionHeader("界面设置"),
                GlassContainer(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     children: [
                       ListTile(
                         title: const Text("字体大小", style: TextStyle(color: Colors.white)),
                         trailing: DropdownButton<double>(
                           dropdownColor: Colors.grey[900],
                           value: context.watch<SettingsProvider>().settings.fontSize,
                           style: const TextStyle(color: Colors.white),
                           items: const [
                             DropdownMenuItem(value: 12.0, child: Text("小")),
                             DropdownMenuItem(value: 14.0, child: Text("标准")),
                             DropdownMenuItem(value: 16.0, child: Text("大")),
                             DropdownMenuItem(value: 18.0, child: Text("特大")),
                           ],
                           onChanged: (val) {
                             if(val != null) context.read<SettingsProvider>().updateFontSize(val);
                           },
                         ),
                       ),
                       const Divider(color: Colors.white24),
                       ListTile(
                         title: const Text("聊天背景", style: TextStyle(color: Colors.white)),
                         subtitle: Text(
                           context.watch<SettingsProvider>().settings.backgroundImagePath != null 
                             ? "已设置: ...${context.watch<SettingsProvider>().settings.backgroundImagePath!.split(Platform.pathSeparator).last}"
                             : "默认渐变",
                           style: const TextStyle(color: Colors.white54, fontSize: 12),
                         ),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             if (context.watch<SettingsProvider>().settings.backgroundImagePath != null)
                               IconButton(
                                 icon: const Icon(Icons.close, color: Colors.redAccent),
                                 onPressed: () => context.read<SettingsProvider>().updateBackgroundImage(null),
                               ),
                             IconButton(
                               icon: const Icon(Icons.image, color: Colors.blueAccent),
                               onPressed: () async {
                                 FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                                 if (result != null) {
                                   context.read<SettingsProvider>().updateBackgroundImage(result.files.single.path);
                                 }
                               },
                             ),
                           ],
                         ),
                       ),
                       const Divider(color: Colors.white24),
                       ListTile(
                         title: const Text("用户头像", style: TextStyle(color: Colors.white)),
                         subtitle: Text(
                           context.watch<SettingsProvider>().settings.userAvatarPath != null 
                             ? "已设置"
                             : "默认图标",
                           style: const TextStyle(color: Colors.white54, fontSize: 12),
                         ),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             if (context.watch<SettingsProvider>().settings.userAvatarPath != null)
                               IconButton(
                                 icon: const Icon(Icons.close, color: Colors.redAccent),
                                 onPressed: () => context.read<SettingsProvider>().updateUserAvatar(null),
                               ),
                             IconButton(
                               icon: const Icon(Icons.account_circle, color: Colors.blueAccent),
                               onPressed: () async {
                                 FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                                 if (result != null) {
                                   context.read<SettingsProvider>().updateUserAvatar(result.files.single.path);
                                 }
                               },
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGlassInput(
    BuildContext context, {
    required String label,
    required Function(String) onChanged,
    required String value,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        initialValue: value,
        obscureText: obscure,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
