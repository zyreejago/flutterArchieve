// lib/widgets/unit_card.dart
// ignore_for_file: use_super_parameters, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/utils/youtube_player_utils.dart'; // Import utility
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UnitCard extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback onTap;

  const UnitCard({
    Key? key,
    required this.unit,
    required this.onTap,
  }) : super(key: key);

  IconData _getIconData() {
    switch (unit.iconName) {
      case 'hand-paper':
        return FontAwesomeIcons.hand;
      case 'calculator':
        return FontAwesomeIcons.calculator;
      case 'comments':
        return FontAwesomeIcons.comments;
      default:
        return FontAwesomeIcons.book;
    }
  }

  // Check if the unit has a YouTube link
  bool get _hasYoutubeLink => unit.youtubeLink != null && unit.youtubeLink!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
          onTap: () {
            print("Card tapped, has YouTube link: $_hasYoutubeLink");
            // If the unit has a YouTube link, open directly with utility function
            if (_hasYoutubeLink) {
              showYoutubePlayerDialog(context, unit.youtubeLink!);
            } else {
              // Otherwise, execute the original onTap function
              onTap();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              unit.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_hasYoutubeLink)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                FontAwesomeIcons.play,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
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
                              'Unit ${unit.unitNumber}',
                              style: const TextStyle(
                                color: Color(0xFF2B6BAF),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${unit.chapterCount} Bab',
                            style: const TextStyle(
                              color: Color(0xFFDBE9F7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      _hasYoutubeLink ? FontAwesomeIcons.play : _getIconData(),
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
}