// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Menampilkan YouTube player dalam dialog
void showYoutubePlayerDialog(BuildContext context, String youtubeUrl) {
  final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
  print("Video ID: $videoId dari URL: $youtubeUrl");
  
  if (videoId == null || videoId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL YouTube tidak valid'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  final controller = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
    ),
  );
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Video Pembelajaran'),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 250, // Fixed height for video
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          bottomActions: [
            const SizedBox(width: 14.0),
            CurrentPosition(),
            const SizedBox(width: 8.0),
            ProgressBar(
              isExpanded: true,
              colors: const ProgressBarColors(
                playedColor: Color(0xFF00B4D8),
                handleColor: Color(0xFF00B4D8),
              ),
            ),
            RemainingDuration(),
            const PlaybackSpeedButton(),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  ).then((_) {
    // Dispose controller when dialog is closed
    controller.dispose();
  });
}