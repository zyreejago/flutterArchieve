// lib/screens/auth/user_type_screen.dart
// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_assets.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:flutter_ngebut/screens/auth/login_screen.dart';
import 'package:flutter_ngebut/widgets/custom_button.dart';

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.welcomeIllustration,
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 24),
                Text(
                  'Masuk ke Akun Anda',
                  style: AppStyles.headingBold,
                ),
                const SizedBox(height: 4),
                Text(
                  'Silakan pilih jenis akun untuk masuk ke aplikasi.',
                  style: AppStyles.bodyRegular,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Masuk sebagai Pengguna',
                  width: double.infinity,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userType: 'user'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Masuk sebagai Admin',
                  width: double.infinity,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userType: 'admin'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}