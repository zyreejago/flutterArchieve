// lib/screens/admin/unit_form_screen.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/services/database_service.dart';
import 'package:flutter_ngebut/widgets/custom_button.dart';
import 'package:flutter_ngebut/widgets/custom_input_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart'; 

class UnitFormScreen extends StatefulWidget {
  final UnitModel? unit;

  const UnitFormScreen({Key? key, this.unit}) : super(key: key);

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _chapterCountController = TextEditingController();
  final _youtubeLinkController = TextEditingController(); // New controller for YouTube link
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.unit != null) {
      _titleController.text = widget.unit!.title;
      _unitNumberController.text = widget.unit!.unitNumber.toString();
      _chapterCountController.text = widget.unit!.chapterCount.toString();
      if (widget.unit!.youtubeLink != null) {
        _youtubeLinkController.text = widget.unit!.youtubeLink!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitNumberController.dispose();
    _chapterCountController.dispose();
    _youtubeLinkController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      if (widget.unit == null) {
        // Create new unit with proper UUID
        final newUnit = UnitModel(
          id: const Uuid().v4(), // Generate a valid UUID instead of using timestamp
          title: _titleController.text.trim(),
          description: 'Default description',
          unitNumber: int.parse(_unitNumberController.text.trim()),
          chapterCount: int.parse(_chapterCountController.text.trim()),
          completed: false,
          createdAt: now,
          youtubeLink: _youtubeLinkController.text.isNotEmpty ? _youtubeLinkController.text.trim() : null,
        );
        
        await _databaseService.addLearningUnit(newUnit);
      } else {
        // Update existing unit
        final updatedUnit = UnitModel(
          id: widget.unit!.id,
          title: _titleController.text.trim(),
          description: widget.unit!.description, // Add this line
          unitNumber: int.parse(_unitNumberController.text.trim()),
          chapterCount: int.parse(_chapterCountController.text.trim()),
          completed: widget.unit!.completed,
          createdAt: widget.unit!.createdAt,
          iconName: widget.unit!.iconName,
          youtubeLink: _youtubeLinkController.text.isNotEmpty ? _youtubeLinkController.text.trim() : null,
        );
        
        await _databaseService.updateLearningUnit(updatedUnit);
      }
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving unit: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00B4D8)),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.chevronLeft,
                          color: Color(0xFF00B4D8),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Unit Pembelajaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Judul Unit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomInputField(
                          hintText: 'Masukkan judul unit',
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Judul unit tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Unit ke-',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomInputField(
                          hintText: 'Contoh: 1, 2, 3 ...',
                          controller: _unitNumberController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor unit tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Nomor unit harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Jumlah Bab',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomInputField(
                          hintText: 'Contoh: 5',
                          controller: _chapterCountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah bab tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Jumlah bab harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // YouTube Link field
                        const Text(
                          'Link YouTube (opsional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomInputField(
                          hintText: 'Contoh: https://youtu.be/abc123',
                          controller: _youtubeLinkController,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Simple YouTube link validation
                              if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                                return 'Masukkan link YouTube yang valid';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),
                        
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00B4D8),
                                ),
                              )
                            : CustomButton(
                                text: 'Simpan',
                                width: double.infinity,
                                height: 56,
                                backgroundColor: const Color(0xFF00B4D8),
                                onPressed: _saveUnit,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}