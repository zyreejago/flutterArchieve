// lib/screens/auth/login_screen.dart
// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_assets.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:flutter_ngebut/screens/admin/admin_home_screen.dart';
import 'package:flutter_ngebut/screens/user/user_home_screen.dart';
import 'package:flutter_ngebut/services/auth_service.dart';
import 'package:flutter_ngebut/widgets/custom_button.dart';
import 'package:flutter_ngebut/widgets/custom_input_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  final String userType;

  const LoginScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        if (user.userType == widget.userType) {
          if (widget.userType == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const UserHomeScreen()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda tidak memiliki akses sebagai tipe pengguna ini.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau kata sandi tidak valid.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Changed to left alignment
              children: [
                const SizedBox(height: 20), // Reduced top padding
                // Back button now aligned to the left
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.chevronLeft,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Center the remaining content
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Image.asset(
                        AppAssets.loginIllustration,
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Masuk',
                        style: AppStyles.headingBold,
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomInputField(
                              hintText: 'Nama Pengguna',
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama pengguna tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomInputField(
                              hintText: 'Kata sandi',
                              controller: _passwordController,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : CustomButton(
                                    text: 'Masuk',
                                    width: double.infinity,
                                    onPressed: _handleLogin,
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
        ),
      ),
    );
  }
}