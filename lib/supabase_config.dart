// lib/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://diaaijthdckjdilrvhzd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpYWFpanRoZGNramRpbHJ2aHpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4NDU4OTQsImV4cCI6MjA2MjQyMTg5NH0._uDODgrb90nHvZN9aHr-X5rVTfQHZThfH3AMNI8jmFI';

  static SupabaseClient get supabaseClient => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}