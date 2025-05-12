// lib/widgets/unit_list_item.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UnitListItem extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnitListItem({
    Key? key,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.title,
                  style: AppStyles.subheadingSemiBold.copyWith(
                    decoration: unit.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unit ${unit.unitNumber} • ${unit.chapterCount} Bab',
                  style: AppStyles.smallText.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.pen,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.trash,
                  color: AppColors.danger,
                  size: 18,
                ),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}