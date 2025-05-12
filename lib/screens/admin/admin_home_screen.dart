// lib/screens/admin/admin_home_screen.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously, deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_ngebut/models/unit_model.dart';
import 'package:flutter_ngebut/screens/admin/unit_form_screen.dart';
import 'package:flutter_ngebut/screens/auth/user_type_screen.dart';
import 'package:flutter_ngebut/services/auth_service.dart';
import 'package:flutter_ngebut/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  List<UnitModel> _units = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
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

  Future<void> _deleteUnit(String id) async {
    try {
      await _databaseService.deleteLearningUnit(id);
      await _loadUnits();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unit berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting unit: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(UnitModel unit) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus unit "${unit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUnit(unit.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure content is left-aligned
        children: [
          // Header section with blue background that extends to screen edges
          Container(
            width: double.infinity, // Make sure it extends full width
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 80),
            decoration: const BoxDecoration(
              color: Color(0xFF00B4D8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles in background
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(37.5, -37.5, 0),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(40, 8, 0),
                  ),
                ),
                // Header text - aligned to left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'HALO, ADMIN!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Slightly increased for better visibility
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kelola materi dan latihan pengguna!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Increased font size
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Ensure left-alignment
                children: [
                  // Section title with Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Unit Pembelajaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UnitFormScreen(),
                            ),
                          );
                          
                          if (result == true) {
                            _loadUnits();
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Unit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Unit list
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00B4D8),
                            ),
                          )
                        : _units.isEmpty
                            ? const Center(
                                child: Text('Belum ada unit pembelajaran'),
                              )
                            : ListView.builder(
                                itemCount: _units.length,
                                itemBuilder: (context, index) {
                                  final unit = _units[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF00B4D8),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  unit.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1F2937),
                                                    fontSize: 16,
                                                    decoration: unit.completed 
                                                        ? TextDecoration.lineThrough 
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Unit ${unit.unitNumber} • ${unit.chapterCount} Bab',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  FontAwesomeIcons.pen,
                                                  color: Color(0xFF00B4D8),
                                                  size: 18,
                                                ),
                                                onPressed: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UnitFormScreen(unit: unit),
                                                    ),
                                                  );
                                                  
                                                  if (result == true) {
                                                    _loadUnits();
                                                  }
                                                },
                                                constraints: const BoxConstraints(),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              const SizedBox(width: 16),
                                              IconButton(
                                                icon: const Icon(
                                                  FontAwesomeIcons.trash,
                                                  color: Color(0xFFE76F51),
                                                  size: 18,
                                                ),
                                                onPressed: () => _confirmDelete(unit),
                                                constraints: const BoxConstraints(),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.home, size: 16),
              label: const Text('Beranda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6F6FF),
                foregroundColor: const Color(0xFF00B4D8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: _signOut,
              icon: const Icon(
                FontAwesomeIcons.cog,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}