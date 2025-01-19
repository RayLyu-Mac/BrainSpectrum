import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/landing_page.dart';
import 'utils/language_controller.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Add debug print to track initialization
    debugPrint('App initialization starting...');

    runApp(
      ChangeNotifierProvider(
        create: (_) => LanguageController(),
        child: const MyApp(),
      ),
    );

    debugPrint('App initialization complete');
  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Rethrow to ensure we don't silently fail
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Memory Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
