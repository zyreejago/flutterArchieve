// lib/screens/user/user_home_screen.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously, deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_assets.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/screens/auth/user_type_screen.dart';
import 'package:flutter_ngebut/services/auth_service.dart';
import 'package:flutter_ngebut/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  List<UnitModel> _units = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;
  bool _isVideoLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final units = await _databaseService.getLearningUnits();
      setState(() {
        _units = units;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading units: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserTypeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showYouTubeVideo(String videoId) {
    if (_youtubeController != null) {
      _youtubeController!.dispose();
    }

    setState(() {
      _isVideoLoading = true;
      _isPlayerReady = false;
    });

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        forceHD: true,
        hideControls: false,
        showLiveFullscreenButton: false,
        useHybridComposition: true,
        loop: false,
        controlsVisibleAtStart: true,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                _youtubeController?.pause();
                return true;
              },
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B4D8),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Video Pembelajaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                _youtubeController?.pause();
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            YoutubePlayer(
                              controller: _youtubeController!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: const Color(0xFF00B4D8),
                              progressColors: const ProgressBarColors(
                                playedColor: Color(0xFF00B4D8),
                                handleColor: Color(0xFF00B4D8),
                              ),
                              onReady: () {
                                setState(() {
                                  _isPlayerReady = true;
                                  _isVideoLoading = false;
                                });
                                // Tunggu sebentar sebelum memutar video
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (_youtubeController != null && mounted) {
                                    _youtubeController!.play();
                                  }
                                });
                              },
                              onEnded: (data) {
                                setState(() {
                                  _isPlayerReady = false;
                                  _isVideoLoading = false;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            if (_isVideoLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00B4D8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (_youtubeController != null) {
        _youtubeController!.dispose();
        _youtubeController = null;
      }
      setState(() {
        _isPlayerReady = false;
        _isVideoLoading = false;
      });
    });
  }

  IconData _getIconForUnit(String title) {
    if (title.toLowerCase().contains('salam')) {
      return FontAwesomeIcons.hand;
    } else if (title.toLowerCase().contains('angka') || 
              title.toLowerCase().contains('hitung')) {
      return FontAwesomeIcons.calculator;
    } else if (title.toLowerCase().contains('percakapan') || 
              title.toLowerCase().contains('sehari')) {
      return FontAwesomeIcons.comments;
    }
    return FontAwesomeIcons.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue curved top section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF00B4D8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FC1E9).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  right: 40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FC1E9).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content on top of decorative elements
                Column(
                  children: [
                    // Top header with greeting and avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'HALO, PENGGUNA!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Siap belajar hari ini?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            AppAssets.avatar,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Achievement cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildAchievementCard(
                            icon: FontAwesomeIcons.trophy,
                            value: '0',
                            label: 'PENCAPAIAN',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAchievementCard(
                            icon: FontAwesomeIcons.fire,
                            value: '0',
                            label: 'REKOR SAAT INI',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B4D8),
                      ),
                    )
                  : _units.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada unit pembelajaran',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _units.length,
                          itemBuilder: (context, index) {
                            final unit = _units[index];
                            return _buildUnitCard(
                              title: unit.title,
                              unitNumber: unit.unitNumber,
                              chapterCount: unit.chapterCount,
                              icon: _getIconForUnit(unit.title),
                              onTap: () {
                                // Tampilkan modal konfirmasi
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: Text('Yakin ingin membuka unit: ${unit.title}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            if (unit.youtubeLink != null) {
                                              // Extract video ID from YouTube URL
                                              String? videoId;
                                              try {
                                                videoId = YoutubePlayer.convertUrlToId(unit.youtubeLink!);
                                                if (videoId == null) {
                                                  // Coba ekstrak ID manual jika format URL tidak standar
                                                  final uri = Uri.parse(unit.youtubeLink!);
                                                  if (uri.host.contains('youtube.com')) {
                                                    videoId = uri.queryParameters['v'];
                                                  } else if (uri.host.contains('youtu.be')) {
                                                    videoId = uri.pathSegments.last;
                                                  }
                                                }
                                              } catch (e) {
                                                debugPrint('Error parsing YouTube URL: $e');
                                              }

                                              if (videoId != null) {
                                                _showYouTubeVideo(videoId);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('URL video tidak valid'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Video belum tersedia'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Ya'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: FontAwesomeIcons.home,
              label: 'Beranda',
              index: 0,
            ),
            _buildNavItem(
              icon: FontAwesomeIcons.users,
              index: 1,
              showLabel: false,
            ),
            _buildNavItem(
              icon: FontAwesomeIcons.fileAlt,
              index: 2,
              showLabel: false,
            ),
            _buildNavItem(
              icon: FontAwesomeIcons.userCircle,
              index: 3,
              showLabel: false,
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFA9D1E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF5CA4D1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF5CA4D1),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7EA9C9),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard({
    required String title,
    required int unitNumber,
    required int chapterCount,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF00B5D9), Color(0xFF009CCA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009CCA).withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4FB),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Unit $unitNumber',
                            style: const TextStyle(
                              color: Color(0xFF2B6BAF),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$chapterCount Bab',
                          style: const TextStyle(
                            color: Color(0xFFDBE9F7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: const Color(0xFF009CCA),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    String? label,
    required int index,
    bool showLabel = true,
    VoidCallback? onTap,
  }) {
    final isActive = _selectedTabIndex == index;
    
    return InkWell(
      onTap: onTap ?? () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: showLabel && isActive
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE6F4FB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              color: isActive 
                  ? const Color(0xFF5CA4D1) 
                  : const Color(0xFF8B94B2),
              size: 18,
            ),
            if (showLabel && isActive) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: const TextStyle(
                  color: Color(0xFF5CA4D1),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}