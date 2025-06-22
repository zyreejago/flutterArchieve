import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dictionary_model.dart';

class DictionaryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil kata-kata paling sering dicari
  Future<List<DictionaryWord>> getMostSearchedWords({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('dictionary_words')
          .select('*, word_categories(*)')
          .order('search_count', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((item) => DictionaryWord.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kata populer: $e');
    }
  }

  // Cari kata berdasarkan query
  Future<List<DictionaryWord>> searchWords(String query, {int? categoryId}) async {
    try {
      var queryBuilder = _supabase
          .from('dictionary_words')
          .select('*, word_categories(*)')
          .ilike('word', '%$query%');
      
      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }
      
      final response = await queryBuilder.order('search_count', ascending: false);
      
      return (response as List)
          .map((item) => DictionaryWord.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mencari kata: $e');
    }
  }

  // Ambil semua kategori
  Future<List<WordCategory>> getCategories() async {
    try {
      final response = await _supabase
          .from('word_categories')
          .select('*')
          .order('name');
      
      return (response as List)
          .map((item) => WordCategory.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kategori: $e');
    }
  }

  // Tambah hitungan pencarian
 // ... existing code ...

// Tambah hitungan pencarian
Future<void> incrementSearchCount(String wordId) async {
  try {
    // Ambil nilai search_count saat ini
    final currentData = await _supabase
        .from('dictionary_words')
        .select('search_count')
        .eq('id', wordId)
        .single();
    
    final currentCount = currentData['search_count'] as int? ?? 0;
    
    // Update dengan nilai baru
    await _supabase
        .from('dictionary_words')
        .update({'search_count': currentCount + 1})
        .eq('id', wordId);
  } catch (e) {
    print('Gagal menambah hitungan pencarian: $e');
  }
}

// ... existing code ...

  // Ambil kata berdasarkan kategori
  Future<List<DictionaryWord>> getWordsByCategory(int categoryId) async {
    try {
      final response = await _supabase
          .from('dictionary_words')
          .select('*, word_categories(*)')
          .eq('category_id', categoryId)
          .order('word');
      
      return (response as List)
          .map((item) => DictionaryWord.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kata berdasarkan kategori: $e');
    }
  }
}