import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models
import 'data/models/app_settings.dart';
import 'data/models/chat_message.dart';
import 'data/models/chat_session.dart';

// Providers
import 'providers/settings_provider.dart';
import 'providers/chat_provider.dart';

// Screens
import 'features/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();
  
  // 2. Register Adapters
  // Note: You must run `dart run build_runner build` to generate the .g.dart files
  // before running the app, or these adapters won't be available.
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionAdapter());
  Hive.registerAdapter(RoleAdapter());

  // 3. Open Boxes (Pre-load essential data)
  await Hive.openBox<AppSettings>('settings');
  await Hive.openBox<ChatSession>('sessions');

  // Set system UI overlay style for transparency
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent, 
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Enable edge-to-edge
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const GlassAIApp());
}

class GlassAIApp extends StatelessWidget {
  const GlassAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (context) => ChatProvider(
            settingsProvider: Provider.of<SettingsProvider>(context, listen: false),
          ),
          update: (context, settings, previousChat) => 
            previousChat ?? ChatProvider(settingsProvider: settings),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Glass AI Chat',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark, // Force dark mode for glass effect
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black, // Dark background base
              fontFamily: 'Roboto', // Or user custom font
              useMaterial3: true,
            ),
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
