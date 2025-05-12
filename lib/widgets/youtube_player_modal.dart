// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerModal extends StatefulWidget {
  final String youtubeUrl;

  const YouTubePlayerModal({
    Key? key,
    required this.youtubeUrl,
  }) : super(key: key);

  @override
  State<YouTubePlayerModal> createState() => _YouTubePlayerModalState();
}

class _YouTubePlayerModalState extends State<YouTubePlayerModal> {
  late YoutubePlayerController _controller;
  late String _videoId;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // Debug log
      print("Initializing player with URL: ${widget.youtubeUrl}");
      
      _videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? '';
      
      // Debug log
      print("Extracted video ID: $_videoId");
      
      if (_videoId.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: _videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Debug log
      print("Error initializing player: $e");
      
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (!_hasError) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug log
    print("Building YouTube player modal. Has error: $_hasError, Is loading: $_isLoading");
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Video Pembelajaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(),
          // Video player
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )
          else if (_hasError)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error memuat video. Pastikan URL valid.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: ${widget.youtubeUrl}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 300,  // Set a fixed width
                height: 200, // Set a fixed height
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: const Color(0xFF00B4D8),
                  progressColors: const ProgressBarColors(
                    playedColor: Color(0xFF00B4D8),
                    handleColor: Color(0xFF00B4D8),
                  ),
                  onReady: () {
                    print("YouTube player is ready");
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}