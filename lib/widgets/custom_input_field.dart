// lib/widgets/custom_input_field.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/constants/app_colors.dart';
import 'package:flutter_ngebut/constants/app_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomInputField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: AppStyles.bodyRegular.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppStyles.bodyRegular.copyWith(color: AppColors.textGrey),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIcon: widget.prefixIcon != null 
          ? Icon(widget.prefixIcon, color: AppColors.primary, size: 18) 
          : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: FaIcon(
                  _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}