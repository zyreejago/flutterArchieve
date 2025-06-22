// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_ngebut/models/user_model.dart';
import 'package:flutter_ngebut/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabaseClient = SupabaseConfig.supabaseClient;

  // Get the current user if logged in
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
  Future<UserModel?> signUp(String email, String password, String name, String userType) async {
  try {
    debugPrint('Attempting signup with email: $email');
    
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    
    debugPrint('Signup response: ${response.user?.id}');
    
    if (response.user == null) return null;

    // INSERT DATA KE TABLE USERS (bagian yang hilang)
    final userData = {
      'id': response.user!.id,
      'email': email,
      'name': name,
      'user_type': userType,
      'created_at': DateTime.now().toIso8601String(),
    };

    final userResponse = await _supabaseClient
        .from('users')
        .insert(userData)
        .select()
        .single();

    debugPrint('User data inserted: $userResponse');
    
    return UserModel.fromJson(userResponse);
    
  } catch (e) {
    debugPrint('Detailed signup error: $e');
    if (e is AuthException) {
      debugPrint('Auth error code: ${e.statusCode}');
      debugPrint('Auth error message: ${e.message}');
    }
    rethrow;
  }
}
  
  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
  try {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) return null;

    final userData = await _supabaseClient
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(userData);
  } catch (e) {
    debugPrint('Error signing in: $e');
    rethrow;
  }
}

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _supabaseClient.auth.currentUser != null;
  }

  // Get user type (admin or user)
  Future<String?> getUserType() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await _supabaseClient
          .from('users')
          .select('user_type')
          .eq('id', user.id)
          .single();

      return response['user_type'];
    } catch (e) {
      debugPrint('Error getting user type: $e');
      return null;
    }
  }
}