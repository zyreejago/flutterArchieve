import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_assets.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:flutter_ngebut/screens/admin/admin_home_screen.dart';
import 'package:flutter_ngebut/screens/user/user_home_screen.dart';
import 'package:flutter_ngebut/services/auth_service.dart';
import 'package:flutter_ngebut/widgets/custom_button.dart';
import 'package:flutter_ngebut/widgets/custom_input_field.dart';
import 'package:flutter_ngebut/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && user != null) {
      // Navigate based on user type
      if (user.userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminHomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserHomeScreen(),
          ),
        );
      }
    }
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login gagal: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      AppAssets.welcomeIllustration,
                      height: 150,
                      width: 150,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Masuk ke Akun Anda',
                    style: AppStyles.headingBold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masukkan email dan password untuk masuk.',
                    style: AppStyles.bodyRegular,
                  ),
                  const SizedBox(height: 32),
                  CustomInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  return 'Format email tidak valid';
}
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _isLoading ? 'Loading...' : 'Masuk',
                    onPressed: _isLoading ? () {} : _handleLogin,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppStyles.bodyRegular,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(userType: 'user'),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar',
                          style: AppStyles.bodyRegular.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}