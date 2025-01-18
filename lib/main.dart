import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/landing_page.dart';
import 'utils/language_controller.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await NotificationService.instance.scheduleDailyNotification();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageController(),
      child: const MyApp(),
    ),
  );
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
