import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/splashscreen.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/syllabus_provider.dart';
import 'providers/task_provider.dart';
import 'providers/logbook_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/certificate_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SyllabusProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LogbookProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => CertificateProvider()),
      ],

      child: MaterialApp(
        title: 'Syllabuz',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
