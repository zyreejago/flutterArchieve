import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ngebut/models/post_model.dart';
import 'package:flutter_ngebut/services/database_service.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart'; 
import 'dart:io';
import 'chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _databaseService.getCommunityPosts();
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading posts: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCommentsDialog(PostModel post) async {
    final TextEditingController commentController = TextEditingController();
    List<Map<String, dynamic>> comments = [];
    
    try {
      comments = await _databaseService.getComments(post.id);
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Komentar (${comments.length})'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      // Menggunakan field 'users' bukan 'profiles'
                      final user = comment['users'];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: user?['avatar_url'] != null
                              ? NetworkImage(user['avatar_url'])
                              : null,
                          child: user?['avatar_url'] == null
                              ? const FaIcon(FontAwesomeIcons.user, size: 12)
                              : null,
                        ),
                        title: Text(
                          user?['name'] ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        subtitle: Text(
                          comment['content'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          try {
                            await _databaseService.addComment(
                              post.id,
                              commentController.text.trim(),
                            );
                            commentController.clear();
                            final newComments = await _databaseService.getComments(post.id);
                            setDialogState(() {
                              comments = newComments;
                            });
                            _loadPosts();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding comment: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.paperPlane),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePostDialog() async {
    final TextEditingController contentController = TextEditingController();
    String? selectedImagePath;
      XFile? selectedXFile;
    
    showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Buat Postingan Baru'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    hintText: 'Apa yang sedang kamu pikirkan?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        if (kIsWeb) {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setDialogState(() {
                              selectedImagePath = image.name;
                              selectedXFile = image; // Simpan XFile
                            });
                          }
                        } else {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setDialogState(() {
                              selectedImagePath = image.path;
                              selectedXFile = image; // Simpan XFile
                            });
                          }
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.image),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? video = await picker.pickVideo(
                          source: ImageSource.gallery,
                        );
                        if (video != null) {
                          setDialogState(() {
                            selectedImagePath = video.path;
                            selectedXFile = video; // Simpan XFile
                          });
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.video),
                    ),
                  ],
                ),
                if (selectedImagePath != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImagePath!.endsWith('.mp4')
                        ? const Center(child: FaIcon(FontAwesomeIcons.video))
                        : kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: selectedXFile?.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              )
                            : Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (contentController.text.trim().isEmpty) return;
                  
                  try {
                    String? mediaUrl;
                    if (selectedXFile != null) {
                      // Gunakan selectedXFile yang sudah disimpan
                      mediaUrl = await _databaseService.uploadImageFromXFile(selectedXFile!);
                    }
                    
                    await _databaseService.createPost(
                      content: contentController.text.trim(),
                      imageUrl: selectedImagePath != null && 
                              (selectedImagePath!.toLowerCase().endsWith('.jpg') || 
                               selectedImagePath!.toLowerCase().endsWith('.png') ||
                               selectedImagePath!.toLowerCase().endsWith('.jpeg'))
                          ? mediaUrl
                          : null,
                      videoUrl: selectedImagePath != null && 
                              selectedImagePath!.toLowerCase().endsWith('.mp4')
                          ? mediaUrl
                          : null,
                    );
                    
                    Navigator.pop(context);
                    _loadPosts();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating post: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Posting'),
              ),
            ],
          );
        },
      );
    },
  );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam';
    } else {
      return '${difference.inDays} hari';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search and chat
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00A9CE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00A9CE)),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatListScreen(),
                          ),
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.comment,
                        color: Color(0xFF00A9CE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Posts list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF00A9CE),
        child: const FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: post.userAvatar != null
                    ? NetworkImage(post.userAvatar!)
                    : null,
                child: post.userAvatar == null
                    ? const FaIcon(FontAwesomeIcons.user, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.userName ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '@${post.userName?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${_formatTimeAgo(post.createdAt)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Post content
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          // Media
          if (post.imageUrl != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                _buildActionButton(
                  icon: FontAwesomeIcons.comment,
                  count: post.commentsCount,
                  onTap: () => _showCommentsDialog(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: post.isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  count: post.likesCount,
                  isActive: post.isLiked,
                  onTap: () async {
                    await _databaseService.toggleLike(post.id);
                    _loadPosts();
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: () async {
                    try {
                      // Buat teks untuk dibagikan
                      String shareText = '${post.userName ?? "Seseorang"} berbagi:\n\n${post.content}';
                      
                      // Tambahkan URL media jika ada
                      if (post.imageUrl != null) {
                        shareText += '\n\nLihat gambar: ${post.imageUrl}';
                      }
                      if (post.videoUrl != null) {
                        shareText += '\n\nLihat video: ${post.videoUrl}';
                      }
                      
                      // Tambahkan signature aplikasi
                      shareText += '\n\nDibagikan dari Flutter Ngebut App';
                      
                      // Share menggunakan share_plus
                      await Share.share(
                        shareText,
                        subject: 'Postingan dari ${post.userName ?? "Flutter Ngebut"}',
                      );
                    } catch (e) {
                      // Jika terjadi error, tampilkan pesan error
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal membagikan postingan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.share,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 16,
            color: isActive ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: isActive ? Colors.red : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}