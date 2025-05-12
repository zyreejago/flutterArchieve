import 'package:flutter/material.dart';
import 'package:flutter_ngebut/screens/auth/user_type_screen.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bisindo Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const UserTypeScreen(),
    );
  }
}