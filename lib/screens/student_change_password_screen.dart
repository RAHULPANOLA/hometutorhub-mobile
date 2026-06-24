import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class StudentChangePasswordScreen extends StatefulWidget {
  @override
  _StudentChangePasswordScreenState createState() => _StudentChangePasswordScreenState();
}

class _StudentChangePasswordScreenState extends State<StudentChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _studentEmail = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _changePassword() async {
    // Validation
    if (_currentPasswordController.text.isEmpty) {
      _showError('Please enter current password');
      return;
    }
    
    if (_newPasswordController.text.isEmpty) {
      _showError('Please enter new password');
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/student_change_password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _studentEmail,
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Password changed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showError(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showError('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF6C63FF)),
                              SizedBox(height: 20),
                              Text(
                                'Changing password...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.lock,
                                        size: 50,
                                        color: Color(0xFF6C63FF),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Change Password',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Enter your current password and choose a new one',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 30),
                              
                              // Current Password
                              Text(
                                'Current Password *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: _obscureCurrent,
                                decoration: InputDecoration(
                                  hintText: 'Enter current password',
                                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureCurrent = !_obscureCurrent;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // New Password
                              Text(
                                'New Password *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                decoration: InputDecoration(
                                  hintText: 'Enter new password (min 6 characters)',
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFF6C63FF)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNew = !_obscureNew;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Confirm Password
                              Text(
                                'Confirm New Password *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                decoration: InputDecoration(
                                  hintText: 'Re-enter new password',
                                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirm = !_obscureConfirm;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Password Requirements
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.blue.shade700, size: 18),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Password must be at least 6 characters long',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 30),
                              
                              // Update Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6C63FF),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Change Password',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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