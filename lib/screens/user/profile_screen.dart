import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_ngebut/services/auth_service.dart';
import 'package:flutter_ngebut/screens/auth/user_type_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  String _selectedTab = 'Semua';
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _userLikes = [];
  List<Map<String, dynamic>> _userComments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserActivity();
  }

  // Tambahkan didUpdateWidget untuk refresh saat widget diupdate
  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshProfile();
  }

  // Tambahkan didChangeDependencies untuk refresh saat dependencies berubah
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _refreshProfile();
    }
  }

  // Method untuk refresh profile dengan loading indicator
  Future<void> _refreshProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _loadUserActivity();
    } catch (error) {
      print('Error refreshing profile: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserActivity() async {
    if (!mounted) return;
    
    try {
      await Future.wait([
        _loadUserPosts(),
        _loadUserLikes(),
        _loadUserComments(),
      ]);
    } catch (error) {
      print('Error loading user activity: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final postsResponse = await _supabase
            .from('posts')
            .select('*, users(name)')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        
        if (mounted) {
          setState(() {
            _userPosts = List<Map<String, dynamic>>.from(postsResponse);
          });
        }
      }
    } catch (error) {
      print('Error loading user posts: $error');
    }
  }

  Future<void> _loadUserLikes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final likesResponse = await _supabase
            .from('post_likes')
            .select('*, posts(*, users(name))')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        
        if (mounted) {
          setState(() {
            _userLikes = List<Map<String, dynamic>>.from(likesResponse);
          });
        }
      }
    } catch (error) {
      print('Error loading user likes: $error');
    }
  }

  Future<void> _loadUserComments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final commentsResponse = await _supabase
            .from('post_comments')
            .select('*, posts(*, users(name))')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _userComments = List<Map<String, dynamic>>.from(commentsResponse);
          });
        }
      }
    } catch (error) {
      print('Error loading user comments: $error');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserTypeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $error')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredContent() {
    switch (_selectedTab) {
      case 'Posts':
        return _userPosts.map((post) => {
          ...post,
          'type': 'post',
          'activity_text': 'Membuat post'
        }).toList();
      case 'Suka':
        return _userLikes.map((like) => {
          ...like,
          'type': 'like',
          'activity_text': 'Menyukai post dari ${like['posts']?['users']?['name'] ?? 'Anonymous'}'
        }).toList();
      case 'Komentar':
        return _userComments.map((comment) => {
          ...comment,
          'type': 'comment',
          'activity_text': 'Berkomentar di post ${comment['posts']?['users']?['name'] ?? 'Anonymous'}'
        }).toList();
      default:
        List<Map<String, dynamic>> allActivity = [];
        
        // Add posts
        allActivity.addAll(_userPosts.map((post) => {
          ...post,
          'type': 'post',
          'activity_text': 'Membuat post',
          'timestamp': post['created_at']
        }));
        
        // Add likes
        allActivity.addAll(_userLikes.map((like) => {
          ...like,
          'type': 'like',
          'activity_text': 'Menyukai post dari ${like['posts']?['users']?['name'] ?? 'Anonymous'}',
          'timestamp': like['created_at']
        }));
        
        // Add comments
        allActivity.addAll(_userComments.map((comment) => {
          ...comment,
          'type': 'comment',
          'activity_text': 'Berkomentar di post ${comment['posts']?['users']?['name'] ?? 'Anonymous'}',
          'timestamp': comment['created_at']
        }));
        
        // Sort by timestamp
        allActivity.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
        
        return allActivity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header dengan background dan tombol logout
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A9BDC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        image: DecorationImage(
                          image: NetworkImage('https://storage.googleapis.com/a1aa/image/2851773d-b3e9-404f-1b54-8aa7b2d50043.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Tombol refresh
                    Positioned(
                      top: 46,
                      left: 16,
                      child: GestureDetector(
                        onTap: _refreshProfile,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: Color(0xFF0EA5E9),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Tombol logout
                    Positioned(
                      top: 46,
                      right: 16,
                      child: GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bagian profil dengan avatar
              Container(
                transform: Matrix4.translationValues(0, -40, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                  child: Column(
                    children: [
                      // Avatar - centered
                      Center(
                        child: Transform.translate(
                          offset: Offset(0, -60),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundImage: user?.userMetadata?['avatar_url'] != null
                                  ? NetworkImage(user!.userMetadata!['avatar_url'])
                                  : AssetImage('assets/images/avatar.png') as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      // Nama user
                      Transform.translate(
                        offset: Offset(0, -40),
                        child: Column(
                          children: [
                            Text(
                              user?.userMetadata?['name'] ?? user?.email ?? 'User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Statistik
                      Transform.translate(
                        offset: Offset(0, -20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Posts', _userPosts.length.toString()),
                              Container(
                                width: 1,
                                height: 40,
                                color: Color(0xFFE2E8F0),
                              ),
                              _buildStatItem('Likes', _userLikes.length.toString()),
                              Container(
                                width: 1,
                                height: 40,
                                color: Color(0xFFE2E8F0),
                              ),
                              _buildStatItem('Komentar', _userComments.length.toString()),
                            ],
                          ),
                        ),
                      ),
                      // Tombol Edit Profil
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement edit profile
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0EA5E9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Tab aktivitas
                      SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Semua'),
                            _buildTabButton('Posts'),
                            _buildTabButton('Suka'),
                            _buildTabButton('Komentar'),
                          ],
                        ),
                      ),
                      // Daftar aktivitas
                      SizedBox(height: 24),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0EA5E9),
                              ),
                            )
                          : _buildActivityList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Color(0xFF0EA5E9) : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final filteredContent = _getFilteredContent();
    
    if (filteredContent.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada aktivitas',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(filteredContent[index]);
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> item) {
    String activityText = item['activity_text'] ?? '';
    String timeAgo = _getTimeAgo(item['created_at'] ?? item['timestamp']);
    
    IconData icon;
    Color iconColor;
    
    switch (item['type']) {
      case 'post':
        icon = Icons.article_outlined;
        iconColor = Color(0xFF0EA5E9);
        break;
      case 'like':
        icon = Icons.favorite_outline;
        iconColor = Color(0xFFEF4444);
        break;
      case 'comment':
        icon = Icons.chat_bubble_outline;
        iconColor = Color(0xFF10B981);
        break;
      default:
        icon = Icons.circle;
        iconColor = Color(0xFF64748B);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Waktu tidak diketahui';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }
}