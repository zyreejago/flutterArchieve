import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/models/post_model.dart';
import 'package:flutter_ngebut/supabase_config.dart';
import 'package:flutter_ngebut/models/chat_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data'; // Untuk web support
import 'package:image_picker/image_picker.dart';

class DatabaseService {
  // Inisialisasi client Supabase untuk komunikasi dengan database
  final SupabaseClient _supabaseClient = SupabaseConfig.supabaseClient;

  // FUNGSI: Mengambil semua unit pembelajaran dari database
  Future<List<UnitModel>> getLearningUnits() async {
    try {
      // Query ke tabel 'learning_units' dengan urutan berdasarkan unit_number
      final response = await _supabaseClient
          .from('learning_units')
          .select()
          .order('unit_number');

      // Konversi response menjadi list UnitModel
      return (response as List)
          .map((unit) => UnitModel.fromJson(unit))
          .toList();
    } catch (e) {
      // Log error dan return list kosong jika gagal
      debugPrint('Error getting learning units: $e');
      return [];
    }
  }

  // FUNGSI: Mengambil semua percakapan user yang sedang login
  Future<List<ConversationModel>> getConversations() async {
    try {
      // Cek apakah user sudah login
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Ambil percakapan dimana user adalah participant_1 atau participant_2
      final conversationsResponse = await _supabaseClient
          .from('conversations')
          .select('*')
          .or('participant_1.eq.${user.id},participant_2.eq.${user.id}')
          .order('updated_at', ascending: false);

      List<ConversationModel> conversations = [];
      
      // Loop setiap percakapan untuk mendapatkan info user lawan bicara
      for (var conv in conversationsResponse as List) {
        // Tentukan siapa user lawan bicara
        final isParticipant1 = conv['participant_1'] == user.id;
        final otherUserId = isParticipant1 ? conv['participant_2'] : conv['participant_1'];
        
        debugPrint('Looking for user with ID: $otherUserId');
        
        // Ambil info user lawan bicara dari tabel 'users'
        final otherUserResponse = await _supabaseClient
            .from('users')
            .select('name,email')
            .eq('id', otherUserId)
            .maybeSingle();
        
        debugPrint('User query result: $otherUserResponse');
        
        // Hitung jumlah pesan yang belum dibaca
        final unreadCount = await _supabaseClient
            .from('messages')
            .select('id')
            .eq('conversation_id', conv['id'])
            .neq('sender_id', user.id) // Bukan pesan dari user sendiri
            .eq('is_read', false)
            .count();

        final userName = otherUserResponse?['name'];
        debugPrint('Final user name: $userName');

        // Buat object ConversationModel dengan data lengkap
        conversations.add(ConversationModel(
          id: conv['id'],
          participant1: conv['participant_1'],
          participant2: conv['participant_2'],
          lastMessage: conv['last_message'],
          lastMessageAt: conv['last_message_at'] != null 
              ? DateTime.parse(conv['last_message_at']) 
              : null,
          createdAt: DateTime.parse(conv['created_at']),
          otherUserName: userName ?? 'Anonymous', // Fallback ke 'Anonymous'
          otherUserAvatar: null,
          unreadCount: unreadCount.count,
        ));
      }

      return conversations;
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }

  // FUNGSI: Mendapatkan atau membuat percakapan baru antara 2 user
  Future<String?> getOrCreateConversation(String otherUserId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Cek apakah percakapan sudah ada (bisa participant_1 atau participant_2)
      final existingConv = await _supabaseClient
          .from('conversations')
          .select('id')
          .or('and(participant_1.eq.${user.id},participant_2.eq.$otherUserId),and(participant_1.eq.$otherUserId,participant_2.eq.${user.id})')
          .maybeSingle();

      // Jika sudah ada, return ID percakapan
      if (existingConv != null) {
        return existingConv['id'];
      }

      // Jika belum ada, buat percakapan baru
      final newConv = await _supabaseClient
          .from('conversations')
          .insert({
            'participant_1': user.id,
            'participant_2': otherUserId,
          })
          .select('id')
          .single();

      return newConv['id'];
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  // FUNGSI: Mengambil semua pesan dalam percakapan tertentu
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      // Ambil semua pesan berdasarkan conversation_id, urutkan berdasarkan waktu
      final response = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      List<MessageModel> messages = [];
      
      // Loop setiap pesan untuk mendapatkan info pengirim
      for (var messageData in response) {
        print('Looking for sender with ID: ${messageData['sender_id']}');
        
        // Ambil info pengirim dari tabel 'users'
        final userResponse = await _supabaseClient
            .from('users')
            .select('name, email')
            .eq('id', messageData['sender_id'])
            .maybeSingle();
        
        print('Sender query result: $userResponse');
        
        // Tentukan nama pengirim dengan prioritas: name > email > 'Anonymous'
        String senderName = 'Anonymous';
        if (userResponse != null) {
          if (userResponse['name'] != null && userResponse['name'].toString().isNotEmpty) {
            senderName = userResponse['name'];
          } else if (userResponse['email'] != null && userResponse['email'].toString().isNotEmpty) {
            senderName = userResponse['email'];
          }
        }
        
        print('Final sender name: $senderName');
        
        // Buat object MessageModel dengan data lengkap
        messages.add(MessageModel(
          id: messageData['id'],
          conversationId: messageData['conversation_id'],
          senderId: messageData['sender_id'],
          content: messageData['content'],
          createdAt: DateTime.parse(messageData['created_at']),
          isRead: messageData['is_read'] ?? false,
          senderName: senderName,
        ));
      }
      
      return messages;
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  // FUNGSI: Mengirim pesan baru
  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Insert pesan baru ke tabel 'messages'
      await _supabaseClient
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': user.id,
            'content': content,
          });

