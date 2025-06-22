import 'package:flutter/material.dart';
import '../../models/dictionary_model.dart';
import '../../services/dictionary_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import 'word_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryService _dictionaryService = DictionaryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<DictionaryWord> _words = [];
  List<DictionaryWord> _mostSearchedWords = [];
  List<WordCategory> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final futures = await Future.wait([
        _dictionaryService.getMostSearchedWords(),
        _dictionaryService.getCategories(),
      ]);
      
      setState(() {
        _mostSearchedWords = futures[0] as List<DictionaryWord>;
        _categories = futures[1] as List<WordCategory>;
        _words = _mostSearchedWords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Kamus Bahasa Isyarat',
          style: AppStyles.headingBold.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      // Implement search logic
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari kata...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                
                // Words List
                Expanded(
                  child: _isSearching
                      ? Center(child: CircularProgressIndicator())
                      : _words.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada kata ditemukan',
                                    style: AppStyles.bodyRegular.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _words.length,
                              itemBuilder: (context, index) {
                                final word = _words[index];
                                return _buildWordCard(word);
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildWordCard(DictionaryWord word) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.sign_language,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          word.word,
          style: AppStyles.headingBold.copyWith(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              word.meaning,
              style: AppStyles.bodyRegular.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (word.category != null)
              Column(
                children: [
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      word.category!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (word.searchCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${word.searchCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
        onTap: () {
          _dictionaryService.incrementSearchCount(word.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(word: word),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}