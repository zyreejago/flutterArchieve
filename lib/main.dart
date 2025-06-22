import 'package:flutter/material.dart';
import 'package:flutter_ngebut/supabase_config.dart';
import 'package:flutter_ngebut/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Ganti dari UserTypeScreen ke SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}