      return true; // Berhasil mengirim
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false; // Gagal mengirim
    }
  }

  // FUNGSI: Menandai pesan sebagai sudah dibaca
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return;

      // Update semua pesan yang bukan dari user sendiri menjadi is_read = true
      await _supabaseClient
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', user.id); // Kecuali pesan dari user sendiri
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // FUNGSI: Mengambil semua user untuk memulai chat baru
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Ambil semua user kecuali user yang sedang login
      final response = await _supabaseClient
          .from('users')
          .select('id, name, email')
          .neq('id', user.id); // Exclude user sendiri

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  // FUNGSI: Mengambil semua post komunitas dengan info lengkap
  Future<List<PostModel>> getCommunityPosts() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      // Ambil semua post, urutkan berdasarkan waktu terbaru
      final postsResponse = await _supabaseClient
          .from('posts')
          .select('*')
          .order('created_at', ascending: false);

      if (postsResponse.isEmpty) return [];

      // Jika user login, ambil daftar post yang sudah di-like
      List<String> userLikes = [];
      if (user != null) {
        final likesResponse = await _supabaseClient
            .from('post_likes')
            .select('post_id')
            .eq('user_id', user.id);
        
        userLikes = (likesResponse as List)
            .map((like) => like['post_id'] as String)
            .toList();
      }

      // Build posts dengan info user, likes count, dan comments count
      List<PostModel> posts = [];
      for (var post in postsResponse as List) {
        // Ambil info user pembuat post
        final userResponse = await _supabaseClient
            .from('users')
            .select('name')
            .eq('id', post['user_id'])
            .maybeSingle();
        
        // Hitung jumlah likes
        final likesCountResponse = await _supabaseClient
            .from('post_likes')
            .select('id')
            .eq('post_id', post['id'])
            .count(CountOption.exact);
        
        // Hitung jumlah komentar
        final commentsCountResponse = await _supabaseClient
            .from('post_comments')
            .select('id')
            .eq('post_id', post['id'])
            .count(CountOption.exact);
        
        final likesCount = likesCountResponse.count;
        final commentsCount = commentsCountResponse.count;
        final isLiked = userLikes.contains(post['id']); // Cek apakah user sudah like
        
        // Buat PostModel dengan data lengkap
        posts.add(PostModel.fromJson({
          ...post,
          'user_name': userResponse?['name'] ?? 'Anonymous',
          'user_avatar': null,
          'likes_count': likesCount,
          'comments_count': commentsCount,
          'is_liked': isLiked,
        }));
      }
      
      return posts;
    } catch (e) {
      debugPrint('Error getting community posts: $e');
      return [];
    }
  }

  // FUNGSI: Membuat post baru
  Future<PostModel?> createPost({
    required String content,
    String? imageUrl,
    String? videoUrl,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Insert post baru ke tabel 'posts'
      final response = await _supabaseClient
          .from('posts')
          .insert({
            'user_id': user.id,
            'content': content,
            'image_url': imageUrl,
            'video_url': videoUrl,
          })
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow; // Re-throw error untuk handling di UI
    }
  }

  // FUNGSI: Menambahkan komentar ke post
  Future<void> addComment(String postId, String content) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Insert komentar baru ke tabel 'post_comments'
      await _supabaseClient
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content,
          });
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  // FUNGSI: Mengambil semua komentar untuk post tertentu
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      // Ambil semua komentar berdasarkan post_id, urutkan berdasarkan waktu
      final commentsResponse = await _supabaseClient
          .from('post_comments')
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      List<Map<String, dynamic>> commentsWithUsers = [];
      
      // Loop setiap komentar untuk mendapatkan info user
      for (var comment in commentsResponse as List) {
        // Ambil info user pembuat komentar
        final userResponse = await _supabaseClient
            .from('users')
            .select('name, email')
            .eq('id', comment['user_id'])
            .maybeSingle();
        
        // Gabungkan data komentar dengan data user
        commentsWithUsers.add({
          ...comment,
          'users': userResponse,
        });
      }

      return commentsWithUsers;
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }

  // FUNGSI: Toggle like/unlike post
  Future<void> toggleLike(String postId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Cek apakah user sudah like post ini
      final existingLike = await _supabaseClient
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingLike != null) {
        // Jika sudah like, hapus like (unlike)
        await _supabaseClient
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
      } else {
        // Jika belum like, tambahkan like
        await _supabaseClient
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': user.id,
            });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  // FUNGSI: Upload gambar dari file path (untuk mobile)
  Future<String?> uploadImage(String filePath, String fileName) async {
    try {
      // Untuk web, gunakan method uploadImageFromXFile
      if (kIsWeb) {
        debugPrint('Web platform detected, use uploadImageFromXFile instead');
        return null;
      }
      
      // Cek apakah file ada
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        return null;
      }
      
      // Baca file sebagai bytes dan upload
      final bytes = await file.readAsBytes();
      return await uploadImageFromBytes(bytes, fileName, filePath);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // FUNGSI: Upload gambar dari bytes (web compatible)
  Future<String?> uploadImageFromBytes(Uint8List bytes, String fileName, String originalPath) async {
    try {
      // Tentukan ekstensi file berdasarkan path
      String fileExtension = 'jpg';
      if (originalPath.toLowerCase().endsWith('.png')) {
        fileExtension = 'png';
      } else if (originalPath.toLowerCase().endsWith('.mp4')) {
        fileExtension = 'mp4';
      }
      
      final fullFileName = '$fileName.$fileExtension';
      
      // Tentukan bucket berdasarkan tipe file
      final bucketName = fileExtension == 'mp4' ? 'post-videos' : 'post-images';
      
      // Upload file ke Supabase Storage
      await _supabaseClient.storage
          .from(bucketName)
          .uploadBinary(fullFileName, bytes);
      
      // Dapatkan public URL file yang di-upload
      final url = _supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(fullFileName);
      
      return url;
    } catch (e) {
      debugPrint('Error uploading image from bytes: $e');
      return null;
    }
  }

  // FUNGSI: Upload gambar dari XFile (universal untuk web dan mobile)
  Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      // Baca file sebagai bytes
      final bytes = await imageFile.readAsBytes();
      // Generate nama file unik berdasarkan timestamp
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      
      return await uploadImageFromBytes(bytes, fileName, imageFile.path);
    } catch (e) {
      debugPrint('Error uploading image from XFile: $e');
      return null;
    }
  }

  // FUNGSI: Menambahkan unit pembelajaran baru (Admin)
  Future<UnitModel?> addLearningUnit(UnitModel unit) async {
    try {
      // Insert unit baru ke tabel 'learning_units'
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

  // FUNGSI: Update unit pembelajaran (Admin)
  Future<UnitModel?> updateLearningUnit(UnitModel unit) async {
    try {
      // Update unit berdasarkan ID
      final response = await _supabaseClient
          .from('learning_units')
          .update(unit.toJson())
          .eq('id', unit.id ?? '')
          .select()
          .single();

      return UnitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating learning unit: $e');
      rethrow;
    }
  }

  // FUNGSI: Hapus unit pembelajaran (Admin)
  Future<void> deleteLearningUnit(String id) async {
    try {
      // Hapus unit berdasarkan ID
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