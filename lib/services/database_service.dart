// lib/services/database_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/supabase_config.dart';

class DatabaseService {
  final SupabaseClient _supabaseClient = SupabaseConfig.supabaseClient;

  // Get all learning units
  Future<List<UnitModel>> getLearningUnits() async {
    try {
      final response = await _supabaseClient
          .from('learning_units')
          .select()
          .order('unit_number');

      return (response as List)
          .map((unit) => UnitModel.fromJson(unit))
          .toList();
    } catch (e) {
      debugPrint('Error getting learning units: $e');
      return [];
    }
  }

  // Add a new learning unit
  Future<UnitModel?> addLearningUnit(UnitModel unit) async {
    try {
      final response = await _supabaseClient
          .from('learning_units')
          .insert(unit.toJson())
          .select()
          .single();

      return UnitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error adding learning unit: $e');
      rethrow;
    }
  }

  // Update a learning unit
  Future<UnitModel?> updateLearningUnit(UnitModel unit) async {
    try {
      final response = await _supabaseClient
          .from('learning_units')
          .update(unit.toJson())
          .eq('id', unit.id)
          .select()
          .single();

      return UnitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating learning unit: $e');
      rethrow;
    }
  }

  // Delete a learning unit
  Future<void> deleteLearningUnit(String id) async {
    try {
      await _supabaseClient
          .from('learning_units')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting learning unit: $e');
      rethrow;
    }
  }
}