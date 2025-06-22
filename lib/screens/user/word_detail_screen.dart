import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/dictionary_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class WordDetailScreen extends StatefulWidget {
  final DictionaryWord word;

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  _WordDetailScreenState createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.word.videoUrl != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isVideoLoading = true;
    });

    try {
      _videoController = VideoPlayerController.network(widget.word.videoUrl!);
      await _videoController!.initialize();
      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.word.word,
          style: AppStyles.headingBold.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player
            if (widget.word.videoUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isVideoLoading
                    ? Center(child: CircularProgressIndicator())
                    : _videoController != null && _videoController!.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.video_library,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
              ),
            
            if (widget.word.videoUrl != null) SizedBox(height: 16),
            
            // Word Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Kata',
                      style: AppStyles.headingBold.copyWith(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    _buildInfoRow('Kata:', widget.word.word),
                    SizedBox(height: 12),
                    
                    _buildInfoRow('Arti:', widget.word.meaning),
                    SizedBox(height: 12),
                    
                    if (widget.word.category != null)
                      _buildInfoRow('Kategori:', widget.word.category!.name),
                    
                    if (widget.word.category != null) SizedBox(height: 12),
                    
                    _buildInfoRow('Dicari:', '${widget.word.searchCount} kali'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppStyles.bodyRegular.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppStyles.bodyRegular.copyWith(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}